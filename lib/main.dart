import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/auvix_theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/legal_gate_screen.dart';
import 'screens/password_recovery_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError('Configurações do Supabase não encontradas.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const AuvixApp());
}

class AuvixApp extends StatefulWidget {
  const AuvixApp({super.key});

  @override
  State<AuvixApp> createState() => _AuvixAppState();
}

class _AuvixAppState extends State<AuvixApp> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;

        setState(() {
          _isPasswordRecovery = data.event == AuthChangeEvent.passwordRecovery;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Erro no estado de autenticação: $error');
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _finishPasswordRecovery() {
    if (!mounted) return;
    setState(() => _isPasswordRecovery = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'AUVIX',
      debugShowCheckedModeBanner: false,
      theme: AuvixTheme.dark(),
      home: _isPasswordRecovery
          ? PasswordRecoveryScreen(onCompleted: _finishPasswordRecovery)
          : session != null
          ? const LegalGateScreen()
          : const OnboardingScreen(),
    );
  }
}
