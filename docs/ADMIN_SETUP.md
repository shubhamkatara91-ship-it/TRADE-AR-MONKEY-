# TRADE AR MONEY — Admin and backend setup

This checklist is for the repository owner. It does not require exposing a Supabase service-role key to the app.

## 1. Apply the database schema

1. Open the Supabase project `sjpgqjxllpjqwsllrzya`.
2. Open **SQL Editor**.
3. Review and run `supabase/schema.sql`.
4. Check the output for errors. If the Realtime publication does not exist, enable Realtime for `public.app_notifications` in the dashboard.

## 2. Create the first admin safely

1. Register a normal account in the app using the email you personally control.
2. In Supabase, open **Authentication → Users** and copy that user's UUID.
3. In SQL Editor, run the following query after replacing the placeholder with that exact UUID:

```sql
update public.profiles
set role = 'admin'
where id = 'REPLACE-WITH-YOUR-OWN-AUTH-USER-UUID'
  and role = 'user';
```

4. Confirm exactly one row was updated. Log out and log back in, then open **Profile → Open Admin Panel**.

Never promote an account based only on an email supplied by someone else. Never put the Supabase service-role key in Flutter, a public website, GitHub source, screenshots, or a chat message. The app's publish controls rely on database row-level security; hiding the admin button alone is not security.

## 3. Configure the ARG V1 results adapter

Follow [ARG V1 live feed setup](ARG_V1_LIVE_FEED_SETUP.md). Use only a documented read-only provider endpoint you own or are authorized to access. Set the URL, hostname allowlist, and response field mappings as Supabase Edge Function secrets. Do not use endpoints for bets, balances, deposits, withdrawals, or payment verification.

## 4. Deploy the Edge Function from GitHub Actions

1. Create a Supabase personal access token in the Supabase dashboard.
2. In GitHub, open **Settings → Secrets and variables → Actions** for this repository.
3. Add a repository secret named `SUPABASE_ACCESS_TOKEN` with that token as its value.
4. Open **Actions → Deploy ARG V1 read-only Edge Function → Run workflow**.
5. Confirm the run succeeds. A successful deployment only deploys the adapter; live data still requires the provider secrets from step 3.

Do not paste the token into issues, source files, the app, or chat. Revoke it if it is exposed.

## 5. GitHub Pages website

The workflow cannot create the Pages site if the repository's Actions token lacks that permission. Open **Settings → Pages**, select **GitHub Actions** as the build/deployment source, save, and then rerun the website deployment workflow.

## 6. Verify the backend before release

After applying the schema, run these read-only checks in the Supabase SQL Editor:

```sql
-- Confirm the expected application tables exist.
select table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in (
    'profiles', 'result_history', 'app_notifications',
    'learning_articles', 'device_push_tokens'
  )
order by table_name;

-- Confirm row-level security is enabled on all application tables.
select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname in (
    'profiles', 'result_history', 'app_notifications',
    'learning_articles', 'device_push_tokens'
  )
order by c.relname;

-- Inspect policy names and commands; review unexpected policies before launch.
select tablename, policyname, roles, cmd
from pg_policies
where schemaname = 'public'
  and tablename in (
    'profiles', 'result_history', 'app_notifications',
    'learning_articles', 'device_push_tokens'
  )
order by tablename, policyname;
```

Expected: all five tables are present and have `rls_enabled = true`. Review the policies against `supabase/schema.sql`; these queries inspect configuration but do not prove every user/admin scenario works. Complete the signup, ordinary-user denial, admin publish, and public-read tests using separate test accounts. Do not use production customer data for testing.

## 7. Release acceptance checklist

- [ ] Signup, email confirmation (if enabled), login, password reset, and logout tested.
- [ ] Regular user cannot publish articles, notifications, or result-history rows.
- [ ] Admin can publish and regular users can only read permitted public content.
- [ ] ARG V1 shows a clear unavailable state when provider secrets are absent.
- [ ] When configured, displayed history is compared against the authorized provider.
- [ ] Website deployment succeeds and public privacy/terms URLs are checked.
- [ ] APK is tested on a physical Android device before public distribution.
- [ ] Production signing and release versioning are configured before a public store release.

A green CI build is not proof of a production deployment or physical-device acceptance test.
