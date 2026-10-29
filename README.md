# TRADE AR MONEY

Flutter Android app and responsive website for an educational community. This repository currently supports a practice simulator; it is not a live betting client.

## Verified build status

- **Latest confirmed successful Android APK:** [Build run 40873309005](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873309005), source commit `8e2b9279fbd4122b28a49e7ddf99282be4224393`.
- **Source validation:** [Run 40874274706](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40874274706) passed for the owner go-live guide update. Earlier source validation for the app startup fix also passed: [run 40873308995](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873308995).
- **Artifact:** `TRADE-AR-MONEY-release-apk-latest` ZIP, available under the successful APK run's **Artifacts** section. Extract it and install `TRADE-AR-MONEY.apk`.
- The APK was structurally inspected and its SHA-256 was verified as `6c4b982b22804cf45c2373339dcbedac3d7a06781fa3fdb16c9b559bcfe74eb4`. This checksum applies to the extracted APK inspected for that build.
- The APK includes a startup diagnostic screen and a 10-second Supabase initialization timeout. It has **not** been confirmed by physical-device acceptance testing or production-signing review.

## Features in source

- Email/password signup and login, password reset, logout, and clearer authentication errors.
- Learning articles, result-history display, announcements, support, and role-gated admin interfaces.
- Responsive browser website and separate admin page under `website/`.
- Supabase schema at `supabase/schema.sql`.
- Read-only ARG V1 results adapter with host allowlisting, timeouts, size/record validation, and schema checks.

Passing source validation or an Android build does not prove that authentication, admin controls, database policies, notifications, or the website work end-to-end in production.

## Required owner-side launch steps

### 1. Apply and verify Supabase schema

1. Open the [Supabase Dashboard](https://supabase.com/dashboard) and select the configured project.
2. Go to **SQL Editor → New query**.
3. Copy the current `supabase/schema.sql` from this repository, run it, and confirm that `profiles`, `result_history`, `app_notifications`, `learning_articles`, and `device_push_tokens` exist.
4. Create the intended owner account, then follow [Owner Go-Live Steps (Hindi)](docs/OWNER_GO_LIVE_HI.md) to grant that account admin access.
5. Test as both a normal user and the owner/admin.

### 2. Enable and deploy GitHub Pages

The previous deployment failed because the Pages site was not enabled and the integration could not create it.

1. Open [Repository Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages).
2. Under **Build and deployment → Source**, select **GitHub Actions** and save.
3. Open [GitHub Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions), select **Deploy TRADE AR MONEY website**, and run the workflow.
4. Verify the deployment succeeds, then test signup/login, article publishing, announcements, and admin authorization on the published site.

### 3. Configure notifications and live data only with authorization

- Android push notifications require a Firebase project, app configuration, secure server-side FCM credentials, device-token registration, and physical-device testing. See [notification setup](docs/NOTIFICATIONS_SETUP_HI.md).
- **No authorized live WinGo/BDG/Mark Pro results API is connected.** ARG V1's one-minute timer is a UI timer, not a live-result source or prediction engine.
- The results adapter is read-only. Configure it only with an endpoint you own or are explicitly authorized to access, using the exact documented response schema and server-side secrets. See [ARG V1 live-feed setup](docs/ARG_V1_LIVE_FEED_SETUP.md).
- No private provider code or server has been copied. Do not bypass authentication, reverse-engineer private endpoints, place real-money bets, or represent simulated choices as live predictions.

### 4. Review privacy, terms, and release quality

- [Privacy Policy draft](docs/PRIVACY_POLICY.md) and [Terms of Use draft](docs/TERMS_OF_USE.md) require a monitored owner/support contact, a check against actual data practices, and appropriate legal review before public release.
- Install the APK on a real Android device and test signup/login/reset/logout, offline/error handling, article and announcement reads, role restrictions, and app restart.
- Check release signing and the final APK checksum before distributing it.

## Security

Never commit a Supabase service-role key, Firebase service-account JSON, provider API token, password, or personal access token. Never put private server credentials in Flutter client code or website JavaScript. The Supabase publishable/anon key may be used client-side only with correctly configured Row Level Security.

## Product scope

TRADE AR MONEY is an educational community app with ARG V1 practice controls only, not a betting or gambling service. ARG V1 does not place wagers, access balances, move money, or guarantee predictions. Past outcomes do not determine future independent outcomes.

## Owner guides

- [Hindi owner go-live checklist](docs/OWNER_GO_LIVE_HI.md)
- [Admin and Supabase setup](docs/ADMIN_SETUP.md)
- [Authorized ARG V1 results-feed setup](docs/ARG_V1_LIVE_FEED_SETUP.md)
- [Mark Pro APK review (Hindi)](docs/MARK_PRO_APK_REVIEW_HI.md)
- [Mark Pro integration requirements (Hindi)](docs/MARK_PRO_INTEGRATION_HI.md)
