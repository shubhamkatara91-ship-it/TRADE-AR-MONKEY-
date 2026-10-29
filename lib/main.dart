import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://sjpgqjxllpjqwsllrzya.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_VUzeFLr_Da61_gz_D6i1GA_1TMv5Seh');
const supportUrl = 'https://t.me/+pmahyzLfcMA2ODZl';
const appShareUrl = 'https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-';
const accent = Color(0xFF9BE7A5), background = Color(0xFF0E1712), panel = Color(0xFF18251C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey).timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('Backend initialization timed out after 10 seconds.'));
    runApp(const TradeArMoneyApp());
  } catch (error, stackTrace) {
    // Keep the app launchable if backend configuration/network initialization fails.
    runApp(StartupFailureApp(message: error.toString()));
    FlutterError.presentError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'TRADE AR MONEY startup',
      context: ErrorDescription('while initializing the backend'),
    ));
  }
}

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TRADE AR MONEY',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: const Color(0xFF0E1712),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 56, color: Colors.orangeAccent),
                const SizedBox(height: 16),
                const Text('TRADE AR MONEY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'App खुल गया है, लेकिन backend शुरू नहीं हो पाया। Internet connection जाँचें। अगर समस्या बनी रहे, तो यह error support को भेजें:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                const Text('अभी login और online data उपलब्ध नहीं होंगे।', textAlign: TextAlign.center, style: TextStyle(color: Colors.orangeAccent)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
class TradeArMoneyApp extends StatelessWidget {
  const TradeArMoneyApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'TRADE AR MONEY', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3:true, brightness:Brightness.dark, scaffoldBackgroundColor:background,
      colorScheme:ColorScheme.fromSeed(seedColor:accent,brightness:Brightness.dark),
      inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder())),
    home:const HomePage());
}
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  int tab=0; bool busy=false, showPassword=false, createMode=true;
  RealtimeChannel? _notificationChannel;
  @override void initState(){
    super.initState();
    _notificationChannel=client.channel('public-app-notifications')
      .onPostgresChanges(event:PostgresChangeEvent.insert,schema:'public',table:'app_notifications',callback:(payload){
        if(!mounted)return;
        setState((){});
        final record=payload.newRecord;
        if(record['audience']=='all' || (client.auth.currentUser!=null && record['audience']=='users')){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('New announcement: ${record['title']??'TRADE AR MONEY'}')));
        }
      }).subscribe();
  }
  final email=TextEditingController(), password=TextEditingController(), username=TextEditingController(), mobile=TextEditingController(), confirmPassword=TextEditingController();
  final formKey=GlobalKey<FormState>();
  final client=Supabase.instance.client;
  @override void dispose(){email.dispose();password.dispose();username.dispose();mobile.dispose();confirmPassword.dispose();if(_notificationChannel!=null){client.removeChannel(_notificationChannel!);}super.dispose();}
  void msg(String s){if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  Future<void> support() async { final ok=await launchUrl(Uri.parse(supportUrl),mode:LaunchMode.externalApplication); if(!ok) msg('Telegram link नहीं खुला।'); }
  Future<void> shareApp() async {
    await Share.share('TRADE AR MONEY — Learn market basics, understand risk, and explore educational resources.\n\nJoin me: $appShareUrl\n\nEducational content only; no guaranteed results.', subject: 'TRADE AR MONEY');
  }
  Future<void> openDocument(String url) async {
    final ok=await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
    if(!ok) msg('लिंक नहीं खुला। इंटरनेट कनेक्शन जाँचें।');
  }
  Future<void> auth(bool signup) async {
    if(!(formKey.currentState?.validate()??false)) return;
    final e=email.text.trim();
    final p=password.text;
    if(signup && p.length<8){msg('नया password कम-से-कम 8 अक्षर का होना चाहिए।');return;}
    if(signup && p!=confirmPassword.text){msg('Password और Confirm Password match नहीं करते।');return;}
    if(signup && username.text.trim().length<3){msg('Username कम-से-कम 3 अक्षर का होना चाहिए।');return;}
    final phone=mobile.text.trim();
    final digits=phone.replaceAll('+','');
    if(signup && (digits.length<10 || digits.length>15 || !digits.split('').every((c)=>'0123456789'.contains(c)))){msg('Mobile number 10 से 15 digits का लिखें।');return;}
    setState(()=>busy=true);
    try {
      if(signup){
        final r=await client.auth.signUp(email:e,password:p,data:{'username':username.text.trim(),'mobile':phone});
        if(mounted && r.session!=null){setState(()=>tab=0);}
        msg(r.session==null?'Signup request भेजी गई। Email confirmation चालू हो तो email verify करके फिर login करें।':'Account बन गया और login सफल।');
      } else {
        await client.auth.signInWithPassword(email:e,password:p);
        if(mounted){setState(()=>tab=0);FocusManager.instance.primaryFocus?.unfocus();}
        msg('Login सफल। Home खुल गया।');
      }
    } on AuthException catch(e){
      final m=e.message.toLowerCase();
      if(m.contains('invalid login credentials')){msg('Email या password सही नहीं है। Email की spelling जाँचें या Forgot password इस्तेमाल करें.');}
      else if(m.contains('email not confirmed')){msg('Email अभी verify नहीं हुई। Inbox/Spam में verification email देखें.');}
      else if(m.contains('rate limit')||m.contains('too many requests')){msg('बहुत बार कोशिश हुई है। थोड़ी देर बाद फिर प्रयास करें.');}
      else if(m.contains('already registered')){msg('यह email पहले से registered है। Log in करें या password reset करें.');}
      else {msg('Authentication error: ${e.message}');}
    } catch(_){msg('कनेक्शन नहीं हुआ। इंटरनेट और Supabase URL/anon key की जाँच करें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> resetPassword() async {
    await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ForgotPasswordPage(client:client)));
  }
  Future<void> logout() async {try{await client.auth.signOut();if(mounted)setState((){});msg('Logout हो गया।');}catch(_){msg('Logout नहीं हो सका।');}}
  Future<List<Map<String,dynamic>>> loadResults() async {
    final r=await client.from('result_history').select('id,source,result_label,result_value,observed_at').order('observed_at',ascending:false).limit(100);
    return List<Map<String,dynamic>>.from(r);
  }
  Future<List<Map<String,dynamic>>> loadLearning() async {
    final r=await client.from('learning_articles').select('id,title,body,category').eq('published',true).order('created_at',ascending:false).limit(100);
    return List<Map<String,dynamic>>.from(r);
  }
  Widget toolsPage()=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('TOOLS',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
    const SizedBox(height:8),
    const Text('Choose a tool to open it. ARG V1 starts a fresh 60-second practice round automatically.',style:TextStyle(color:Colors.white70)),
    const SizedBox(height:18),
    Card(color:panel,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:accent,width:1)),child:ListTile(
      contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:16),
      leading:Container(width:52,height:52,decoration:BoxDecoration(color:accent.withOpacity(0.12),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.bolt,color:accent,size:30)),
      title:const Text('ARG V1',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
      subtitle:const Padding(padding:EdgeInsets.only(top:6),child:Text('WinGo • 1 Minute • BIG / SMALL practice')),
      trailing:const Icon(Icons.arrow_forward_ios,size:17,color:accent),
      onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const ArgV1Page())),
    )),
    const SizedBox(height:10),
    Card(color:panel,child:ListTile(
      contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:12),
      leading:Container(width:52,height:52,decoration:BoxDecoration(color:accent.withOpacity(0.12),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.shield_outlined,color:accent,size:28)),
      title:const Text('Auto Bet — Practice Controls',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
      subtitle:const Padding(padding:EdgeInsets.only(top:5),child:Text('Capital target • Levels 1–5 • Practice-only stop rules')),
      trailing:const Icon(Icons.arrow_forward_ios,size:17,color:accent),
      onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const AutoBetPracticePage())),
    )),
    const SizedBox(height:10),
    const Text('Note: live results/predictions are not connected. This tool does not generate or claim live signals.',style:TextStyle(color:Colors.orangeAccent)),
  ]);
  Widget insightsPage()=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('AI & MARKET INSIGHTS',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const SizedBox(height:12),
    Card(color:panel,child:const ListTile(leading:Icon(Icons.auto_graph,color:accent),title:Text('Market Insights'),subtitle:Text('Review historical information and understand probability. No live market feed is connected.'))),
    Card(color:panel,child:const ListTile(leading:Icon(Icons.psychology_alt,color:accent),title:Text('AI Analytics'),subtitle:Text('Analytics tools can be added when a verified data source and model are configured. This build does not generate live predictions.'))),
    Card(color:panel,child:const ListTile(leading:Icon(Icons.shield_outlined,color:accent),title:Text('Risk Guide'),subtitle:Text('Past results do not guarantee future outcomes. Avoid treating random outcomes as certain signals.'))),
    const SizedBox(height:8),
    const Text('Educational information only. No guaranteed predictions or betting features.',style:TextStyle(color:Colors.orangeAccent)),
  ]);
  Widget learningPage()=>RefreshIndicator(onRefresh:()async{setState((){});await loadLearning();},child:FutureBuilder<List<Map<String,dynamic>>>(future:loadLearning(),builder:(context,s){
    if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
    if(s.hasError)return ListView(children:[errorBox(s.error!)]);
    final rows=s.data??[];
    if(rows.isEmpty)return ListView(padding:const EdgeInsets.all(24),children:const [
      Icon(Icons.menu_book,size:42,color:accent),SizedBox(height:12),
      Text('Learn & Guides',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),
      Text('Learning articles will appear here after an admin publishes them in Supabase.')
    ]);
    return ListView(padding:const EdgeInsets.all(16),children:[const Text('LEARN & GUIDES',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),...rows.map((r)=>Card(color:panel,child:ExpansionTile(leading:const Icon(Icons.menu_book,color:accent),title:Text('${r['title']}'),subtitle:Text('${r['category']}'),children:[Padding(padding:const EdgeInsets.all(16),child:Align(alignment:Alignment.centerLeft,child:Text('${r['body']}')))])))]);
  }));
  Future<List<Map<String,dynamic>>> loadNotifications() async {
    final r=await client.from('app_notifications').select('id,title,body,created_at').order('created_at',ascending:false).limit(50);
    return List<Map<String,dynamic>>.from(r);
  }
  Widget errorBox(Object error) => Padding(padding:const EdgeInsets.all(16),child:Text('डेटा अभी उपलब्ध नहीं है। Supabase SQL schema लागू करें और नेटवर्क जाँचें.\n$error',style:const TextStyle(color:Colors.orangeAccent)));
  Widget resultsPage()=>RefreshIndicator(onRefresh:()async{setState((){});await loadResults();},child:FutureBuilder<List<Map<String,dynamic>>>(future:loadResults(),builder:(context,s){
    if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
    if(s.hasError)return ListView(children:[errorBox(s.error!)]);
    final rows=s.data??[];
    if(rows.isEmpty)return ListView(padding:const EdgeInsets.all(24),children:const [Icon(Icons.history,size:42,color:accent),SizedBox(height:12),Text('Results History',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('अभी कोई result रिकॉर्ड नहीं है। रिकॉर्ड manually जोड़े जाते हैं; original source से खुद जाँचें।')]);
    return ListView(padding:const EdgeInsets.all(16),children:[const Text('RESULTS HISTORY',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),...rows.map((r)=>Card(color:panel,child:ListTile(leading:const Icon(Icons.history,color:accent),title:Text('${r['result_label']}'),subtitle:Text('${r['source']} • ${r['observed_at']}'),trailing:Text('${r['result_value']??''}'))))]);
  }));
  Widget notificationsPage()=>RefreshIndicator(onRefresh:()async{setState((){});await loadNotifications();},child:FutureBuilder<List<Map<String,dynamic>>>(future:loadNotifications(),builder:(context,s){
    if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
    if(s.hasError)return ListView(children:[errorBox(s.error!)]);
    final rows=s.data??[];
    if(rows.isEmpty)return ListView(padding:const EdgeInsets.all(24),children:const [Icon(Icons.notifications_none,size:42,color:accent),SizedBox(height:12),Text('Notifications',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('अभी कोई notification नहीं है। Admin के नए announcements उपलब्ध होने पर यह feed अपने-आप refresh होगी। Android lock-screen push notifications के लिए Firebase project और credentials अलग से आवश्यक हैं।')]);
    return ListView(padding:const EdgeInsets.all(16),children:[const Text('NOTIFICATIONS',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),...rows.map((r)=>Card(color:panel,child:ListTile(leading:const Icon(Icons.notifications_active,color:accent),title:Text('${r['title']}'),subtitle:Text('${r['body']}\n${r['created_at']}'))))]);
  }));
  @override Widget build(BuildContext context){
    final user=client.auth.currentUser;
    final pages=<Widget>[
      ListView(padding:const EdgeInsets.all(18),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF294B32),Color(0xFF101B13)])),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Icon(Icons.auto_graph,color:accent,size:32),SizedBox(height:12),Text('TRADE AR MONEY',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),SizedBox(height:8),
          Text('Learn the market. Understand the risk. Make informed decisions.'),SizedBox(height:14),
          Text('Educational content only. Live data API is not connected; no live results or guaranteed predictions are shown.',style:TextStyle(color:Colors.white70))])),
        const SizedBox(height:18),const Text('QUICK ACCESS',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.auto_graph,color:accent),title:const Text('AI Analytics'),subtitle:const Text('Market insights and risk guide'),onTap:()=>setState(()=>tab=1))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.workspace_premium,color:accent),title:const Text('VIP Membership'),subtitle:const Text('Membership status and future features'),onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const VipMembershipPage())))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.shield_outlined,color:accent),title:const Text('Risk Guide'),subtitle:const Text('Understand probability and risk'),onTap:()=>setState(()=>tab=1))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.history,color:accent),title:const Text('Results History'),subtitle:const Text('View admin-entered history records'),onTap:()=>setState(()=>tab=2))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.notifications,color:accent),title:const Text('Notifications'),subtitle:const Text('Read in-app announcements'),onTap:()=>setState(()=>tab=3))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.share,color:accent),title:const Text('Share with friends'),subtitle:const Text('Invite friends to TRADE AR MONEY'),onTap:shareApp)),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.support_agent,color:accent),title:const Text('Telegram Support'),subtitle:const Text('Open Telegram'),onTap:support)),
        if(user!=null)Card(color:panel,child:ListTile(leading:const Icon(Icons.verified_user,color:accent),title:const Text('Signed in'),subtitle:Text(user.email??'Account active'))),
      ]),
      toolsPage(),
      resultsPage(),
      notificationsPage(),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('COMMUNITY',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const Card(color:panel,child:ListTile(leading:Icon(Icons.groups,color:accent),title:Text('TRADE AR MONEY Telegram'),subtitle:Text('Community and support currently use the configured Telegram invite link.'))),
        FilledButton.icon(onPressed:shareApp,icon:const Icon(Icons.share),label:const Text('Share with friends')),
        const SizedBox(height:10),
        OutlinedButton.icon(onPressed:support,icon:const Icon(Icons.send),label:const Text('Open Telegram')),
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('ACCOUNT',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        if(user==null)...[
          const SizedBox(height:8),Text(createMode?'Create your account using all fields below.':'Log in with your registered email and password.'),
          const SizedBox(height:16),Form(key:formKey,child:Column(children:[
            if(createMode)...[
              TextFormField(controller:username,autofillHints:const[AutofillHints.username],decoration:const InputDecoration(labelText:'Username'),validator:(v)=>(v??'').trim().length>=3?null:'Username कम-से-कम 3 अक्षर का होना चाहिए।'),
              const SizedBox(height:12),
              TextFormField(controller:mobile,keyboardType:TextInputType.phone,autofillHints:const[AutofillHints.telephoneNumber],decoration:const InputDecoration(labelText:'Mobile Number'),validator:(v){final n=(v??'').trim().replaceAll('+','');return n.length>=10&&n.length<=15&&n.split('').every((c)=>'0123456789'.contains(c))?null:'10 से 15 digits का mobile number लिखें।';}),
              const SizedBox(height:12),
            ],
            TextFormField(controller:email,keyboardType:TextInputType.emailAddress,autofillHints:const[AutofillHints.email],decoration:const InputDecoration(labelText:'Email ID'),validator:(v){final x=(v??'').trim();return x.contains('@')&&x.contains('.')?null:'सही email लिखें।';}),
            const SizedBox(height:12),
            TextFormField(controller:password,obscureText:!showPassword,autofillHints:const[AutofillHints.newPassword],decoration:InputDecoration(labelText:createMode?'Password (minimum 8 characters)':'Password',suffixIcon:IconButton(onPressed:()=>setState(()=>showPassword=!showPassword),icon:Icon(showPassword?Icons.visibility_off:Icons.visibility))),validator:(v)=>createMode?((v??'').length>=8?null:'Password कम-से-कम 8 अक्षर का होना चाहिए।'):((v??'').isNotEmpty?null:'Password लिखें।')),
            if(createMode)...[
              const SizedBox(height:12),
              TextFormField(controller:confirmPassword,obscureText:!showPassword,decoration:const InputDecoration(labelText:'Confirm Password'),validator:(v)=>(v??'')==password.text?null:'दोनों password match होने चाहिए।'),
            ],
            const SizedBox(height:14),
            SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:()=>auth(createMode),child:Text(busy?'Please wait…':createMode?'Create Account':'Log in'))),
            TextButton(onPressed:()=>setState(()=>createMode=!createMode),child:Text(createMode?'Already have an account? Log in':'New here? Create account')),
            TextButton(onPressed:busy?null:resetPassword,child:const Text('Forgot password?')),
          ])),
        ]else ...[
          Card(color:panel,child:ListTile(leading:const Icon(Icons.account_circle,color:accent),title:const Text('Signed in as'),subtitle:Text(user.email??'Email unavailable'))),
          FutureBuilder<Map<String,dynamic>?>(
            future:client.from('profiles').select('role').eq('id',user.id).maybeSingle(),
            builder:(context,s){
              if(s.data?['role']!='admin') return const SizedBox.shrink();
              return SizedBox(width:double.infinity,child:FilledButton.icon(
                onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>AdminPanel(client:client))),
                icon:const Icon(Icons.admin_panel_settings),label:const Text('Open Admin Panel')));
            }),

          SizedBox(width:double.infinity,child:OutlinedButton.icon(onPressed:logout,icon:const Icon(Icons.logout),label:const Text('Log out'))),
        ],
        if(user!=null)...[
        const SizedBox(height:14),OutlinedButton.icon(onPressed:support,icon:const Icon(Icons.support_agent),label:const Text('Contact support')),
        const SizedBox(height:14),
        const Text('LEGAL & PRIVACY',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
        ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.privacy_tip_outlined,color:accent),title:const Text('Privacy Policy'),subtitle:const Text('Review data handling information'),onTap:()=>openDocument('https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/blob/main/docs/PRIVACY_POLICY.md')),
        ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.description_outlined,color:accent),title:const Text('Terms of Use'),subtitle:const Text('Review app terms and limitations'),onTap:()=>openDocument('https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/blob/main/docs/TERMS_OF_USE.md')),
        const SizedBox(height:14),const Text('Admin access must be granted securely in the database. Never place service-role secrets in the app.',style:TextStyle(color:Colors.white60)),
        ],
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('SUPPORT',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        const Card(color:panel,child:ListTile(leading:Icon(Icons.support_agent,color:accent),title:Text('Telegram Support'),subtitle:Text('Contact the configured support channel.'))),
        SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:support,icon:const Icon(Icons.send),label:const Text('Open Telegram Support'))),
      ]),
      const VipMembershipPage(),
    ];
    if(user==null){
      return Scaffold(
        appBar:AppBar(title:const Text('TRADE AR MONEY',style:TextStyle(fontWeight:FontWeight.w900))),
        body:pages[5],
      );
    }
    return Scaffold(appBar:AppBar(title:const Text('TRADE AR MONEY',style:TextStyle(fontWeight:FontWeight.w900)),actions:[
      IconButton(onPressed:()=>setState(()=>tab=3),tooltip:'Notifications',icon:const Icon(Icons.notifications_outlined,color:accent)),
      IconButton(onPressed:shareApp,tooltip:'Share app',icon:const Icon(Icons.share_outlined,color:accent)),
      IconButton(onPressed:support,tooltip:'Telegram Support',icon:const Icon(Icons.support_agent,color:accent))]),
      body:pages[tab],bottomNavigationBar:NavigationBar(backgroundColor:panel,selectedIndex:tab==0?1:tab==1?0:tab==5?2:tab==6?3:tab==7?4:0,onDestinationSelected:(v){
        if(v==0){setState(()=>tab=1);}
        else if(v==1){setState(()=>tab=0);}
        else if(v==2){setState(()=>tab=5);}
        else if(v==3){setState(()=>tab=6);}
        else if(v==4){setState(()=>tab=7);}
        else if(v==5){logout();}
      },destinations:const[
        NavigationDestination(icon:Icon(Icons.build_outlined),label:'Tools'),
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'Home'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile'),
        NavigationDestination(icon:Icon(Icons.support_agent_outlined),label:'Support'),
        NavigationDestination(icon:Icon(Icons.workspace_premium_outlined),label:'Premium'),
        NavigationDestination(icon:Icon(Icons.logout),label:'Log Out'),
      ]));
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key,required this.client});
  final SupabaseClient client;
  @override State<ForgotPasswordPage> createState()=>_ForgotPasswordPageState();
}
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email=TextEditingController(), otp=TextEditingController(), password=TextEditingController(), confirm=TextEditingController();
  bool busy=false, codeSent=false, verified=false, showPassword=false;
  String status='';
  @override void dispose(){email.dispose();otp.dispose();password.dispose();confirm.dispose();super.dispose();}
  Future<void> sendCode() async {
    final e=email.text.trim();
    if(!e.contains('@')||!e.contains('.')){setState(()=>status='Registered email ID सही लिखें।');return;}
    setState(()=>busy=true);
    try {
      await widget.client.auth.resetPasswordForEmail(e);
      if(mounted)setState(()=>status='यदि account मौजूद है, तो email पर recovery code भेजा गया है। Inbox और Spam folder जाँचें।');
      if(mounted)setState(()=>codeSent=true);
    } on AuthException catch(x){if(mounted)setState(()=>status=x.message);}
      catch(_){if(mounted)setState(()=>status='OTP request नहीं भेजी जा सकी। Internet और email settings जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> verifyCode() async {
    if(otp.text.trim().length<6){setState(()=>status='Email में आया पूरा OTP डालें।');return;}
    setState(()=>busy=true);
    try {
      await widget.client.auth.verifyOTP(email:email.text.trim(),token:otp.text.trim(),type:OtpType.recovery);
      if(mounted)setState(()=>verified=true);
      if(mounted)setState(()=>status='OTP verified. अब नया password बनाएँ।');
    } on AuthException catch(x){if(mounted)setState(()=>status='OTP verify नहीं हुआ: ${x.message}');}
      catch(_){if(mounted)setState(()=>status='OTP verify नहीं हुआ। Code और expiry जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> savePassword() async {
    if(password.text.length<8){setState(()=>status='नया password कम-से-कम 8 अक्षर का होना चाहिए।');return;}
    if(password.text!=confirm.text){setState(()=>status='New Password और Confirm Password match नहीं करते।');return;}
    setState(()=>busy=true);
    try {
      await widget.client.auth.updateUser(UserAttributes(password:password.text));
      if(mounted)setState(()=>status='Password successfully changed. अब वापस जाकर login करें।');
    } on AuthException catch(x){if(mounted)setState(()=>status='Password update नहीं हुआ: ${x.message}');}
      catch(_){if(mounted)setState(()=>status='Password update नहीं हो सका। फिर प्रयास करें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Forgot Password')),
    body:SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
      const Text('Reset your password',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      const Text('Registered email पर recovery OTP मँगाएँ, OTP verify करें और नया password save करें।'),
      const SizedBox(height:18),
      TextField(controller:email,enabled:!codeSent,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Registered Email ID')),
      const SizedBox(height:12),
      if(!codeSent) SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:sendCode,child:Text(busy?'Please wait…':'Send OTP to Email'))),
      if(codeSent&&!verified)...[
        TextField(controller:otp,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Email OTP')),
        const SizedBox(height:12),
        SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:verifyCode,child:Text(busy?'Verifying…':'Verify OTP'))),
        TextButton(onPressed:busy?null:sendCode,child:const Text('Resend OTP')),
      ],
      if(verified)...[
        TextField(controller:password,obscureText:!showPassword,decoration:InputDecoration(labelText:'New Password (minimum 8 characters)',suffixIcon:IconButton(onPressed:()=>setState(()=>showPassword=!showPassword),icon:Icon(showPassword?Icons.visibility_off:Icons.visibility)))),
        const SizedBox(height:12),
        TextField(controller:confirm,obscureText:!showPassword,decoration:const InputDecoration(labelText:'Confirm New Password')),
        const SizedBox(height:12),
        SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:savePassword,child:Text(busy?'Saving…':'Save New Password'))),
      ],
      if(status.isNotEmpty)...[const SizedBox(height:14),Text(status,style:const TextStyle(color:accent))],
    ])),
  );
}
class ArgV1Page extends StatefulWidget {
  const ArgV1Page({super.key});
  @override State<ArgV1Page> createState()=>_ArgV1PageState();
}
class _ArgV1PageState extends State<ArgV1Page> {
  int remaining=60-DateTime.now().second;
  String round=_localPeriodId(DateTime.now());
  String? selected;
  bool autoPractice=false;
  String autoPracticeChoice='BIG';
  final List<String> practiceHistory=[];
  List<Map<String,dynamic>> liveRows=[];
  String? liveSource, liveFetchedAt, liveError;
  bool loadingLive=false;
  Timer? ticker;
  static String _localPeriodId(DateTime time) =>
      '${time.year.toString().padLeft(4,'0')}${time.month.toString().padLeft(2,'0')}${time.day.toString().padLeft(2,'0')}${time.hour.toString().padLeft(2,'0')}${time.minute.toString().padLeft(2,'0')}';
  @override void initState(){
    super.initState();
    _syncRoundClock();
    ticker=Timer.periodic(const Duration(seconds:1),(_){
      if(!mounted)return;
      _syncRoundClock();
    });
    // Load the read-only result history automatically when ARG V1 opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadLiveResults();
    });
  }
  void _syncRoundClock(){
    final now=DateTime.now();
    final currentRound=_localPeriodId(now);
    final nextRemaining=60-now.second;
    if(currentRound!=round){
      setState((){
        round=currentRound;
        remaining=nextRemaining;
        selected=null;
      });
      // Practice-only automation; no money or external bet submission.
      if(autoPractice) choose(autoPracticeChoice);
    }else if(nextRemaining!=remaining){
      setState(()=>remaining=nextRemaining);
    }
  }
  @override void dispose(){ticker?.cancel();super.dispose();}
  void choose(String value){
    setState(()=>selected=value);
    practiceHistory.insert(0,'Period $round • Practice choice: $value');
    if(practiceHistory.length>10)practiceHistory.removeLast();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$value selected for practice only. No result prediction was made.')));
  }
  Future<void> loadLiveResults() async {
    if(loadingLive)return;
    if (Supabase.instance.client.auth.currentUser == null) {
      setState(() => liveError = 'Source result history के लिए पहले sign in करें।');
      return;
    }
    setState(()=>loadingLive=true);
    try {
      final response=await Supabase.instance.client.functions.invoke('arg-v1-results',method:HttpMethod.get);
      final payload=response.data;
      if(payload is! Map) throw Exception('Result API ने expected JSON object नहीं लौटाया।');
      final raw=payload['results'];
      if(raw is! List) throw Exception('Response schema mismatch: results array नहीं मिला।');
      final parsed=<Map<String,dynamic>>[];
      for(final item in raw){
        if(item is Map) parsed.add(Map<String,dynamic>.from(item));
      }
      if(!mounted)return;
      setState((){
        liveRows=parsed;
        liveSource=payload['source']?.toString();
        liveFetchedAt=payload['fetchedAt']?.toString();
        liveError=null;
      });
    } catch(e) {
      if(!mounted)return;
      setState(()=>liveError=e.toString());
    } finally {
      if(mounted)setState(()=>loadingLive=false);
    }
  }
  String? _normalizedSize(Map<String,dynamic> row) {
    final raw=(row['bigSmall'] ?? row['result_label'] ?? row['size'] ?? '').toString().trim().toUpperCase();
    if(raw=='BIG' || raw=='B' || raw=='大') return 'BIG';
    if(raw=='SMALL' || raw=='S' || raw=='小') return 'SMALL';
    final number=int.tryParse((row['number'] ?? row['result_value'] ?? '').toString());
    if(number!=null && number>=0 && number<=9) return number>=5?'BIG':'SMALL';
    return null;
  }
  Widget patternAnalysisPanel() {
    final recent=liveRows.take(20).toList();
    final classified=recent.map((row)=>_normalizedSize(row)).whereType<String>().toList();
    final big=classified.where((x)=>x=='BIG').length;
    final small=classified.where((x)=>x=='SMALL').length;
    final unknown=recent.length-classified.length;
    var streak=0;
    String? streakType;
    for(final row in recent) {
      final size=_normalizedSize(row);
      if(size==null) break;
      if(streakType==null) {streakType=size; streak=1;}
      else if(size==streakType) {streak++;}
      else break;
    }
    final enough=classified.length>=10;
    final lean=enough && big!=small ? (big>small?'BIG':'SMALL') : null;
    final share=classified.isEmpty?0.0:(big>small?big:small)/classified.length*100;
    return Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('RECENT PATTERN ANALYSIS',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
      const SizedBox(height:6),
      Text('Analyzed ${classified.length} classified results from the latest ${recent.length} loaded records.'),
      const SizedBox(height:8),
      Row(children:[
        Expanded(child:Text('BIG: ${big}',style:const TextStyle(color:Color(0xFF78D69A),fontWeight:FontWeight.bold))),
        Expanded(child:Text('SMALL: ${small}',style:const TextStyle(color:Color(0xFFFF8C8C),fontWeight:FontWeight.bold))),
      ]),
      Text('Unclassified records: ${unknown}'),
      Text(streakType==null?'Current streak: not available':'Latest visible streak: ${streakType} × ${streak}'),
      const SizedBox(height:8),
      Text(!enough?'Pattern lean: insufficient data (need at least 10 classified results).':lean==null?'Pattern lean: no side dominates this sample.':'Descriptive sample lean: ${lean} (${share.toStringAsFixed(0)}% of classified results).'),
      const SizedBox(height:6),
      const Text('This summarizes past records only. It does not establish the next outcome, does not verify Mark Pro/GoaOK data, and must not be treated as a bet instruction.',style:TextStyle(color:Colors.orangeAccent,fontSize:12)),
    ])));
  }
  Widget liveResultsPanel()=>Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('SOURCE RESULT HISTORY',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
    const SizedBox(height:6),
    Text(liveSource==null?'Authorized read-only source is not yet configured.': 'Source: $liveSource',style:const TextStyle(color:Colors.white70)),
    if(liveFetchedAt!=null)Text('Fetched: $liveFetchedAt',style:const TextStyle(color:Colors.white54,fontSize:12)),
    const SizedBox(height:10),
    SizedBox(width:double.infinity,child:OutlinedButton.icon(
      onPressed:loadingLive?null:loadLiveResults,
      icon:loadingLive?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.refresh),
      label:Text(loadingLive?'Loading…':'Refresh result history'),
    )),
    if(liveError!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text('Result feed unavailable: $liveError',style:const TextStyle(color:Colors.orangeAccent))),
    if(liveRows.isEmpty && liveError==null)const Padding(padding:EdgeInsets.only(top:8),child:Text('No records loaded. Configure the authorized API and refresh.',style:TextStyle(color:Colors.white70))),
    ...liveRows.take(20).map((row)=>ListTile(
      dense:true,contentPadding:EdgeInsets.zero,
      leading:const Icon(Icons.history,color:accent),
      title:Text('Period: ${row['period']??'—'}'),
      subtitle:Text('Number: ${row['number']??'—'} • ${row['bigSmall']??'Size unknown'}${row['drawTime']==null?'':' • ${row['drawTime']}'}'),
    )),
  ])));
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('ARG V1 • WinGo 1 Minute')),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('ARG V1 • 1-MINUTE ROUND',style:TextStyle(color:accent,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),Text((remaining ~/ 60).toString().padLeft(2,'0') + ':' + (remaining % 60).toString().padLeft(2,'0'),style:const TextStyle(fontSize:42,fontWeight:FontWeight.w900)),
        Text('Local practice period: $round',style:const TextStyle(color:Colors.white70)),
      ])),
      const SizedBox(height:10),
      Card(color:panel,child:const ListTile(
        dense:true,
        leading:Icon(Icons.schedule,color:accent),
        title:Text('Clock status: synchronized to this device'),
        subtitle:Text('This is a local minute period, not an official provider round ID. Live results are not connected.'),
      )),
      const SizedBox(height:12),
      liveResultsPanel(),
      const SizedBox(height:10),
      patternAnalysisPanel(),
      const SizedBox(height:16),
      const Text('BIG / SMALL',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      const Text('Practice controls only. This app is not connected to Mark Pro or an authorized live results API, so it cannot show a verified live prediction.'),
      const SizedBox(height:14),
      Row(children:[
        Expanded(child:FilledButton(style:FilledButton.styleFrom(backgroundColor:const Color(0xFF2E8B57)),onPressed:()=>choose('BIG'),child:const Text('BIG'))),
        const SizedBox(width:12),
        Expanded(child:FilledButton(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFB65C5C)),onPressed:()=>choose('SMALL'),child:const Text('SMALL'))),
      ]),
      const SizedBox(height:14),
      DropdownButtonFormField<String>(
        value:autoPracticeChoice,
        decoration:const InputDecoration(labelText:'Auto-practice choice',helperText:'Repeats this choice each new local minute. Not a prediction.'),
        items:const [
          DropdownMenuItem(value:'BIG',child:Text('Repeat BIG')),
          DropdownMenuItem(value:'SMALL',child:Text('Repeat SMALL')),
        ],
        onChanged:autoPractice?null:(value){if(value!=null)setState(()=>autoPracticeChoice=value);},
      ),
      const SizedBox(height:8),
      SizedBox(width:double.infinity,child:OutlinedButton.icon(
        icon:Icon(autoPractice?Icons.stop_circle_outlined:Icons.autorenew),
        onPressed:()=>setState(()=>autoPractice=!autoPractice),
        label:Text(autoPractice?'Stop auto-practice':'Start auto-practice'),
      )),
      Text(autoPractice?'Auto-practice is ON. It will record a practice choice at each new local minute.':'Auto-practice is OFF.',style:TextStyle(color:autoPractice?accent:Colors.white70)),
      if(selected!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text('Selected: $selected (practice only)',style:const TextStyle(color:accent,fontWeight:FontWeight.bold))),
      const SizedBox(height:20),
      const Text('PRACTICE HISTORY',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      if(practiceHistory.isEmpty)const Text('No practice selections yet.',style:TextStyle(color:Colors.white70)),
      ...practiceHistory.map((item)=>Card(color:panel,child:ListTile(leading:const Icon(Icons.history,color:accent),title:Text(item)))),
      const SizedBox(height:12),
      const Text('Educational practice only. No betting, payments, live predictions, or guaranteed outcomes are provided.',style:TextStyle(color:Colors.orangeAccent)),
    ]),
  );
}
class AdminPanel extends StatefulWidget {
  final SupabaseClient client;
  const AdminPanel({super.key,required this.client});
  @override State<AdminPanel> createState()=>_AdminPanelState();
}
class _AdminPanelState extends State<AdminPanel> {
  final articleTitle=TextEditingController(),articleBody=TextEditingController(),category=TextEditingController(text:'Basics');
  final noticeTitle=TextEditingController(),noticeBody=TextEditingController();
  final source=TextEditingController(),resultLabel=TextEditingController(),resultValue=TextEditingController();
  bool busy=false;
  @override void dispose(){articleTitle.dispose();articleBody.dispose();noticeTitle.dispose();noticeBody.dispose();category.dispose();source.dispose();resultLabel.dispose();resultValue.dispose();super.dispose();}
  void message(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  Future<void> saveArticle() async {
    if(articleTitle.text.trim().isEmpty||articleBody.text.trim().isEmpty){message('Title और content भरें।');return;}
    setState(()=>busy=true);
    try{await widget.client.from('learning_articles').insert({'title':articleTitle.text.trim(),'body':articleBody.text.trim(),'category':category.text.trim().isEmpty?'Basics':category.text.trim(),'published':true});articleTitle.clear();articleBody.clear();message('Learning article publish हो गया।');}
    catch(e){message('Save नहीं हुआ। Admin role और database schema जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> saveNotice() async {
    if(noticeTitle.text.trim().isEmpty||noticeBody.text.trim().isEmpty){message('Title और message भरें।');return;}
    setState(()=>busy=true);
    final title=noticeTitle.text.trim(), body=noticeBody.text.trim();
    try{
      await widget.client.from('app_notifications').insert({'title':title,'body':body,'audience':'all'});
      noticeTitle.clear();noticeBody.clear();
      // In-app announcement is saved first. Push is best-effort and requires
      // the separately deployed Edge Function plus registered Firebase tokens.
      try{
        final pushed=await widget.client.functions.invoke('send-push',body: {'title':title,'body':body});
        if(pushed.status>=200 && pushed.status<300){
          final data=pushed.data;
          if(data is Map && data['sent'] is num && (data['sent'] as num)>0){
            message('Announcement publish हुआ। Push भेजे गए: ${data['sent']}');
          }else{
            message('Announcement publish हुआ। Push setup है, लेकिन अभी registered devices नहीं मिले।');
          }
        }else{
          message('Announcement publish हुआ। Push अभी configured/deployed नहीं है।');
        }
      }catch(_){
        message('Announcement publish हुआ। In-app notification उपलब्ध है; push के लिए Firebase setup बाकी है।');
      }
    }catch(e){message('Save नहीं हुआ। Admin role और database schema जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> saveResult() async {
    if(source.text.trim().isEmpty||resultLabel.text.trim().isEmpty){message('Source और result label आवश्यक हैं।');return;}
    setState(()=>busy=true);
    try{await widget.client.from('result_history').insert({'source':source.text.trim(),'result_label':resultLabel.text.trim(),'result_value':resultValue.text.trim().isEmpty?null:resultValue.text.trim(),'observed_at':DateTime.now().toUtc().toIso8601String()});source.clear();resultLabel.clear();resultValue.clear();message('Record save हुआ। Result को original source से independently verify करें।');}
    catch(e){message('Save नहीं हुआ। Admin role और database schema जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Widget field(TextEditingController c,String label,{int lines=1})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c,maxLines:lines,decoration:InputDecoration(labelText:label)));
  Widget section(String name,IconData icon,List<Widget> children)=>Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:accent),const SizedBox(width:8),Text(name,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold))]),const SizedBox(height:12),...children])));
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Admin Panel')),body:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Admin tools are protected by Supabase Row Level Security. Publish only accurate, authorized information.',style:TextStyle(color:Colors.white70)),
    const SizedBox(height:12),
    section('Publish learning article',Icons.menu_book,[
      field(articleTitle,'Article title'),field(category,'Category'),field(articleBody,'Article content',lines:5),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:saveArticle,child:const Text('Publish article')))
    ]),
    section('Publish announcement',Icons.notifications_active,[
      field(noticeTitle,'Announcement title'),field(noticeBody,'Message',lines:3),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:saveNotice,child:const Text('Publish to all users')))
    ]),
    section('Add result history record',Icons.fact_check,[
      field(source,'Source / provider'),field(resultLabel,'Result label'),field(resultValue,'Result value (optional)'),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:saveResult,child:const Text('Save result record'))),
      const SizedBox(height:6),const Text('Records are entered manually and are not independently verified by this app. Check the original source; no live API is connected.',style:TextStyle(color:Colors.orangeAccent))
    ]),
  ]));
}


