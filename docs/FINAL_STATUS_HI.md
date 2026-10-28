# TRADE AR MONEY — Final readiness checklist (Hindi)

यह फाइल repository में मौजूद code और उपलब्ध GitHub Actions परिणामों की स्थिति बताती है। इसे वास्तविक backend/device test का विकल्प न समझें।

## जो code मौजूद है
- Android Flutter client और successful release build.
- Email/password signup, login, password reset, logout.
- Learning articles, announcements, result-history list.
- Role-based admin UI for articles, announcements, and manually verified history.
- Browser website और admin page.
- Supabase SQL schema with Row Level Security policies.
- Admin-only server-side FCM Edge Function foundation.

## जो अभी verified/live नहीं है
1. **Website public deployment:** GitHub Actions run #11 failed at `actions/configure-pages` with `Resource not accessible by integration`. The GitHub integration does not have permission to create the repository's Pages site.
2. **Supabase:** the SQL file is committed but we have not confirmed it was executed against the real project or smoke-tested.
3. **First admin:** one intended account must be assigned admin role through the Supabase SQL Editor; never expose an admin-role update endpoint.
4. **Android push:** Firebase Android setup, token registration in the app, and Edge Function secrets are not yet configured end-to-end.
5. **Live results:** no documented/authorized results API is connected. The app must not fabricate a live feed.

## Required owner-side actions to reach production
1. Open [GitHub Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages), choose **GitHub Actions** as the deployment source, save, then rerun the website deployment workflow.
2. Run the complete `supabase/schema.sql` in the matching Supabase project's SQL Editor.
3. Set up the first admin as described in [NOTIFICATIONS_SETUP_HI.md](NOTIFICATIONS_SETUP_HI.md).
4. Perform real signup/login/admin-vs-user/RLS tests on Android and website.
5. If lock-screen push is required, configure Firebase and secrets following the notification guide, then test on a physical Android device.

These last items require access to the owner's GitHub repository settings, Supabase dashboard, and Firebase project. They cannot be truthfully marked complete by changing repository source code alone.
