import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://sjpgqjxllpjqwsllrzya.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_VUzeFLr_Da61_gz_D6i1GA_1TMv5Seh');
const supportUrl = 'https://t.me/+pmahyzLfcMA2ODZl';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const TradeArMoneyApp());
}
const accent = Color(0xFF9BE7A5);
const background = Color(0xFF0E1712);
const panel = Color(0xFF18251C);

class TradeArMoneyApp extends StatelessWidget {
  const TradeArMoneyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TRADE AR MONEY', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark)),
    home: const HomePage(),
  );
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab=0;
  final email=TextEditingController(), password=TextEditingController();
  Future<void> support() async {
    final ok=await launchUrl(Uri.parse(supportUrl), mode: LaunchMode.externalApplication);
    if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telegram link could not be opened.')));
  }
  Future<void> auth(bool signup) async {
    try {
      final c=Supabase.instance.client.auth;
      if (signup) { await c.signUp(email: email.text.trim(), password: password.text); }
      else { await c.signInWithPassword(email: email.text.trim(), password: password.text); }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(signup?'Sign-up request sent. Check email if confirmation is enabled.':'Login successful.')));
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication failed: $e')));
    }
  }
  @override Widget build(BuildContext context) {
    final pages=<Widget>[
      ListView(padding: const EdgeInsets.all(18), children:[
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors:[Color(0xFF294B32),Color(0xFF101B13)])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Icon(Icons.auto_graph,color:accent,size:32), SizedBox(height:12),
            Text('TRADE AR MONEY',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
            SizedBox(height:8), Text('Learn the market. Understand the risk. Make informed decisions.'),
            SizedBox(height:14), Text('Live data is not connected. No real-time results or guaranteed predictions are shown.',style:TextStyle(color:Colors.white70))
          ])),
        const SizedBox(height:18), const Text('QUICK ACCESS',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height:10), Card(color:panel,child:const ListTile(leading:Icon(Icons.school,color:accent),title:Text('Learn & Guides'),subtitle:Text('Market basics, probability and risk awareness.'))),
        Card(color:panel,child:const ListTile(leading:Icon(Icons.history,color:accent),title:Text('Results History'),subtitle:Text('Available after an authorized, verified data source is connected.'))),
        Card(color:panel,child:ListTile(leading:const Icon(Icons.support_agent,color:accent),title:const Text('Customer Support'),subtitle:const Text('Contact us on Telegram'),onTap:support)),
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('LEARN',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const Card(color:panel,child:ListTile(title:Text('Probability & uncertainty'),subtitle:Text('Past outcomes do not determine the next result.'))),
        const Card(color:panel,child:ListTile(title:Text('Risk management'),subtitle:Text('Never rely on guaranteed-profit claims or borrow to speculate.'))),
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('COMMUNITY & SUPPORT',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const Card(color:panel,child:ListTile(leading:Icon(Icons.groups,color:accent),title:Text('TRADE AR MONEY Telegram'),subtitle:Text('Join the community or contact customer support.'))),
        FilledButton.icon(onPressed:support,icon:const Icon(Icons.send),label:const Text('Open Telegram channel')),
        OutlinedButton.icon(onPressed:support,icon:const Icon(Icons.support_agent),label:const Text('Customer Support on Telegram')),
      ]),
      ListView(padding:const EdgeInsets.all(18),children:[
        const Text('ACCOUNT',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email',border:OutlineInputBorder())),
        const SizedBox(height:12), TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password',border:OutlineInputBorder())),
        const SizedBox(height:12), FilledButton(onPressed:()=>auth(false),child:const Text('Log in')),
        OutlinedButton(onPressed:()=>auth(true),child:const Text('Sign up')),
        OutlinedButton.icon(onPressed:support,icon:const Icon(Icons.support_agent),label:const Text('Contact support')),
        const SizedBox(height:14), const Text('Admin access requires server-side role policies. Do not put service-role secrets in the app.',style:TextStyle(color:Colors.white60)),
      ]),
    ];
    return Scaffold(appBar:AppBar(title:const Text('TRADE AR MONEY',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(onPressed:support,tooltip:'Customer Support',icon:const Icon(Icons.support_agent,color:accent))]),
      body:pages[tab],bottomNavigationBar:NavigationBar(backgroundColor:panel,selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),label:'Home'),
        NavigationDestination(icon:Icon(Icons.menu_book_outlined),label:'Learn'),
        NavigationDestination(icon:Icon(Icons.groups_outlined),label:'Community'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Account'),
      ]));
  }
}