class VipMembershipPage extends StatelessWidget {
  const VipMembershipPage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('VIP Membership')),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(Icons.workspace_premium,color:accent,size:38),SizedBox(height:12),
        Text('TRADE AR MONEY VIP',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900)),
        SizedBox(height:8),Text('Membership section ready for future authorized features. No paid membership or payment gateway is active in this build.')
      ])),
      const SizedBox(height:14),
      const Card(color:panel,child:ListTile(leading:Icon(Icons.insights,color:accent),title:Text('Analytics'),subtitle:Text('Requires a verified data source and tested analytics model.'))),
      const Card(color:panel,child:ListTile(leading:Icon(Icons.history,color:accent),title:Text('History'),subtitle:Text('Historical records are available from the Results tab when entered by an authorized admin.'))),
      const Card(color:panel,child:ListTile(leading:Icon(Icons.support_agent,color:accent),title:Text('Support'),subtitle:Text('Use Telegram Support from the dashboard.'))),
    ]),
  );
}

class AutoBetPracticePage extends StatefulWidget {
  const AutoBetPracticePage({super.key});
  @override State<AutoBetPracticePage> createState() => _AutoBetPracticePageState();
}
class _AutoBetPracticePageState extends State<AutoBetPracticePage> {
  final List<int> capitals = [300, 500, 1000, 2000];
  final List<int> targets = [15, 30, 45, 90];
  final List<int> defaultBetByLevel = [5, 12, 29, 70, 168];
  final Map<int, List<int>> betPlans = const {
    500: [10, 23, 53, 122, 281],
    1000: [20, 46, 106, 244, 562],
    2000: [40, 92, 212, 488, 1123],
  };
  int capital = 300, targetPercent = 15, maxLevel = 5, level = 1;
  int roundNumber = 1, roundSecondsRemaining = 60;
  Timer? roundTimer;
  bool outcomeLoggedThisRound = false;
  double practicePnl = 0;
  bool running = false, stopped = false;
  String stopReason = 'Practice session not started';
  final List<String> history = [];
  double get targetAmount => capital * targetPercent / 100;
  List<int> get betByLevel => betPlans[capital] ?? defaultBetByLevel;
  int get currentPracticeBet => betByLevel[level - 1];
  double get remainingCapital => capital + practicePnl;
  double get progress => targetAmount <= 0 ? 0 : (practicePnl / targetAmount).clamp(0.0, 1.0);

