# TRADE AR MONEY — Owner Go-Live Steps (Hindi)

यह guide उन कामों के लिए है जिन्हें repository code अकेले पूरा नहीं कर सकता। Latest APK build (commit `777f039f01e9b46d0fdc84e725cc18d41a7c7317`) सफल है। Build सफल होना live backend/website या physical Android device पर end-to-end testing सफल होने का प्रमाण नहीं है।

## 1. Latest APK install करें
1. [Latest successful Android build](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40893565361) खोलें।
2. **Artifacts** में `TRADE-AR-MONEY-release-apk-latest` ZIP डाउनलोड करें।
3. ZIP extract करें और `TRADE-AR-MONEY.apk` install करें। Android unknown-app install permission पूछ सकता है।
4. यह CI-compiled build है; production signing और physical-device acceptance testing अभी certified नहीं हैं।

## 2. Supabase database setup
1. [Supabase Dashboard](https://supabase.com/dashboard) खोलें और app में configured project चुनें।
2. **SQL Editor → New query** खोलें।
3. [supabase/schema.sql](../supabase/schema.sql) की पूरी SQL copy करके SQL Editor में paste करें और Run करें।
4. Table Editor में `profiles`, `learning_articles`, `app_notifications`, `result_history`, `device_push_tokens` की मौजूदगी जाँचें।
5. SQL error आने पर उसे पहले समझें; बिना जाँच बार-बार schema न चलाएँ।

## 3. Create Account — signup पर OTP नहीं
1. Supabase Dashboard → **Authentication → Sign In / Providers → Email** खोलें (Dashboard UI में नाम थोड़ा अलग हो सकता है)।
2. **Confirm email** OFF करके Save करें। Server-side setting बदले बिना client code confirmation को bypass नहीं कर सकता।
3. App में Create Account पर email, username, mobile और password भरें।
4. Account बनने के बाद उसी email/password से Login करें। यदि Supabase session न लौटाए, पहले Confirm email setting दोबारा जाँचें।

## 4. Forgot Password — email OTP
Forgot Password flow Supabase Auth recovery email पर निर्भर है। Reset Password template में numeric OTP दिखना चाहिए, recovery link नहीं।

1. Supabase Dashboard → **Authentication → Email Templates → Reset Password** खोलें।
2. Template body में recovery code के लिए `{{ .Token }}` इस्तेमाल करें, उदाहरण:

```html
<h2>TRADE AR MONEY password reset</h2>
<p>आपका password reset OTP है:</p>
<p style="font-size:24px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
<p>यह code सीमित समय के लिए मान्य है। इसे किसी के साथ साझा न करें।</p>
```

3. Template save करें और email delivery/SMTP configuration जाँचें। Provider की sending limits लागू हो सकती हैं।
4. Test account पर **Forgot Password → Send OTP to Email → Verify OTP → Save New Password** पूरा करके जाँचें। Inbox और Spam दोनों देखें।
5. OTP कभी किसी दूसरे account/email पर न भेजें। Reset request का generic response account existence disclose होने से बचाने में मदद करता है।

## 5. अपने account को Admin बनाना
1. App में अपने email से account बनाएं। अगर Confirm email OFF है तो account direct बनाया जा सकता है।
2. Supabase → **Authentication → Users** में अपने user का UUID copy करें।
3. SQL Editor में नीचे की query चलाएँ और placeholder को अपने UUID से बदलें:

```sql
update public.profiles
set role = 'admin'
where id = 'PASTE_YOUR_AUTH_USER_UUID_HERE';
```

4. Affected rows 1 होनी चाहिए। App/website से logout करके फिर login करें।
5. किसी दूसरे user को admin role न दें, जब तक वह अधिकृत न हो।

## 6. Website publish करना — owner action आवश्यक
पहले deployment प्रयास में GitHub Pages site नहीं मिली और integration को Pages site बनाने की अनुमति नहीं थी। यह repository code मात्र से ठीक नहीं हो सकता।

1. [Repository Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages) खोलें।
2. **Build and deployment → Source** में **GitHub Actions** चुनकर Save करें। विकल्प न दिखे तो repository/organization policy या permission ठीक करनी होगी।
3. [GitHub Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions) में **Deploy TRADE AR MONEY website** workflow चलाएँ।
4. Workflow सफल होने पर deployment output में दिया URL खोलें और login, articles, announcements तथा admin permissions test करें।
5. नया workflow fail हो तो उसी run का error पढ़ें; website को live घोषित न करें जब तक सफल deployment और end-to-end test न हो।

## 7. Acceptance tests
- Normal user signup, login, password reset और logout कर पाए।
- Normal user admin content publish न कर पाए।
- Admin article/announcement publish करे और public feed में दिखे।
- Realtime announcement test हो।
- App restart और खराब internet पर error handling जाँची जाए।
- Privacy Policy/Terms में सही owner/support contact और legal review पूरा हो।

## अभी अलग से configure/test करना है
- Firebase push notifications: Firebase project, Android configuration, secure server-side FCM credentials, token registration और real-device testing।
- Live results: कोई authorized live-results API connected नहीं है। History में केवल verified/admin-entered records डालें।
- Privacy Policy/Terms: owner contact और legal review के बिना production-ready न मानें।

**Security:** Supabase publishable key client app में हो सकती है। Supabase service-role key, Firebase service-account JSON और private provider credentials कभी भी app code, website JavaScript या GitHub repository में commit न करें।
