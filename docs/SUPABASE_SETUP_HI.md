# Supabase setup — Hindi checklist

यह setup app owner को एक बार करना होगा। App में service-role key कभी न डालें।

## 1. SQL schema चलाएँ
1. Supabase Dashboard खोलें और उसी project को चुनें जिसका URL `lib/main.dart` में है।
2. **SQL Editor → New query** खोलें।
3. Repository की `supabase/schema.sql` फाइल का पूरा SQL paste करके Run करें।
4. Run सफल होने के बाद **Table Editor** में `profiles`, `learning_articles`, `app_notifications`, और `result_history` दिखने चाहिए।

## 2. पहला admin सुरक्षित तरीके से बनाएँ
1. App से अपने admin email का account बनाकर email confirmation पूरा करें (यदि चालू है)।
2. Supabase Dashboard → **Authentication → Users** में उसी account का UUID कॉपी करें।
3. SQL Editor में यह query चलाएँ; placeholder को उस UUID से बदलें:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'PASTE_AUTH_USER_UUID_HERE';
   ```
4. App में logout/login करें और Account tab खोलें। Admin role पढ़ने पर **Open Admin Panel** दिखना चाहिए।
5. यदि कोई row update नहीं हुई, पहले सुनिश्चित करें कि signup trigger से `profiles` row बनी है। किसी दूसरे user को admin role न दें।

## 3. Smoke tests
- नया सामान्य user: signup, login, forgot password और logout।
- सामान्य user को Admin Panel नहीं दिखना चाहिए; admin writes RLS द्वारा अस्वीकार होने चाहिए।
- Admin Panel में एक educational article और announcement publish करें; Learn और Alerts tabs में जाँचें।
- केवल वास्तविक, अधिकृत स्रोत से सत्यापित result history record डालें। यह form manually record डालता है; live API नहीं जोड़ता।
- Supabase Table Editor → Policies में RLS policies देखें।

## 4. Production से पहले
- Email confirmation और redirect URLs configure करें।
- Owner का monitored support/privacy email जोड़कर `docs/PRIVACY_POLICY.md` और `docs/TERMS_OF_USE.md` review/publish करें।
- किसी live provider API का contract/license और authorization जाँचे; API secret केवल server/Edge Function में रखें।
- Firebase push messaging अभी configure नहीं है। मौजूदा Alerts tab in-app feed है, Android push notification नहीं।
- Release APK को असली Android device पर install करके test करें।

## 5. Website deploy (एक बार owner setting)
GitHub Actions deployment में अगर `Get Pages site failed` या `Resource not accessible by integration` दिखे:
1. Repository खोलें → **Settings → Pages**.
2. **Build and deployment → Source** में **GitHub Actions** चुनें; अगर Pages enable करने का विकल्प दिखे तो enable करें.
3. फिर **Actions → Deploy TRADE AR MONEY website → Run workflow** से workflow दोबारा चलाएँ.
4. Successful run में environment deployment URL दिखेगा. तब तक website source repo में मौजूद है, लेकिन public website live होने की पुष्टि नहीं है.