  void startSession() {
    roundTimer?.cancel();
    setState(() {
      running = true; stopped = false; level = 1; practicePnl = 0;
      roundNumber = 1; roundSecondsRemaining = 60; outcomeLoggedThisRound = false;
      stopReason = 'Practice session running'; history.clear();
      history.insert(0, 'Practice session started • Capital reference ₹$capital • Target $targetPercent% • Practice only');
    });
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !running || stopped) { timer.cancel(); return; }
      setState(() {
        roundSecondsRemaining--;
        if (roundSecondsRemaining <= 0) {
          if (!outcomeLoggedThisRound) {
            history.insert(0, 'Practice round $roundNumber closed with no outcome recorded; P/L unchanged.');
          }
          roundNumber++;
          roundSecondsRemaining = 60;
          outcomeLoggedThisRound = false;
        }
      });
    });
  }
  @override void dispose() { roundTimer?.cancel(); super.dispose(); }
  void logOutcome(bool win) {
    if (!running || stopped || outcomeLoggedThisRound) return;
    final bet = currentPracticeBet;
    if (!win && remainingCapital < bet) {
      setState(() { running = false; stopped = true; stopReason = 'Practice capital limit reached — session stopped'; history.insert(0, 'Stopped: remaining practice capital is below the Level $level stake ₹$bet.'); });
      return;
    }
    // 1:1 is an illustrative simulator assumption, not a real-game payout claim.
    final delta = win ? bet.toDouble() : -bet.toDouble();
    setState(() {
      practicePnl += delta;
      outcomeLoggedThisRound = true;
      history.insert(0, 'Round $roundNumber • Level $level • Practice stake ₹$bet • ${win ? 'WIN' : 'LOSS'} • ${delta >= 0 ? '+' : '-'}₹${delta.abs().toStringAsFixed(2)} simulated P/L (illustrative 1:1)');
      if (practicePnl >= targetAmount) {
        running = false; stopped = true; stopReason = 'Target reached — practice stopped';
      } else if (win) {
        level = 1;
      } else if (level >= maxLevel) {
        running = false; stopped = true; stopReason = 'Level $maxLevel loss limit reached — practice stopped';
      } else {
        level += 1;
      }
      if (running && remainingCapital < currentPracticeBet) {
        running = false; stopped = true; stopReason = 'Remaining practice capital is below the next level stake — session stopped';
      }
      if (!running || stopped) roundTimer?.cancel();
    });
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Auto Bet • Practice Controls')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Card(color: panel, child: const Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.shield_outlined, color: accent), SizedBox(width: 8), Expanded(child: Text('PRACTICE SIMULATOR ONLY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))]),
        SizedBox(height: 8),
        Text('यह स्क्रीन केवल काल्पनिक practice outcomes दर्ज करती है। यह कोई prediction नहीं बनाती, पैसे नहीं लगाती, wallet/payment नहीं खोलती और किसी बाहरी website पर bet submit नहीं करती।'),
      ]))),
      const SizedBox(height: 16),
      const Text('Capital reference', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: capitals.map((value) => ChoiceChip(label: Text('₹$value'), selected: capital == value, onSelected: running ? null : (_) => setState(() => capital = value))).toList()),
      const SizedBox(height: 8),
      Text('Selected stake plan: ${betByLevel.map((amount) => '₹$amount').join(' / ')}', style: const TextStyle(color: Colors.white70)),
      if (capital == 300) const Text('₹300 is the legacy practice plan; custom plans are set for ₹500, ₹1,000 and ₹2,000.', style: TextStyle(color: Colors.orangeAccent)),
      const SizedBox(height: 16),
      const Text('Practice target', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: targets.map((value) => ChoiceChip(label: Text('$value%  (₹${(capital * value / 100).toStringAsFixed(0)})'), selected: targetPercent == value, onSelected: running ? null : (_) => setState(() => targetPercent = value))).toList()),
      const SizedBox(height: 16),
      const Text('Maximum practice loss level', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [1,2,3,4,5].map((value) => ChoiceChip(label: Text('Level $value'), selected: maxLevel == value, onSelected: running ? null : (_) => setState(() { maxLevel = value; if (level > maxLevel) level = maxLevel; }))).toList()),
      const SizedBox(height: 18),
      Card(color: panel, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Session status', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Text(stopReason, style: TextStyle(color: stopped ? Colors.orangeAccent : accent, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), Text('Practice round: $roundNumber'),
        Text('Round timer: ${roundSecondsRemaining ~/ 60}:${(roundSecondsRemaining % 60).toString().padLeft(2, '0')}'),
        Text(outcomeLoggedThisRound ? 'This round outcome is already recorded.' : 'One practice outcome can be recorded per round.'),
        const SizedBox(height: 8), Text('Current practice level: $level / $maxLevel'),
        Text('Current practice stake: ₹$currentPracticeBet'),
        Text('Five-level plan: ${betByLevel.map((amount) => '₹$amount').join(' → ')}'),
        Text('Total of five stakes: ₹${betByLevel.fold<int>(0, (sum, amount) => sum + amount)}'),
        Text('Remaining capital reference: ₹${remainingCapital.toStringAsFixed(2)}'),
        Text('Simulated P/L: ${practicePnl >= 0 ? '+' : '-'}₹${practicePnl.abs().toStringAsFixed(2)}'),
        Text('Target: ₹${targetAmount.toStringAsFixed(2)} ($targetPercent%)'),
        const SizedBox(height: 10), LinearProgressIndicator(value: progress, minHeight: 7),
      ]))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: running ? null : startSession, icon: const Icon(Icons.play_arrow), label: Text(stopped ? 'Start new practice session' : 'Start practice session'))),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: running && !outcomeLoggedThisRound ? () => logOutcome(true) : null, icon: const Icon(Icons.check_circle_outline), label: const Text('Log practice win'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: running && !outcomeLoggedThisRound ? () => logOutcome(false) : null, icon: const Icon(Icons.cancel_outlined), label: const Text('Log practice loss'))),
      ]),
      const SizedBox(height: 18), const Text('Practice history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      if (history.isEmpty) const Text('Session शुरू करने के बाद practice entries यहाँ दिखेंगी।', style: TextStyle(color: Colors.white70)),
      ...history.take(12).map((entry) => Card(color: panel, child: Padding(padding: const EdgeInsets.all(12), child: Text(entry)))),
    ]),
  );
}
