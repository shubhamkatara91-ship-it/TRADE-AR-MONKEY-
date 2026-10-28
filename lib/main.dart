import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://sjpgqjxllpjqwsllrzya.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_VUzeFLr_Da61_gz_D6i1GA_1TMv5Seh');
const supportUrl = 'https://t.me/+pmahyzLfcMA2ODZl';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const TradeArMoneyApp());
}

const accent = Color(0xFF9BE7A5);
const background = Color(0xFF0E1712);
const panel = Color(0xFF18251C);

class TradeArMoneyApp extends StatelessWidget {
  const TradeArMoneyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TRADE AR MONEY',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  bool showPassword = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> openSupport() async {
    final ok = await launchUrl(Uri.parse(supportUrl), mode: LaunchMode.externalApplication);
    if (!ok) message('Telegram link could not be opened. Please check that Telegram is installed.');
  }

  Future<void> auth(bool signup) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => busy = true);
    try {
      final client = Supabase.instance.client.auth;
      if (signup) {
        final response = await client.signUp(email: email.text.trim(), password: password.text);
        if (response.session == null) {
          message('Signup request submitted. Check your email if confirmation is enabled.');
        } else {
          message('Account created successfully.');
        }
      } else {
        await client.signInWithPassword(email: email.text.trim(), password: password.text);
        message('Login successful.');
      }
      if (mounted) setState(() {});
    } on AuthException catch (e) {
      message(e.message);
    } catch (_) {
      message('Could not connect. Check your internet and Supabase configuration.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    final address = email.text.trim();
    if (address.isEmpty || !address.contains('@')) {
      message('Enter your email address first, then tap Forgot password.');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(address);
      message('If the account exists, a password-reset email will be sent.');
    } on AuthException catch (e) {
      message(e.message);
    } catch (_) {
      message('Password reset could not be requested. Check your connection.');
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) setState(() {});
      message('You are logged out.');
    } on AuthException catch (e) {
      message(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final pages = <Widget>[
      ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF294B32), Color(0xFF101B13)]),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.auto_graph, color: accent, size: 32),
            SizedBox(height: 12),
            Text('TRADE AR MONEY', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('Learn the market. Understand the risk. Make informed decisions.'),
            SizedBox(height: 14),
            Text('Educational content only. Live data is not connected; no real-time results or guaranteed predictions are provided.',
              style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('QUICK ACCESS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.school, color: accent), title: Text('Learn & Guides'), subtitle: Text('Market basics, probability and risk awareness.'))),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.history, color: accent), title: Text('Results History'), subtitle: Text('No verified live data source is connected yet.'))),
        Card(color: panel, child: ListTile(leading: const Icon(Icons.support_agent, color: accent), title: const Text('Customer Support'), subtitle: const Text('Contact us on Telegram'), onTap: openSupport)),
        if (user != null) Card(color: panel, child: ListTile(leading: const Icon(Icons.verified_user, color: accent), title: const Text('Signed in'), subtitle: Text(user.email ?? 'Account active'))),
      ]),
      ListView(padding: const EdgeInsets.all(18), children: [
        const Text('LEARN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.casino_outlined, color: accent), title: Text('Probability & uncertainty'), subtitle: Text('A past outcome does not determine the next outcome.'))),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.shield_outlined, color: accent), title: Text('Risk management'), subtitle: Text('Avoid guaranteed-profit claims and never borrow to speculate.'))),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.menu_book_outlined, color: accent), title: Text('Learning plan'), subtitle: Text('Learn terminology, risk, diversification and how to evaluate sources.'))),
      ]),
      ListView(padding: const EdgeInsets.all(18), children: [
        const Text('COMMUNITY & SUPPORT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Card(color: panel, child: ListTile(leading: Icon(Icons.groups, color: accent), title: Text('TRADE AR MONEY Telegram'), subtitle: Text('Open the provided Telegram community link.'))),
        FilledButton.icon(onPressed: openSupport, icon: const Icon(Icons.send), label: const Text('Open Telegram')),
        const SizedBox(height: 8),
        const Text('The current configuration uses one Telegram link for both community and support.', style: TextStyle(color: Colors.white60)),
      ]),
      ListView(padding: const EdgeInsets.all(18), children: [
        const Text('ACCOUNT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        if (user == null) ...[
          const SizedBox(height: 8),
          const Text('Create an account or log in. Internet access and a configured Supabase project are required.'),
          const SizedBox(height: 16),
          Form(key: formKey, child: Column(children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty || !value.contains('@') || !value.contains('.')) return 'Enter a valid email address.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: password,
              obscureText: !showPassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  tooltip: showPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) {
                if ((v ?? '').length < 8) return 'Use at least 8 characters.';
                return null;
              },
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: busy ? null : () => auth(false),
              child: Text(busy ? 'Please wait…' : 'Log in'),
            )),
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: busy ? null : () => auth(true),
              child: const Text('Create account'),
            )),
            TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
          ])),
        ] else ...[
          Card(color: panel, child: ListTile(leading: const Icon(Icons.account_circle, color: accent), title: const Text('Signed in as'), subtitle: Text(user.email ?? 'Email unavailable'))),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: logout, icon: const Icon(Icons.logout), label: const Text('Log out'))),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: openSupport, icon: const Icon(Icons.support_agent), label: const Text('Contact support')),
        const SizedBox(height: 14),
        const Text('Admin access must be controlled by verified server-side roles and policies. Never put service-role secrets in the mobile app.', style: TextStyle(color: Colors.white60)),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRADE AR MONEY', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: openSupport, tooltip: 'Customer Support', icon: const Icon(Icons.support_agent, color: accent))],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}
