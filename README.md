# TRADE AR MONEY
Flutter Android app for educational community content.

## Customer support
The Community and Account pages include a support button opening the supplied Telegram invite:
https://t.me/+pmahyzLfcMA2ODZl

## Authentication
Supabase email/password login and sign-up are wired using the configured project URL and publishable key. End-to-end mobile auth still needs verification. Never place a service-role key in the app.

## Build APK
GitHub Actions runs on push to main or manually from Actions. Open the successful run and download the `TRADE-AR-MONEY-release-apk` artifact.

## Important status
Live game/colour-prediction feeds are not connected. The app does not fabricate live outcomes or guarantee predictions. Connect only an API you own or are explicitly authorized to use, with documented response formats. Historical data cannot guarantee future outcomes.

## Website
A responsive static website is in `website/index.html`. It uses the same Supabase project for published learning articles, public announcements, and verified history, and supports email/password sign-up, login, password reset, and logout. It does not include betting, real-money prediction, or an automatic live-results feed.

The GitHub Pages workflow is `.github/workflows/deploy-website.yml`. After Pages deployment succeeds, use the page URL shown in the workflow run. The repository owner may need to allow GitHub Pages in **Settings → Pages** if organization or repository policy prevents automatic enablement.

## Database setup
Run all SQL in `supabase/schema.sql` from the matching Supabase project's SQL Editor. Then follow `docs/SUPABASE_SETUP_HI.md` to assign the first admin account securely. The app and website are not production-ready until the database and account flows have been tested.
