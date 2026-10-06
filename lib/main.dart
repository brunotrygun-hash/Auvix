import 'package:flutter/material.dart';
import 'theme/auvix_theme.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuvixApp());
}

class AuvixApp extends StatelessWidget {
  const AuvixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AUVIX',
      debugShowCheckedModeBanner: false,
      theme: AuvixTheme.dark(),
      home: const LoginScreen(),
    );
  }
}
