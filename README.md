# TRADE AR MONEY
Flutter Android app and responsive website for an educational community.

## Customer support
The app includes a **Share with friends** action in the app bar, Home and Community screens. Android opens the system share sheet; the invite currently points to this public GitHub repository because GitHub Pages hosting is not enabled yet. The website has Share buttons that use the current page URL and fall back to copying the invite text when supported. Sharing code is committed, but the newly triggered APK build and website hosting are not yet confirmed successful.

The app includes a support button opening the supplied Telegram invite:
https://t.me/+pmahyzLfcMA2ODZl

## Current verified status
- Latest source validation passed in GitHub Actions run `40820147307` (HTML/inline JavaScript and schema safety/idempotency checks): https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40820147307
- Share-with-friends changes are committed. The APK build including these buttons succeeded in run `40820133635`: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40820133635.
- A follow-up build is packaging the APK with a build-info file and SHA-256 checksum in run `40821037141`: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40821037141. Wait for it to finish before using that bundle; the prior successful build artifact remains available as a fallback.
- Flutter app source includes email/password signup, login, password reset, logout, learning articles, result-history display, announcements, and a role-gated admin interface.
- A responsive browser website and separate admin page are present under `website/`.
- Supabase schema and an admin-only FCM Edge Function are in the repository, but deployment/configuration of the backend and Firebase have not been confirmed.
- Website deployment is currently blocked: GitHub Actions reports `Resource not accessible by integration` while trying to create the GitHub Pages site. The connected GitHub integration cannot change that repository-level setting.
- No authorized live results API is connected. The app must not show invented outcomes as live results.

## Download the Android APK
Open the [latest successful build with Share buttons](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40820133635), scroll to **Artifacts**, and download the APK bundle. The follow-up packaging build is tracked [here](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40821037141); once successful, use its `TRADE-AR-MONEY-release-apk-latest` artifact, which includes `TRADE-AR-MONEY.apk`, `BUILD_INFO.txt`, and `SHA256SUMS.txt`.

Extract the ZIP, then install the APK on Android. The checksum can be used to verify the file was downloaded intact. This confirms compilation only; it does not prove production signing or end-to-end device/backend testing. Workflow artifacts expire.

## Client handover

The client handover pack is available at [docs/CLIENT_HANDOFF_HI.md](docs/CLIENT_HANDOFF_HI.md), with release gates and owner-side setup steps.

## Website deployment blocker
Latest attempt:
https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40748848366

A repository owner must enable GitHub Pages once in **Settings → Pages → Build and deployment → Source: GitHub Actions**:
https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages

After that, rerun the **Deploy TRADE AR MONEY website** workflow from Actions. The current GitHub integration cannot grant itself the repository permission needed to create the Pages site.

## Apply the Supabase schema
Run the full current `supabase/schema.sql` in the SQL Editor of the Supabase project configured in `lib/main.dart`. Then follow:
- [Hindi setup and notification guide](docs/NOTIFICATIONS_SETUP_HI.md)
- [Supabase schema](supabase/schema.sql)

The schema has not been verified as applied to the live project. Create the first admin only by updating the intended account's `profiles.role` in the Supabase SQL Editor, then test both admin and normal-user access.

## Notifications
In-app announcements use Supabase Realtime only after the schema is applied and `app_notifications` is enabled for Realtime. Android push/lock-screen notifications are not live: Firebase project configuration, client token registration, and server-side FCM secrets are still required. Never commit Firebase service-account JSON or Supabase service-role keys to this repository.

## Data and safety
This project is configured as an educational community, not a betting/gambling app. It does not include a live WinGo/BDG feed, real-money prediction, or guaranteed signals. Connect only a documented API you own or are authorized to use. Historical outcomes cannot guarantee future results.
