# TRADE AR MONEY

Flutter Android app and responsive website for an educational community.

## Current verified status

- **Latest successful Android APK build:** [GitHub Actions run 40824384462](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40824384462).
- **APK artifact:** `TRADE-AR-MONEY-release-apk-latest` (ZIP bundle, about 24.7 MB; artifact expires 27 January 2027).
- **Latest source validation:** [GitHub Actions run 40824713008](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40824713008).
- The current Tools section exposes ARG V1; its one-minute timer starts automatically. BIG/SMALL choices are practice selections, not verified predictions.
- Flutter source includes email/password signup, login, password reset, logout, learning articles, result-history display, announcements, support, and role-gated admin features.
- A responsive browser website and separate admin page are present under `website/`.
- Supabase schema is in `supabase/schema.sql`; it must be applied and tested in the intended Supabase project before launch.
- **Website deployment is not yet verified as live.** Repository owner must first enable GitHub Pages as described below.

## Download the Android APK

1. Open the [latest successful Android build](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40824384462).
2. Under **Artifacts**, download `TRADE-AR-MONEY-release-apk-latest`.
3. Extract the ZIP and install the APK on Android.

This is a CI-compiled APK. A successful build does not certify production signing, installation on every device, or end-to-end backend testing. Use the artifact's checksum file if included to verify download integrity. Workflow artifacts expire.

## Website deployment

The deployment workflow is `.github/workflows/deploy-website.yml`. The earlier deployment failed because GitHub Pages was not enabled and the integration could not create the Pages site due to repository permissions. The workflow no longer attempts to enable Pages automatically.

1. The repository owner opens [Repository Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages).
2. Under **Build and deployment → Source**, select **GitHub Actions** and save. If this setting is unavailable, the owner must resolve repository/organization policy or permission restrictions.
3. Open [GitHub Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions), select **Deploy TRADE AR MONEY website**, and click **Run workflow**.
4. Verify the deployment run succeeds, then test signup/login, published articles, announcements, and admin authorization on the live site. A page loading successfully is not enough to establish that the backend is configured correctly.

## Apply the Supabase schema

1. Open the [Supabase Dashboard](https://supabase.com/dashboard) and select the project configured in the app.
2. Open **SQL Editor → New query**.
3. Copy the complete current `supabase/schema.sql` into the editor and run it.
4. Verify that the expected tables exist and test access as both a normal user and an admin.
5. Follow [Hindi owner go-live steps](docs/OWNER_GO_LIVE_HI.md) and [notification setup guide](docs/NOTIFICATIONS_SETUP_HI.md).

Do not promote an account to admin unless it is the intended owner account. Never place a Supabase service-role key, Firebase service-account JSON, or other private server credential in the app, website JavaScript, or repository.

## Live results and notifications

- **No authorized live WinGo/BDG results API is connected.** Only use results from an authorized provider with documented API access. Do not label manually entered history or practice choices as live results.
- ARG V1's automatic one-minute timer is a UI timer; it does not fetch real results or make guaranteed predictions.
- In-app announcements depend on the Supabase schema and Realtime configuration being applied.
- Android push notifications require Firebase setup, device-token registration, secure server-side FCM credentials, and real-device testing.

## Privacy and terms

The [Privacy Policy](docs/PRIVACY_POLICY.md) and [Terms of Use](docs/TERMS_OF_USE.md) are drafts. Add a monitored owner/support contact, verify actual data practices, and obtain appropriate legal review before public release.

## Security and product scope

TRADE AR MONEY is intended as an educational community, not a betting or gambling service. It does not accept wagers or promise prediction accuracy. Past results do not guarantee future outcomes. Connect only services and APIs that the owner is authorized to use.
