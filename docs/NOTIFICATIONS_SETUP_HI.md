# Backend और Notifications Setup — हिंदी

## अभी code में क्या है
- Supabase Auth: email/password signup, login, password reset और logout.
- RLS-सुरक्षित profiles/roles, learning articles, announcements और manually verified result history.
- Announcements के लिए Supabase Realtime subscription: नया announcement insert होने पर app feed refresh और app खुला होने पर banner दिखाती है.
- Website के लिए published learning articles अब anon और authenticated दोनों पढ़ सकते हैं.
- Android lock-screen/push notification अभी enabled नहीं है. इसके लिए Firebase project, Android app registration, Firebase config files और FCM credentials जरूरी हैं.

## A. Supabase backend लागू करें
1. Supabase Dashboard में सही project खोलें.
2. SQL Editor में `supabase/schema.sql` की पूरी current file चलाएँ.
3. Table Editor में `profiles`, `learning_articles`, `app_notifications`, `result_history` जाँचें.
4. Database → Publications/Realtime में `app_notifications` table publication में शामिल है, यह verify करें. SQL file इसे जोड़ने की कोशिश करती है; अगर permission/error आए तो dashboard से enable करें.
5. Authentication → URL Configuration में app के email confirmation/password reset के लिए सही redirect URLs set करें.

## B. पहला admin account
1. Android app में अपना account बनाकर email confirmation पूरा करें.
2. Authentication → Users से उसी account का UUID copy करें.
3. SQL Editor में केवल अपने account के लिए चलाएँ:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'YOUR_AUTH_USER_UUID';
   ```
4. App में logout/login करें. Account tab में Open Admin Panel दिखना चाहिए.
5. किसी user को admin role देने के लिए public app endpoint या client-side update न बनाएँ.

## C. Notification test
1. ऊपर का schema run होने के बाद app में admin account से login करें.
2. Account → Open Admin Panel → Publish announcement में test message डालें.
3. दूसरी device या app session में Alerts tab खोलें. New announcement database से दिखना चाहिए; app foreground में हो तो नया announcement snackbar भी आना चाहिए.
4. यदि live update नहीं आती, Supabase Realtime publication में `app_notifications` enabled है या नहीं जाँचें; Alerts screen को pull-to-refresh भी करें.
5. `audience='all'` announcements सार्वजनिक हैं. उसमें private/personal information न डालें.

## D. Android push notifications क्यों अलग हैं
Push notification बंद app या lock screen पर दिखाई देती है. Realtime in-app feed उसका विकल्प नहीं है. Push के लिए owner को:
1. Firebase Console में project बनाना और Android package name `com.tradearmoney` register करना होगा.
2. Firebase की Android config file `google-services.json` और FlutterFire configuration बनानी होगी.
3. Firebase Cloud Messaging सक्षम करके service account credential को केवल server-side secret के रूप में सुरक्षित रखना होगा.
4. Firebase token registration, token storage (RLS के साथ), और authenticated admin-only server function से FCM HTTP v1 भेजना implement/test करना होगा.
5. कोई Firebase service-account JSON, private key या service-role key GitHub repo या Flutter app में commit न करें.

Firebase project/configuration owner के पास नहीं होने के कारण push notification को इस repository से अकेले live नहीं किया जा सकता. Credentials मिलने पर ही end-to-end push test संभव है.

## E. Production smoke tests
- Signup/login/forgot password/logout
- Email confirmation और password reset links
- Normal user को admin tools न दिखें
- Normal user द्वारा article/announcement/result insert RLS से reject हो
- Admin article/announcement publish करे और दूसरे user को दिखे
- Anonymous website published article पढ़ सके
- Realtime announcement update
- Android device install, offline/error states और app restart
- Privacy Policy और Terms में owner contact details भरकर review

## सुरक्षा नोट
App में केवल Supabase publishable/anon key रखें. Service-role key, FCM service-account private key और provider API secrets केवल trusted server-side environment में रखें.
