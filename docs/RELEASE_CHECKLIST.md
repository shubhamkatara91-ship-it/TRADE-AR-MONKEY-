# TRADE AR MONEY — deployment checklist

This repository currently builds an Android APK, but a successful compile is not the same as a production-verified release.

## 1. Apply the database schema
1. Open the Supabase project configured in `lib/main.dart`.
2. Open **SQL Editor**.
3. Paste and run the full contents of `supabase/schema.sql`.
4. In Supabase Authentication settings, configure email confirmation and the correct redirect URLs.
5. Create a test account and verify sign-up, email confirmation (if enabled), login, password reset and logout.

## 2. Admin role
The app must never let a user promote themselves. To assign the first admin, sign in with the intended admin account, then run a reviewed SQL statement in the Supabase SQL Editor using that account's UUID:
```sql
update public.profiles set role = 'admin' where id = 'REPLACE_WITH_ADMIN_USER_UUID';
```
Only a trusted project owner should run this statement. Do not expose the Supabase service-role key in the mobile app. An admin management UI still needs to be implemented and security-tested before production.

## 3. Results History / external data API
The app reads verified records from `public.result_history`. This repository does **not** currently include a third-party live results API provider, endpoint, credentials, or documented data license. Do not insert invented/sample outcomes and label them as live.
Before connecting a provider, confirm its API documentation, authorization, allowed use, response format, update frequency, and error/rate-limit behavior. Keep any secret API key on a trusted server/edge function, not in the Android app. Normalize verified records into `result_history`.

## 4. In-app messages vs push notifications
The app currently reads announcements from `public.app_notifications` when the Notifications screen is opened/refreshed. This is an in-app notification feed, not Android push notifications.
Real push notifications require a Firebase project, Android app registration, Firebase configuration file, Flutter messaging dependencies, notification permission handling, and a trusted server/edge function to send notifications. Keep service credentials server-side.

## 5. Telegram
The current community/support buttons open the configured Telegram invite URL. If community and support should be different destinations, replace the single URL with the two correct links and test both on a real device.

## 6. Release acceptance checks
- Install the release APK on a real Android device.
- Test on slow/offline network and with Supabase unavailable.
- Test signup, confirmation, login, wrong password, reset email, logout and expired sessions.
- Verify row-level security with normal and admin accounts.
- Verify results source, timestamps and failure behavior.
- Verify notifications and Telegram links.
- Add and publish Privacy Policy and Terms, confirm data collection/retention, and complete applicable Play Store policy checks.
- Test app on multiple screen sizes before distributing to clients.
