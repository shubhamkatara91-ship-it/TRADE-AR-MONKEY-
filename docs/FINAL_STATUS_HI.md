# TRADE AR MONEY — वर्तमान स्थिति और release readiness

यह रिपोर्ट repository code और उपलब्ध GitHub Actions परिणामों पर आधारित है। यह वास्तविक Supabase backend या physical Android device पर परीक्षण का दावा नहीं करती।

## तैयार code
- Flutter Android app: email/password signup, login, password reset, logout.
- Learning articles, announcements, result-history feed, Telegram support link.
- Android admin screen और browser admin page: article/announcement publish तथा verified history record entry.
- Supabase schema with RLS policies and Realtime for in-app announcements.
- Browser website source in `website/`.
- Server-side FCM Edge Function foundation in `supabase/functions/send-push/index.ts`.
- Hindi setup instructions and release checklist.

## Android APK build
- GitHub Actions validation/build run `40810500955` **successful**; website HTML/JS checks and Flutter release APK compilation passed.
- Latest build run: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40810500955
- Latest artifact: `TRADE-AR-MONEY-release-apk-latest` (ZIP about 24.7 MB; compiled APK about 53.4 MB), artifact ID `12870113190`; it expires on 2026-11-12.
- Download: open the latest run, open **Artifacts**, download `TRADE-AR-MONEY-release-apk-latest` ZIP, then extract the APK.
- Build result confirms compilation only; it does not verify live Supabase configuration, hosting, push delivery, or physical-device behavior.

## अभी भी blocked / unverified
1. **Website deployment:** still requires owner-side GitHub Pages enablement. Open https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages and choose **Build and deployment → Source: GitHub Actions**; then rerun the deployment workflow.
2. **Supabase schema:** `supabase/schema.sql` is committed, but its execution against the live project and live RLS behavior have not been verified.
3. **First admin:** the intended owner account must be assigned `role='admin'` in Supabase SQL Editor.
4. **Push notifications:** Firebase Android setup, device-token registration, FCM secret, Edge Function deployment and physical-device delivery test are not complete.
5. **Live results:** no documented/authorized external live-results API is connected. No live results or guaranteed predictions are generated.
6. **Legal pages:** privacy policy and terms are drafts; owner contact details and legal review remain required before public launch.

## Required owner-side actions
1. Enable Pages once at https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages: choose **Build and deployment → Source → GitHub Actions**, save, then rerun the website workflow from https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions.
2. Run the full `supabase/schema.sql` in the matching Supabase project's SQL Editor.
3. Create/confirm the owner account, then assign its UUID the admin role using the reviewed SQL in [NOTIFICATIONS_SETUP_HI.md](NOTIFICATIONS_SETUP_HI.md).
4. Run signup/login/reset, admin-vs-user and direct RLS denial tests on the real backend.
5. For lock-screen notifications, configure Firebase and server-side secrets, deploy the Edge Function, and test on a physical Android device.
6. Add a monitored owner/support contact and review the privacy/terms drafts before publishing.

## Scope and safety
TRADE AR MONEY is an educational/community app. It does not include betting, gambling, real-money prediction payments, or a fabricated live-results feed. The repository code cannot itself grant the connected GitHub integration missing repository-settings permission or confirm external dashboard configuration; those steps are explicitly listed above rather than marked complete.
