import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/auvix_theme.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const PasswordRecoveryScreen({super.key, required this.onCompleted});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _savePassword() async {
    final password = _passwordController.text;
    final confirmation = _confirmController.text;

    if (password.length < 6) {
      _showMessage('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    if (password != confirmation) {
      _showMessage('As senhas não coincidem.');
      return;
    }

    setState(() => _saving = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (!mounted) return;

      _showMessage('Senha atualizada com sucesso!');
      widget.onCompleted();
    } on AuthException catch (error) {
      _showMessage('Não foi possível atualizar a senha: ${error.message}');
    } catch (_) {
      _showMessage('Erro ao atualizar a senha. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova senha'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 64,
                    color: AuvixTheme.accent,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crie sua nova senha',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Escolha uma senha nova para acessar sua conta AMBUX.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AuvixTheme.muted),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _passwordController,
                    enabled: !_saving,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmController,
                    enabled: !_saving,
                    obscureText: _obscureConfirm,
                    onSubmitted: (_) {
                      if (!_saving) _savePassword();
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirme a nova senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _savePassword,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar nova senha'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
