# TRADE AR MONEY — Client Handover Pack

**स्थिति:** Client review / staging handover — production launch अभी conditional है.  
**Platform:** Android APK + responsive website source + Supabase backend schema.  
**उद्देश्य:** Market education, risk awareness, announcements, and manually verified history. यह betting या guaranteed-prediction product नहीं है.

## Client को अभी क्या दिखाया जा सकता है

- Android app: Home, Learn & Guides, Results History, Alerts, Community/Telegram, Account.
- Email/password signup, login, password reset, and logout UI integrated with Supabase Auth.
- Admin UI for publishing learning articles, announcements, and manually verified history.
- Website: public learning content, announcements, history, account UI, and separate admin page.
- Supabase SQL schema with Row Level Security policies and admin-role checks.
- GitHub Actions workflow that validates website HTML/inline JavaScript and compiles an Android release APK.

## Production launch gate — ये items अभी sign-off नहीं हुए हैं

| Item | Current status | Required proof |
|---|---|---|
| Android build | CI build previously succeeded; newest run must finish | Successful latest run and downloadable APK artifact |
| Supabase schema | SQL file committed; live project execution not independently verified | Run `supabase/schema.sql` in the correct project's SQL Editor; verify tables and policies |
| Admin account | Owner must grant the role to the intended account | Test admin publish and ordinary-user denial |
| Website hosting | GitHub Pages needs owner-side enablement | Set Pages source to GitHub Actions and verify deployed URL |
| Authentication | Client code is integrated; end-to-end live test pending | Test signup, email confirmation, login, reset, logout |
| Push notifications | In-app announcements implemented; lock-screen push not verified | Firebase setup, device-token registration, deployed function, physical-device test |
| Live results | No live provider connected | Only integrate an authorized documented API; never present manual records as live |
| Privacy/terms | Drafts require owner contact and review | Complete monitored contact details, review, publish stable HTTPS policy |
| Device QA | No full physical-device acceptance evidence | Install APK and test navigation, poor network, auth, and account roles |

## Owner setup steps

1. Open the [Supabase project](https://supabase.com/dashboard/project/sjpgqjxllpjqwsllrzya) and go to **SQL Editor**.
2. Run the complete current `supabase/schema.sql` from this repository.
3. Register the intended owner account through the app, then find that account's UUID in **Authentication → Users**.
4. As the trusted project owner, promote only that UUID in SQL Editor:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'REPLACE_WITH_OWNER_AUTH_USER_UUID';
   ```
5. Open [GitHub Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages), choose **Build and deployment → Source: GitHub Actions**, and save.
6. Run the deployment workflow from [GitHub Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions).
7. Download the APK artifact from the successful validation workflow, extract the ZIP, and install the APK on a test Android phone.
8. Complete every launch-gate test above before calling the service production-ready.

## Security requirements

- The publishable Supabase client key may be present in the client app; it is not a service-role secret.
- Never put Supabase service-role keys, Firebase service-account JSON, or other private server credentials in the APK, website, or public repository.
- Keep database Row Level Security enabled. Test write restrictions using a non-admin account.
- Do not collect payments or add betting/real-money prediction functionality as part of this educational build without a separate legal and compliance review.

## Client acceptance sign-off

The client/owner should confirm:
- [ ] Branding, app name, Telegram destination, and support contact are correct.
- [ ] Live Supabase schema and Auth settings have been tested.
- [ ] Admin and ordinary-user permissions have been tested separately.
- [ ] Website is publicly accessible over HTTPS and all links work.
- [ ] APK is installed and tested on a physical Android device.
- [ ] Privacy policy and terms are finalized and published.
- [ ] No feature is described as live unless it has been verified live.
