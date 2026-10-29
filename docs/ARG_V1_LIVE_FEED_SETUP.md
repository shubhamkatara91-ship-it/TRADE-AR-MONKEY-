# ARG V1 live result feed — deployment steps

This adapter is read-only. It does not create predictions, place bets, access balances, or use payment routes. Configure only a provider API that you own or are explicitly authorized to access. APK inspection alone did not establish authorization or a stable provider response schema.

## 1. Deploy the Edge Function

Install the Supabase CLI and authenticate to the project, then run from the repository root:

```sh
supabase login
supabase link --project-ref sjpgqjxllpjqwsllrzya
supabase functions deploy arg-v1-results --no-verify-jwt=false
```

The project config enables JWT verification. Do not disable it for this function.

## 2. Configure secrets

Use the exact endpoint and schema documented by your authorized provider. The host must match the URL hostname exactly.

```sh
supabase secrets set ARG_V1_RESULTS_URL='https://YOUR-AUTHORIZED-HOST.example/api/results'
supabase secrets set ARG_V1_ALLOWED_HOSTS='YOUR-AUTHORIZED-HOST.example'
supabase secrets set ARG_V1_ITEMS_PATH='data'
supabase secrets set ARG_V1_PERIOD_FIELD='issueNumber'
supabase secrets set ARG_V1_NUMBER_FIELD='number'
supabase secrets set ARG_V1_SIZE_FIELD='bigSmall'
supabase secrets set ARG_V1_TIME_FIELD='openTime'
supabase secrets set ARG_V1_SOURCE_LABEL='Authorized provider name'
```

If the provider requires a bearer token, configure it as a server-side secret:
```sh
supabase secrets set ARG_V1_RESULTS_API_KEY='YOUR_PROVIDER_API_TOKEN'
```
Never commit provider tokens or put them in Flutter build arguments.

## 3. Required response contract

The upstream response must be JSON containing an array at `ARG_V1_ITEMS_PATH`. Each row must expose the configured period and number fields. Size values are displayed only when exactly `BIG` or `SMALL`; other values remain unknown. Example contract only (not live data):

```json
{"data":[{"issueNumber":"20261029001","number":"7","bigSmall":"BIG","openTime":"2026-10-29T10:00:00Z"}]}
```

## 4. Verify

- Log in to TRADE AR MONEY and open Tools → ARG V1 → Refresh result history.
- A missing source should return `results_source_not_configured`; a schema mismatch should return `response_schema_mismatch`.
- Confirm displayed period/number/time against the provider's documented read-only output.
- Do not treat historical values as a prediction or guarantee.

## Known release limitation

The currently inspected BDG/Mark Pro APKs did not establish an authorized, documented ARG V1 endpoint and exact response contract. Therefore live provider configuration remains an owner-side prerequisite; the adapter intentionally fails closed until configured.
