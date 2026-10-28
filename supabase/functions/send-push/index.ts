// Supabase Edge Function: send-push
// Required Edge Function secrets:
// FCM_SERVICE_ACCOUNT_JSON = Firebase service-account JSON (server-side only)
// SUPABASE_URL and SUPABASE_ANON_KEY are provided by Supabase.
// This endpoint accepts only an authenticated admin and never exposes FCM credentials.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5.9.6";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

async function accessToken(account: Record<string, string>): Promise<string> {
  const key = await importPKCS8(account.private_key, "RS256");
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  }).setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(account.client_email)
    .setSubject(account.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now).setExpirationTime(now + 3600).sign(key);

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const tokenBody = await tokenResponse.json();
  if (!tokenResponse.ok || !tokenBody.access_token) {
    throw new Error("Could not obtain Firebase OAuth access token");
  }
  return tokenBody.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return response({ error: "POST required" }, 405);

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return response({ error: "Sign-in required" }, 401);
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) return response({ error: "Supabase function secrets missing" }, 500);

  const db = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await db.auth.getUser();
  if (userError || !userData.user) return response({ error: "Valid sign-in required" }, 401);
  const { data: isAdmin, error: roleError } = await db.rpc("is_admin");
  if (roleError || isAdmin !== true) return response({ error: "Admin access required" }, 403);

  let input: { title?: string; body?: string };
  try { input = await req.json(); } catch { return response({ error: "Invalid JSON" }, 400); }
  const title = (input.title ?? "").trim().slice(0, 100);
  const body = (input.body ?? "").trim().slice(0, 500);
  if (!title || !body) return response({ error: "Title and body are required" }, 400);

  const serviceAccountRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!serviceAccountRaw) return response({ error: "Push is not configured: FCM service account secret is missing" }, 503);

  // Use the server-side service role only after the caller has been verified as an admin.
  // This is necessary because a user's JWT can only read that user's own device tokens.
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!serviceRoleKey) return response({ error: "Server-side Supabase service-role secret is missing" }, 500);
  const serverDb = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: rows, error: tokenError } = await serverDb
    .from("device_push_tokens").select("token").eq("enabled", true).limit(500);
  if (tokenError) return response({ error: "Could not load registered devices" }, 500);
  if (!rows?.length) return response({ sent: 0, failed: 0, message: "No registered device tokens yet" });

  try {
    const account = JSON.parse(serviceAccountRaw) as Record<string, string>;
    if (!account.project_id || !account.client_email || !account.private_key) {
      return response({ error: "Firebase service-account JSON is incomplete" }, 500);
    }
    const bearer = await accessToken(account);
    let sent = 0, failed = 0;
    for (const row of rows) {
      const result = await fetch(
        `https://fcm.googleapis.com/v1/projects/${encodeURIComponent(account.project_id)}/messages:send`,
        {
          method: "POST",
          headers: { Authorization: `Bearer ${bearer}`, "Content-Type": "application/json" },
          body: JSON.stringify({
            message: {
              token: row.token,
              notification: { title, body },
              data: { source: "trade_ar_money" },
              android: { priority: "HIGH", notification: { channel_id: "trade_ar_money_announcements" } },
            },
          }),
        },
      );
      if (result.ok) sent++;
      else failed++;
    }
    return response({ sent, failed, total: rows.length });
  } catch {
    return response({ error: "FCM send failed. Verify the server-side Firebase service-account secret." }, 502);
  }
});
