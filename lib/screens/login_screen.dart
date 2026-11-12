import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/auvix_theme.dart';
import 'navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  bool isCreatingAccount = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  String _friendlyAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }

    if (message.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }

    if (message.contains('user already registered')) {
      return 'Este e-mail já possui uma conta. Faça login.';
    }

    if (message.contains('password should be at least')) {
      return 'A senha não atende ao tamanho mínimo exigido.';
    }

    return error.message;
  }

  Future<void> _submit() async {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (isCreatingAccount && fullName.isEmpty) {
      _showMessage('Informe seu nome para criar a conta.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Informe um endereço de e-mail válido.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Informe sua senha.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = Supabase.instance.client.auth;

      if (isCreatingAccount) {
        final response = await auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );

        if (!mounted) return;

        if (response.session != null) {
          _showMessage('Conta criada com sucesso!');
          _openApp();
        } else {
          setState(() => isCreatingAccount = false);
          _showMessage(
            'Conta criada! Confira seu e-mail para confirmar o cadastro.',
          );
        }
      } else {
        final response = await auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (response.session != null) {
          _openApp();
        } else {
          _showMessage('Não foi possível iniciar a sessão.');
        }
      }
    } on AuthException catch (error) {
      _showMessage(_friendlyAuthError(error));
    } catch (_) {
      _showMessage(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      isCreatingAccount = !isCreatingAccount;
    });
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
                  Text(
                    isCreatingAccount ? 'Criar conta' : 'Entrar',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCreatingAccount
                        ? 'Crie sua conta para começar a usar o AUVIX.'
                        : 'Acompanhe seus investimentos em um só lugar.',
                    style: const TextStyle(color: AuvixTheme.muted),
                  ),
                  const SizedBox(height: 28),
                  if (isCreatingAccount) ...[
                    TextField(
                      controller: nameController,
                      enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Como deseja ser chamado?',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'voce@email.com',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    enabled: !isLoading,
                    obscureText: obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!isLoading) _submit();
                    },
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isCreatingAccount ? 'Criar conta' : 'Entrar'),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: isLoading ? null : _toggleMode,
                    child: Text(
                      isCreatingAccount
                          ? 'Já tenho uma conta. Entrar'
                          : 'Criar conta',
                    ),
                  ),
                  const SizedBox(height: 42),
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
        Icon(
          Icons.trending_up_rounded,
          color: AuvixTheme.accent,
          size: large ? 72 : 34,
        ),
        const SizedBox(height: 4),
        Text(
          'AUVIX',
          style: TextStyle(
            fontSize: large ? 42 : 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Seu dinheiro em movimento.',
          style: TextStyle(color: AuvixTheme.muted, fontSize: large ? 15 : 11),
        ),
      ],
    );
  }
}
