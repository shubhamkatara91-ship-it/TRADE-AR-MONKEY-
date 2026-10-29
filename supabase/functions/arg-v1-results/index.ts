// Read-only adapter for a results API the project owner is authorized to use.
// Deploy with JWT verification enabled. Never put upstream secrets in Flutter.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

function readPath(value: unknown, path: string): unknown {
  if (!path) return undefined;
  return path.split(".").reduce<unknown>((current, part) => {
    if (current === null || current === undefined || typeof current !== "object") return undefined;
    return (current as Record<string, unknown>)[part];
  }, value);
}
async function readBoundedBody(response: Response, maxBytes: number): Promise<string> {
  if (!response.body) return "";
  const reader = response.body.getReader(), chunks: Uint8Array[] = [];
  let total = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      total += value.byteLength;
      if (total > maxBytes) { await reader.cancel(); throw new Error("response_too_large"); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const merged = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) { merged.set(chunk, offset); offset += chunk.byteLength; }
  return new TextDecoder("utf-8", { fatal: true }).decode(merged);
}
function stringValue(value: unknown): string | null {
  if (typeof value === "string" && value.trim()) return value.trim();
  if (typeof value === "number" && Number.isFinite(value)) return String(value);
  return null;
}
serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET") return Response.json({ error: "method_not_allowed" }, { status: 405, headers: corsHeaders });

  const upstreamUrl = Deno.env.get("ARG_V1_RESULTS_URL");
  if (!upstreamUrl) return Response.json({ error: "results_source_not_configured", message: "Configure an authorized read-only results API first." }, { status: 503, headers: corsHeaders });

  let parsedUrl: URL;
  try { parsedUrl = new URL(upstreamUrl); } catch {
    return Response.json({ error: "invalid_source_url" }, { status: 500, headers: corsHeaders });
  }
  if (parsedUrl.protocol !== "https:" || parsedUrl.username || parsedUrl.password || (parsedUrl.port && parsedUrl.port !== "443")) {
    return Response.json({ error: "invalid_source_url", message: "HTTPS URL without embedded credentials or a nonstandard port is required." }, { status: 500, headers: corsHeaders });
  }
  const allowedHosts = (Deno.env.get("ARG_V1_ALLOWED_HOSTS") ?? "").split(",").map((host) => host.trim().toLowerCase()).filter(Boolean);
  if (!allowedHosts.includes(parsedUrl.hostname.toLowerCase())) {
    return Response.json({ error: "source_host_not_allowed", message: "Configure the exact authorized hostname in ARG_V1_ALLOWED_HOSTS." }, { status: 500, headers: corsHeaders });
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 8000);
  try {
    const headers = new Headers({ Accept: "application/json" });
    const upstreamKey = Deno.env.get("ARG_V1_RESULTS_API_KEY");
    if (upstreamKey) headers.set("Authorization", `Bearer ${upstreamKey}`);
    const upstream = await fetch(parsedUrl, { method: "GET", headers, signal: controller.signal, redirect: "error" });
    if (!upstream.ok) return Response.json({ error: "upstream_unavailable", upstream_status: upstream.status }, { status: 502, headers: corsHeaders });
    if (!(upstream.headers.get("content-type") ?? "").toLowerCase().includes("json")) {
      return Response.json({ error: "upstream_not_json" }, { status: 502, headers: corsHeaders });
    }
    const declaredLength = Number(upstream.headers.get("content-length") ?? "0");
    if (Number.isFinite(declaredLength) && declaredLength > 1_000_000) return Response.json({ error: "upstream_response_too_large" }, { status: 502, headers: corsHeaders });
    let responseText: string;
    try { responseText = await readBoundedBody(upstream, 1_000_000); }
    catch (error) {
      return Response.json({ error: error instanceof Error && error.message === "response_too_large" ? "upstream_response_too_large" : "upstream_invalid_encoding" }, { status: 502, headers: corsHeaders });
    }
    let payload: unknown;
    try { payload = JSON.parse(responseText); } catch { return Response.json({ error: "upstream_invalid_json" }, { status: 502, headers: corsHeaders }); }

    const rawRows = readPath(payload, Deno.env.get("ARG_V1_ITEMS_PATH") ?? "data");
    if (!Array.isArray(rawRows)) return Response.json({ error: "response_schema_mismatch", message: "Set ARG_V1_ITEMS_PATH to the documented array field." }, { status: 502, headers: corsHeaders });
    const periodField = Deno.env.get("ARG_V1_PERIOD_FIELD") ?? "issueNumber";
    const numberField = Deno.env.get("ARG_V1_NUMBER_FIELD") ?? "number";
    const sizeField = Deno.env.get("ARG_V1_SIZE_FIELD") ?? "bigSmall";
    const timeField = Deno.env.get("ARG_V1_TIME_FIELD") ?? "openTime";
    const results = rawRows.slice(0, 100).map((row) => {
      const p = stringValue(readPath(row, periodField)), n = stringValue(readPath(row, numberField));
      const size = stringValue(readPath(row, sizeField))?.toUpperCase();
      const t = stringValue(readPath(row, timeField));
      return { period: p && p.length <= 80 ? p : null, number: n && n.length <= 32 ? n : null,
        bigSmall: size === "BIG" || size === "SMALL" ? size : null, drawTime: t && t.length <= 80 ? t : null };
    }).filter((row) => row.period !== null && row.number !== null);
    return Response.json({ source: (Deno.env.get("ARG_V1_SOURCE_LABEL") ?? "Configured results API").slice(0, 80), fetchedAt: new Date().toISOString(), results }, {
      status: 200, headers: { ...corsHeaders, "Cache-Control": "private, max-age=15" },
    });
  } catch (error) {
    const aborted = error instanceof DOMException && error.name === "AbortError";
    return Response.json({ error: aborted ? "upstream_timeout" : "upstream_fetch_failed" }, { status: 502, headers: corsHeaders });
  } finally { clearTimeout(timeout); }
});
