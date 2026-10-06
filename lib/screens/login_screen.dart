import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';
import 'portfolio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PortfolioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  const _AuvixBrand(large: true),
                  const SizedBox(height: 56),
                  const Text('Entrar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Acompanhe seus investimentos em um só lugar.', style: TextStyle(color: AuvixTheme.muted)),
                  const SizedBox(height: 28),
                  TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', hintText: 'voce@email.com')),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => obscure = !obscure)),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(onPressed: _login, child: const Text('Entrar')),
                  const SizedBox(height: 18),
                  TextButton(onPressed: () {}, child: const Text('Criar conta')),
                  const SizedBox(height: 42),
                  const Center(child: Text('Modo demonstração: qualquer e-mail e senha entram.', style: TextStyle(color: AuvixTheme.muted, fontSize: 12))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuvixBrand extends StatelessWidget {
  final bool large;
  const _AuvixBrand({this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.trending_up_rounded, color: AuvixTheme.accent, size: large ? 72 : 34),
        const SizedBox(height: 4),
        Text('AUVIX', style: TextStyle(fontSize: large ? 42 : 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
        const SizedBox(height: 4),
        Text('Seu dinheiro em movimento.', style: TextStyle(color: AuvixTheme.muted, fontSize: large ? 15 : 11)),
      ],
    );
  }
}
