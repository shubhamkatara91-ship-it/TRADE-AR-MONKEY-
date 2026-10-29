# TRADE AR MONEY

Flutter Android app and responsive website for an educational community.

## Current verified status

- **Latest confirmed successful Android APK build:** [GitHub Actions run 40873309005](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873309005), commit `8e2b9279fbd4122b28a49e7ddf99282be4224393`. It includes startup failure diagnostics and a 10-second backend initialization timeout.
- **Current ARG V1 pattern-analysis APK build:** [run 40870135212](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40870135212), commit `907987fd55175ba2e79293d77e5043aa731583b1`. It adds recent BIG/SMALL counts and streak/sample-lean display. Do not call the new artifact available until this run succeeds.
- **Latest confirmed source validation for pattern analysis:** [run 40870135224](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40870135224). Validation is source-level, not a full Android device test.
- **APK artifact:** `TRADE-AR-MONEY-release-apk-latest` ZIP; download from the successful run's **Artifacts** section. Build artifacts expire; use the newest successful run.
- ARG V1's one-minute timer and practice outcomes are not verified predictions. The recent pattern panel summarizes only records already loaded by the configured result feed.
- Flutter source includes email/password signup, login, password reset, logout, learning articles, result-history display, announcements, support, and role-gated admin features.
- A responsive browser website and separate admin page are present under `website/`.
- Supabase schema is in `supabase/schema.sql`; it must be applied and tested in the intended Supabase project before launch.
- **Website deployment is not yet verified as live.** Repository owner must first enable GitHub Pages as described below.
- **Login validation fix:** Existing accounts are no longer blocked by the app's 8-character signup-password rule; new signups still require at least 8 characters. Website login now displays clearer messages for common authentication failures. This is code-level validation only; end-to-end login still requires testing against the configured Supabase project.
- **Latest APK build with startup diagnostics:** [run 40873309005](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873309005). This run succeeded and its Artifacts section contains `TRADE-AR-MONEY-release-apk-latest`. The build is not yet verified on a physical phone.

## Download the Android APK

1. Open the [latest successful APK run](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873309005).
2. Under **Artifacts**, download `TRADE-AR-MONEY-release-apk-latest`.
3. Extract the ZIP and install `TRADE-AR-MONEY.apk` on Android.

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

## Mark Pro / official provider integration

The uploaded APK has now been statically inspected; see [Mark Pro APK review (Hindi)](docs/MARK_PRO_APK_REVIEW_HI.md) for verified embedded strings and limitations. Read [Hindi integration requirements](docs/MARK_PRO_INTEGRATION_HI.md) before connecting any external WinGo provider. No public, authorized Mark Pro API documentation was found in the reviewed search results, so no private Mark Pro code or server has been copied and no live connection is claimed. Integration requires official documentation, written permission, and server-side credentials.

## Live results and notifications

- **No authorized live WinGo/BDG results API is connected.** Only use results from an authorized provider with documented API access. Do not label manually entered history or practice choices as live results.
- ARG V1's automatic one-minute timer is a UI timer; it does not fetch real results or make guaranteed predictions.
- In-app announcements depend on the Supabase schema and Realtime configuration being applied.
- Android push notifications require Firebase setup, device-token registration, secure server-side FCM credentials, and real-device testing.

## Privacy and terms

The [Privacy Policy](docs/PRIVACY_POLICY.md) and [Terms of Use](docs/TERMS_OF_USE.md) are drafts. Add a monitored owner/support contact, verify actual data practices, and obtain appropriate legal review before public release.

## Security and product scope

TRADE AR MONEY is intended as an educational community, not a betting or gambling service. It does not accept wagers or promise prediction accuracy. Past results do not guarantee future outcomes. Connect only services and APIs that the owner is authorized to use.
## Owner setup guides

- [Admin, Supabase, and deployment checklist](docs/ADMIN_SETUP.md)
- [ARG V1 authorized read-only results feed setup](docs/ARG_V1_LIVE_FEED_SETUP.md)

## Practice stake progression (simulator only)

The Auto Bet screen is a manual-outcome simulator. It does not read a live game result, predict the next result, place bets, or move money. The displayed win/loss calculation assumes an illustrative 1:1 payout and is not a provider payout rule.

| Capital reference | Level 1 | Level 2 | Level 3 | Level 4 | Level 5 | Total five-level exposure |
|---:|---:|---:|---:|---:|---:|---:|
| ₹300 | ₹5 | ₹12 | ₹29 | ₹70 | ₹168 | ₹284 |
| ₹500 | ₹10 | ₹23 | ₹53 | ₹122 | ₹281 | ₹489 |
| ₹1,000 | ₹20 | ₹46 | ₹106 | ₹244 | ₹562 | ₹998 |
| ₹2,000 | ₹40 | ₹92 | ₹212 | ₹488 | ₹1,123 | ₹1,955 |

A recorded practice win resets to Level 1; a loss advances one level. A loss at Level 5 stops the session. The simulator stops when the configured practice profit target is reached or the remaining reference capital cannot cover the next stake. These mechanics are educational bookkeeping only and do not establish a profitable strategy or predict outcomes.
