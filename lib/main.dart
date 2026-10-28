import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://sjpgqjxllpjqwsllrzya.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_VUzeFLr_Da61_gz_D6i1GA_1TMv5Seh');
const supportUrl = 'https://t.me/+pmahyzLfcMA2ODZl';
const accent = Color(0xFF9BE7A5), background = Color(0xFF0E1712), panel = Color(0xFF18251C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const TradeArMoneyApp());
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
  int tab=0; bool busy=false, showPassword=false;
  final email=TextEditingController(), password=TextEditingController();
  final formKey=GlobalKey<FormState>();
  final client=Supabase.instance.client;
  @override void dispose(){email.dispose();password.dispose();super.dispose();}
  void msg(String s){if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  Future<void> support() async { final ok=await launchUrl(Uri.parse(supportUrl),mode:LaunchMode.externalApplication); if(!ok) msg('Telegram link नहीं खुला।'); }
  Future<void> openDocument(String url) async {
    final ok=await launchUrl(Uri.parse(url),mode:LaunchMode.externalApplication);
    if(!ok) msg('लिंक नहीं खुला। इंटरनेट कनेक्शन जाँचें।');
  }
  Future<void> auth(bool signup) async {
    if(!(formKey.currentState?.validate()??false)) return;
    setState(()=>busy=true);
    try {
      if(signup){final r=await client.auth.signUp(email:email.text.trim(),password:password.text);msg(r.session==null?'Signup request भेजी गई। Email confirmation चालू हो तो email देखें।':'Account बन गया।');}
      else {await client.auth.signInWithPassword(email:email.text.trim(),password:password.text);msg('Login सफल।');}
      if(mounted)setState((){});
    } on AuthException catch(e){msg(e.message);} catch(_){msg('कनेक्शन नहीं हुआ। Supabase सेटिंग और इंटरनेट जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> resetPassword() async {
    final e=email.text.trim(); if(!e.contains('@')){msg('पहले सही email लिखें।');return;}
    try{await client.auth.resetPasswordForEmail(e);msg('यदि account मौजूद है तो reset email भेजा जाएगा.');}
    on AuthException catch(x){msg(x.message);} catch(_){msg('Reset request नहीं भेजी जा सकी।');}
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
    if(rows.isEmpty)return ListView(padding:const EdgeInsets.all(24),children:const [Icon(Icons.history,size:42,color:accent),SizedBox(height:12),Text('Results History',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('अभी कोई verified result रिकॉर्ड नहीं है। डेटा स्रोत सत्यापित होने के बाद रिकॉर्ड यहाँ दिखेंगे।')]);
    return ListView(padding:const EdgeInsets.all(16),children:[const Text('RESULTS HISTORY',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),...rows.map((r)=>Card(color:panel,child:ListTile(leading:const Icon(Icons.history,color:accent),title:Text('${r['result_label']}'),subtitle:Text('${r['source']} • ${r['observed_at']}'),trailing:Text('${r['result_value']??''}'))))]);
  }));
  Widget notificationsPage()=>RefreshIndicator(onRefresh:()async{setState((){});await loadNotifications();},child:FutureBuilder<List<Map<String,dynamic>>>(future:loadNotifications(),builder:(context,s){
    if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
    if(s.hasError)return ListView(children:[errorBox(s.error!)]);
    final rows=s.data??[];
    if(rows.isEmpty)return ListView(padding:const EdgeInsets.all(24),children:const [Icon(Icons.notifications_none,size:42,color:accent),SizedBox(height:12),Text('Notifications',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('अभी कोई notification नहीं है। Admin द्वारा प्रकाशित संदेश यहाँ दिखेंगे। यह in-app notification feed है; push notification के लिए Firebase सेटअप अलग से आवश्यक है।')]);
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
        Card(color:panel,child:ListTile(leading:const Icon(Icons.school,color:accent),title:const Text('Learn & Guides'),subtitle:const Text('Market basics, probability and risk'),onTap:()=>setState(()=>tab=1))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.history,color:accent),title:const Text('Results History'),subtitle:const Text('View verified records from database'),onTap:()=>setState(()=>tab=2))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.notifications,color:accent),title:const Text('Notifications'),subtitle:const Text('Read in-app announcements'),onTap:()=>setState(()=>tab=3))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.support_agent,color:accent),title:const Text('Telegram Support'),subtitle:const Text('Open Telegram'),onTap:support)),
        if(user!=null)Card(color:panel,child:ListTile(leading:const Icon(Icons.verified_user,color:accent),title:const Text('Signed in'),subtitle:Text(user.email??'Account active'))),
      ]),
      learningPage(),
      resultsPage(),
      notificationsPage(),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('COMMUNITY',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const Card(color:panel,child:ListTile(leading:Icon(Icons.groups,color:accent),title:Text('TRADE AR MONEY Telegram'),subtitle:Text('Community and support currently use the configured Telegram invite link.'))),
        FilledButton.icon(onPressed:support,icon:const Icon(Icons.send),label:const Text('Open Telegram')),
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('ACCOUNT',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        if(user==null)...[
          const SizedBox(height:8),const Text('Account बनाने या login करने के लिए email और password डालें.'),
          const SizedBox(height:16),Form(key:formKey,child:Column(children:[
            TextFormField(controller:email,keyboardType:TextInputType.emailAddress,autofillHints:const[AutofillHints.email],decoration:const InputDecoration(labelText:'Email'),validator:(v){final x=(v??'').trim();return x.contains('@')&&x.contains('.')?null:'सही email लिखें।';}),
            const SizedBox(height:12),TextFormField(controller:password,obscureText:!showPassword,decoration:InputDecoration(labelText:'Password',suffixIcon:IconButton(onPressed:()=>setState(()=>showPassword=!showPassword),icon:Icon(showPassword?Icons.visibility_off:Icons.visibility))),validator:(v)=>(v??'').length<8?'कम-से-कम 8 अक्षर लिखें।':null),
            const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:()=>auth(false),child:Text(busy?'Please wait…':'Log in'))),
            SizedBox(width:double.infinity,child:OutlinedButton(onPressed:busy?null:()=>auth(true),child:const Text('Create account'))),
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
        const SizedBox(height:14),OutlinedButton.icon(onPressed:support,icon:const Icon(Icons.support_agent),label:const Text('Contact support')),
        const SizedBox(height:14),
        const Text('LEGAL & PRIVACY',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
        ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.privacy_tip_outlined,color:accent),title:const Text('Privacy Policy'),subtitle:const Text('Review data handling information'),onTap:()=>openDocument('https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/blob/main/docs/PRIVACY_POLICY.md')),
        ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.description_outlined,color:accent),title:const Text('Terms of Use'),subtitle:const Text('Review app terms and limitations'),onTap:()=>openDocument('https://github.com/shubhamkatara91-ship-it/TRADE-AR-MONKEY-/blob/main/docs/TERMS_OF_USE.md')),
        const SizedBox(height:14),const Text('Admin access must be granted securely in the database. Never place service-role secrets in the app.',style:TextStyle(color:Colors.white60)),
      ]),
    ];
    return Scaffold(appBar:AppBar(title:const Text('TRADE AR MONEY',style:TextStyle(fontWeight:FontWeight.w900)),actions:[
      IconButton(onPressed:()=>setState(()=>tab=3),tooltip:'Notifications',icon:const Icon(Icons.notifications_outlined,color:accent)),
      IconButton(onPressed:support,tooltip:'Telegram Support',icon:const Icon(Icons.support_agent,color:accent))]),
      body:pages[tab],bottomNavigationBar:NavigationBar(backgroundColor:panel,selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'Home'),
        NavigationDestination(icon:Icon(Icons.menu_book_outlined),label:'Learn'),
        NavigationDestination(icon:Icon(Icons.history),label:'Results'),
        NavigationDestination(icon:Icon(Icons.notifications_outlined),label:'Alerts'),
        NavigationDestination(icon:Icon(Icons.groups_outlined),label:'Community'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Account'),
      ]));
  }
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
    try{await widget.client.from('app_notifications').insert({'title':noticeTitle.text.trim(),'body':noticeBody.text.trim(),'audience':'all'});noticeTitle.clear();noticeBody.clear();message('Announcement publish हो गया।');}
    catch(e){message('Save नहीं हुआ। Admin role और database schema जाँचें।');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> saveResult() async {
    if(source.text.trim().isEmpty||resultLabel.text.trim().isEmpty){message('Source और result label आवश्यक हैं।');return;}
    setState(()=>busy=true);
    try{await widget.client.from('result_history').insert({'source':source.text.trim(),'result_label':resultLabel.text.trim(),'result_value':resultValue.text.trim().isEmpty?null:resultValue.text.trim(),'observed_at':DateTime.now().toUtc().toIso8601String()});source.clear();resultLabel.clear();resultValue.clear();message('Record save हुआ। केवल verified source का result दर्ज करें।');}
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
    section('Add verified result record',Icons.fact_check,[
      field(source,'Source / provider'),field(resultLabel,'Result label'),field(resultValue,'Result value (optional)'),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:busy?null:saveResult,child:const Text('Save verified record'))),
      const SizedBox(height:6),const Text('This records a verified result manually; it does not connect a live API.',style:TextStyle(color:Colors.orangeAccent))
    ]),
  ]));
}
