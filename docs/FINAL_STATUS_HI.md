# TRADE AR MONEY — वर्तमान स्थिति और release readiness

यह रिपोर्ट repository code और उपलब्ध GitHub Actions परिणामों पर आधारित है। यह वास्तविक Supabase backend या physical Android device पर परीक्षण का दावा नहीं करती।

## तैयार code
- Flutter Android app: email/password signup, login, password reset, logout.
- Learning articles, announcements, result-history feed, Telegram support link.
- ARG V1 Practice Mode: interactive 1-minute local timer, working BIG/SMALL selection controls, and local practice history. This is not a live signal/prediction feed.
- Share with friends buttons in the Android app bar, Home and Community; website Share buttons use native browser sharing with clipboard/prompt fallback.
- Android admin screen और browser admin page: article/announcement publish तथा manually entered history record entry; records app द्वारा independently verify नहीं होते।
- Supabase schema with RLS policies and Realtime for in-app announcements.
- Browser website source in `website/`.
- Server-side FCM Edge Function foundation in `supabase/functions/send-push/index.ts`.
- Hindi setup instructions and release checklist.

## Mark Pro APK inspection and ARG V1
- Static inspection of the user-supplied APK confirms it is a Flutter app branded Mark Pro and contains WinGo/AI signal, prediction-tool, membership, and payment-related modules.
- The APK contains third-party server/payment addresses, but an address embedded in an APK is not API documentation or proof of permission. No such private endpoints or credentials were copied into TRADE AR MONEY.
- TRADE AR MONEY uses its own interface and original code. The ARG V1 screen currently provides working practice controls only; live results require an authorized, documented API and confirmed response schema.

## Automated checks and Android APK
- Latest source validation run `40821861340` **successful** after adding the ARG V1 Practice Mode screen: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40821861340
- Share-with-friends changes committed. Latest APK workflow run `40821861347` includes ARG V1 Practice Mode plus the Android Internet permission, build-info file, and SHA-256 checksum packaging: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40821861347. At last check, release APK compilation was still running; wait for a successful conclusion and artifact before distributing it.
- Last known earlier successful Android APK compilation run: `40810500955`: https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40810500955. That artifact predates the latest Share and network-permission changes.
- Validation and APK compilation are now separate workflows to avoid rebuilding the APK for schema/docs-only changes.
- Earlier artifact: `TRADE-AR-MONEY-release-apk-latest` (ZIP about 24.7 MB; compiled APK about 53.4 MB), artifact ID `12870113190`; it expires on 2026-11-12. It is not the latest source build.
- Download: open a **successful** run, open **Artifacts**, download `TRADE-AR-MONEY-release-apk-latest` ZIP, then extract the APK. The newest workflow also packages `BUILD_INFO.txt` and `SHA256SUMS.txt`.
- Build result confirms compilation only; it does not verify live Supabase configuration, hosting, push delivery, or physical-device behavior.

## Share feature note
- Android share message currently links to the public GitHub repository because the website has not yet been published. Once GitHub Pages is enabled and a stable site URL is verified, update the invite to that URL.
- Website share action shares the current page URL; this cannot be fully tested until the site is hosted.

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
