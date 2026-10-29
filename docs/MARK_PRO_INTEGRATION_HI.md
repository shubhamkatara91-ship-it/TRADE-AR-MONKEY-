# Mark Pro / WinGo provider integration — Hindi

## स्थिति

TRADE AR MONEY में ARG V1 का 1-minute timer और practice-only BIG/SMALL UI मौजूद है। यह अपने-आप Mark Pro का live result, algorithm, server या prediction source नहीं पढ़ता। इस repository में Mark Pro का authorized API endpoint/schema उपलब्ध नहीं है, इसलिए कोई live connection अभी configured नहीं है।

## क्या हम सीधे Mark Pro का private code/server कॉपी कर सकते हैं?

नहीं। Private app code, credentials, undocumented endpoints या server access को बिना लिखित अनुमति के extract/copy करना उचित नहीं है। App की UI देखकर backend protocol या prediction algorithm का अनुमान लगाना भी reliable integration नहीं है। हम provider द्वारा officially supplied API/docs और authorized credentials के साथ integration कर सकते हैं।

## Provider से क्या चाहिए

Provider/owner से ये चीजें लें:

1. Official API documentation और base URL.
2. Written permission that this app may consume the API.
3. Authentication method (test credential first; production secret server-side only).
4. Sample successful response JSON for current round and settled result.
5. Round identifier, start/end time, timezone, result finality/status, rate limits and error codes.
6. Test endpoint or sandbox, plus rules for storing and redistributing the results.

**Never commit API tokens, cookies, session headers, private keys, Firebase service-account JSON, or Supabase service-role keys.** Store provider credentials in Supabase Edge Function secrets, not in Flutter/browser code.

## Integration contract (after official docs are supplied)

Create a server-side provider adapter that:
- fetches only documented endpoints;
- validates the HTTP status, JSON schema, round ID and timestamp;
- distinguishes pending, settled, unavailable and stale results;
- stores verified provider responses with source and fetched-at timestamp;
- does not generate or label a guessed number as a live result;
- rate-limits requests, applies timeouts, and avoids logging credentials;
- exposes only sanitized result data to the signed-in client.

Expected normalized response (illustrative only; not a real provider response):

```json
{
  "provider": "official-provider-name",
  "round_id": "provider-issued-round-id",
  "period_seconds": 60,
  "status": "pending",
  "result": null,
  "source_timestamp": "2026-01-01T00:00:00Z"
}
```

The example above is a proposed internal schema, not an actual Mark Pro endpoint or response. Map real fields only after checking the official documentation.

## Go-live checklist

- [ ] Written provider permission and official API docs received.
- [ ] Provider contract and sample JSON reviewed.
- [ ] Edge Function adapter implemented against documented fields.
- [ ] Secret stored in Supabase Edge Function secrets.
- [ ] Unit tests cover invalid JSON, timeout, HTTP errors, stale rounds and duplicate results.
- [ ] Admin can inspect source, timestamp and errors.
- [ ] UI clearly distinguishes official settled results from practice UI.
- [ ] Production deployment and a real-device test completed.

Until these prerequisites are met, keep ARG V1 labelled **practice only**. A running 60-second timer is not evidence of live provider data or prediction accuracy.
