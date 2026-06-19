import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'providers/firebase_provider.dart';
import 'pages/landing_page.dart';
import 'pages/success_page.dart';
import 'pages/admin_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Automatically sign users in anonymously when entering the website
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.signInAnonymously();
    } catch (e) {
      debugPrint('Error during anonymous sign-in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUOP | Where Skills Meet Opportunities',
      debugShowCheckedModeBanner: false,
      theme: MUOPTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/success': (context) => const SuccessPage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}
