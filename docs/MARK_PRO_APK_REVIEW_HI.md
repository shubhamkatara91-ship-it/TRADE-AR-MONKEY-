# Mark Pro APK review — findings and integration status

Review date: 29 October 2026  
Input artifact: user-uploaded `DOC-20261018-WA0007(1).apk` (56,569,523 bytes), inspected statically without signing in, sending requests to its servers, or extracting private credentials.

## What the APK appears to contain

Static strings and package metadata indicate this is a Flutter application with package namespace `com.mania.mark_pro`. The binary includes screens/services for:

- Dashboard, prediction tools, signals and custom platform links.
- Subscription/pass status and subscription history.
- Firebase Authentication integration.
- Backend subscription synchronization and payment-related flows.
- A split-screen signals feed and user-added gaming portal URLs.

These are observations from embedded strings and package metadata, not a guarantee that every feature works in the current production build.

## Server indicators found in the APK

The binary contains the base URL `https://9m.hop9.in/backend` and references to PHP routes under `https://hop9.in/pgg/` for subscription/payment flows. It also contains portal URLs such as `https://bdg9.cc/#/login` and `https://bdgwinp.com/#/login`.

**These are static indicators only.** I have not called these endpoints, verified ownership, tested authentication, confirmed that they are currently online, or established any documented public API contract. The presence of a URL inside an APK does not grant authorization to use its private backend. Payment routes are not being integrated into TRADE AR MONEY.

## What the APK does not prove

Strings such as “Real-time neural WinGo signals engine” and “live socket feeds” describe product claims or UI copy. They do not prove the model's implementation, its accuracy, the result source, the socket protocol, or that a third-party app is authorized to consume that data. Static inspection did not establish a documented, authorized Mark Pro results API.

The APK is compiled Flutter code, not the original editable Dart source. This review did not copy its code, assets, credentials, Firebase project secrets, or private backend logic.

## TRADE AR MONEY integration status

TRADE AR MONEY keeps its own original implementation and existing navigation: Tools, Home, Profile, Support, Premium, Log Out. ARG V1 remains the single tool exposed in Tools, with a one-minute UI timer and clearly labelled practice-only BIG/SMALL selections. It is not wired to Mark Pro or BDG live results.

The repository already has its own Supabase authentication, role-gated admin surface, result-history display, and an admin-authorized push-notification Edge Function foundation. Push notifications still require Firebase client setup, device token registration, and Edge Function deployment/configuration.

## Safe next integration path

For actual live results, use one of these authorized inputs:

1. Official provider API documentation and written permission to consume its result feed; or
2. A backend/API that the user owns or is explicitly authorized to integrate, including endpoint contract, authentication method, sample response and rate limits.

Then build a server-side adapter that validates response schema, round IDs, timestamps and settled status, stores source metadata, and exposes sanitized results. Credentials must remain in server-side secrets. Do not scrape a private endpoint, replay app sessions, bypass access controls, or label guessed outcomes as live predictions.

## Validation

- APK archive structure and Flutter/native-library contents inspected.
- URLs and feature indicators extracted from embedded strings.
- No live requests were sent to the discovered game/payment endpoints.
- This is static inspection only, not a security audit or runtime verification.
