# TRADE AR MONEY — deployment and release checklist

A successful APK build confirms that the source compiles. It does **not** prove that the live Supabase project, website hosting, authentication, push delivery, or device behavior is production-ready.

## 1. Apply and verify the database schema
1. Open the Supabase project configured in `lib/main.dart`.
2. Open **SQL Editor** and run the complete current `supabase/schema.sql`.
3. Confirm the `profiles`, `learning_articles`, `app_notifications`, `result_history`, and `device_push_tokens` tables exist.
4. Confirm Realtime is enabled for `app_notifications`.
5. Configure Auth email confirmation and password-reset redirect URLs.
6. Test sign-up, confirmation, login, incorrect password, reset email, logout, and expired sessions.

## 2. Admin role and row-level security
The Android and website admin screens exist. They are only UI; Supabase Row Level Security (RLS) is the actual access-control boundary.

1. Create a normal account and confirm it cannot publish or modify records.
2. In Supabase Authentication, find the intended owner account's UUID.
3. As the trusted project owner, run the following in SQL Editor after replacing the placeholder:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'REPLACE_WITH_ADMIN_USER_UUID';
   ```
4. Sign out and back in; verify the owner can open the admin tools.
5. With a separate normal account, verify direct API inserts/updates/deletes are rejected by RLS.
6. Confirm users cannot update their own `profiles.role`; never add a public role-promotion endpoint.

## 3. Website deployment
The website source is in `website/`. The latest known Pages deployment attempt failed because the GitHub integration could not create the repository Pages site.

1. Repository owner: open [GitHub Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages).
2. Set **Build and deployment → Source** to **GitHub Actions** and save.
3. Rerun the website workflow from [Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions).
4. Open the resulting deployment URL and test mobile layout, signup/login/reset/logout, content loading, and admin access.
5. The website reads from the configured Supabase project; deployment alone does not apply the database schema.

## 4. Results history and external data
The app reads records from `public.result_history`; admins can manually add records. No documented/authorized live results API is connected.

- Do not insert invented/sample outcomes and label them as live.
- Before integrating a provider, confirm its API documentation, authorization, data license, response format, timestamps, update frequency, and rate limits.
- Keep any provider secret on a trusted server/Edge Function, never in the Android client.
- Verify every record's source and observation time before publication.

## 5. Notifications
- **In-app announcements:** implemented through `app_notifications`; the Android app and website subscribe to Realtime, and the app also supports refresh/feed loading.
- **Android lock-screen push:** not verified/live. It requires Firebase project configuration, Android client initialization and token registration, server-side FCM credentials, deployed Edge Function, and a physical-device test.
- Never commit Firebase service-account JSON, private keys, or Supabase service-role keys to the repository.

## 6. Telegram
The current support/community buttons use the configured Telegram invite URL. Open it on a real Android device and confirm it points to the intended community.

## 7. Legal and release acceptance
- Review and finalize `docs/PRIVACY_POLICY.md` and `docs/TERMS_OF_USE.md`; they are drafts and contain owner-contact placeholders.
- Publish the privacy policy at a stable HTTPS URL and provide a monitored support/privacy contact.
- Confirm actual data collection, retention, deletion process, providers, and applicable Indian data-protection and Play Store obligations.
- Install the release APK on a physical Android device and test normal/admin roles, poor/offline network, Supabase outage, navigation, and all links.
- Test multiple Android screen sizes and accessibility basics.
- Do not announce production readiness until the above tests have passed.

## Current known limitations
- Backend schema execution against the live Supabase project has not been confirmed from this repository workflow.
- Website Pages hosting needs one-time owner enablement.
- Firebase push is not end-to-end configured.
- There is no live results API.
