# TRADE AR MONEY — Owner Go-Live Steps (Hindi)

यह guide उन कामों के लिए है जिन्हें repository code अकेले पूरा नहीं कर सकता। नवीनतम APK build (commit `8e2b9279`) सफल है और startup backend timeout diagnostic शामिल है; इसका मतलब live backend/website का end-to-end test या physical-device test सफल होना नहीं है।

## 1. APK install करें
1. [Latest successful Android build](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions/runs/40873309005) खोलें।
2. नीचे **Artifacts** में `TRADE-AR-MONEY-release-apk-latest` ZIP डाउनलोड करें (artifact expiry 27 January 2027)।
3. ZIP extract करें और APK को अपने Android phone पर install करें।
4. केवल official repo के artifact का उपयोग करें। Android unknown-app install permission पूछ सकता है।

## 2. Supabase backend लागू करें
1. [Supabase Dashboard](https://supabase.com/dashboard) खोलें और वही project चुनें जो app में configured है।
2. **SQL Editor → New query** खोलें।
3. GitHub की [supabase/schema.sql](../supabase/schema.sql) file खोलें, पूरी SQL copy करके SQL Editor में paste करें और **Run** करें।
4. Table Editor में `profiles`, `learning_articles`, `app_notifications`, `result_history`, `device_push_tokens` दिखने चाहिए।
5. अगर SQL error आए, error text को ठीक-ठीक देखें; बिना जाँच के बार-बार पूरा schema न चलाएँ।

## 3. Forgot Password के email OTP को configure करें

App का Forgot Password flow Supabase Auth के recovery email पर निर्भर करता है। OTP field तभी काम करेगी जब recovery email template numeric/code OTP भेजे; default recovery-link template को OTP समझकर न डालें।

1. Supabase Dashboard → **Authentication → Email Templates → Reset Password** खोलें।
2. Reset Password email body में recovery code के लिए Supabase template variable `{{ .Token }}` का उपयोग करें। उदाहरण:

```html
<h2>TRADE AR MONEY password reset</h2>
<p>आपका password reset OTP है:</p>
<p style="font-size:24px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
<p>यह code सीमित समय के लिए मान्य है। इसे किसी के साथ साझा न करें।</p>
```

3. Template save करें। Authentication email delivery/SMTP configuration भी जाँचें; custom SMTP न होने पर provider की sending limits लागू हो सकती हैं।
4. पहले से बने test account पर **Forgot Password → Send OTP to Email → Verify OTP → Save New Password** पूरा करके जाँचें। Inbox के साथ Spam folder भी देखें।
5. OTP किसी अन्य account/email पर न भेजें। Reset request पर app generic message दिखाता है ताकि account existence अनावश्यक रूप से disclose न हो।

## 4. अपना account Admin बनाएं
1. App या website से अपने ही email पर account बनाएं और email confirmation पूरा करें।
2. Supabase → **Authentication → Users** में अपने account का UUID copy करें।
3. SQL Editor में यह query चलाएँ; placeholder को अपने UUID से बदलें:

```sql
update public.profiles
set role = 'admin'
where id = 'PASTE_YOUR_AUTH_USER_UUID_HERE';
```

4. Query के बाद affected rows 1 होनी चाहिए। App/website से logout करके फिर login करें।
5. किसी दूसरे व्यक्ति को admin role न दें, जब तक आप उस व्यक्ति को अधिकृत न करते हों।

## 5. Website publish करें — जरूरी manual step
पिछला deployment run GitHub Pages site को पढ़/बना नहीं पाया: GitHub ने `Get Pages site: Not Found` और `Create Pages site: Resource not accessible by integration` लौटाया। Workflow code repository permissions से Pages को पहली बार enable नहीं कर सकता।

1. Repository owner अपने account से [Repository Pages settings](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/settings/pages) खोलें।
2. **Build and deployment → Source** में **GitHub Actions** चुनकर Save करें। अगर विकल्प उपलब्ध न हो, repository/organization की Pages policy या access permission owner को ठीक करनी होगी।
3. [GitHub Actions](https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/actions) खोलें, **Deploy TRADE AR MONEY website** workflow चुनें और **Run workflow** करें।
4. Workflow सफल होने पर deployment output में दिया गया URL खोलें। सिर्फ URL खुलना काफी नहीं—login, published articles, announcements और admin access test करें।
5. यदि deployment फिर fail हो, उस नए run का error पढ़ें; live website को सफल घोषित न करें।

## 6. जरूरी acceptance tests
- Normal user login/signup/reset/logout कर पाए।
- Normal user admin content publish न कर पाए।
- Admin article/announcement publish करे और public feed में दिखे।
- Realtime announcement test हो।
- App restart और खराब internet पर error handling जाँचें।
- Privacy Policy/Terms में सही owner/support contact भरें और public launch से पहले review करें।

## अभी शामिल नहीं / अलग से configure करना होगा
- Firebase push notification: Firebase project, Android configuration, secure server-side FCM credentials, token registration और real-device testing।
- Live results: कोई authorized live-results API अभी connected नहीं है। इस कारण history में केवल admin द्वारा दर्ज verified records ही डालें।
- Privacy Policy/Terms: drafts हैं; owner contact और legal review के बिना production-ready न मानें।

**Security:** Supabase publishable key client app में हो सकती है। Supabase service-role key, Firebase service-account JSON और private provider credentials कभी भी app code, website JavaScript या GitHub repo में commit न करें।
