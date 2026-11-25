import 'package:flutter/material.dart';

import '../services/legal_acceptance_service.dart';
import '../theme/auvix_theme.dart';
import 'navigation_screen.dart';

class LegalGateScreen extends StatefulWidget {
  const LegalGateScreen({super.key});

  @override
  State<LegalGateScreen> createState() => _LegalGateScreenState();
}

class _LegalGateScreenState extends State<LegalGateScreen> {
  late Future<bool> _acceptanceFuture;

  @override
  void initState() {
    super.initState();
    _loadAcceptance();
  }

  void _loadAcceptance() {
    _acceptanceFuture = LegalAcceptanceService.hasCurrentAcceptance();
  }

  void _retry() {
    setState(_loadAcceptance);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _acceptanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 48,
                      color: AuvixTheme.accent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível verificar a aceitação dos documentos.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainNavigationScreen();
        }

        return const LegalAcceptanceScreen();
      },
    );
  }
}

class LegalAcceptanceScreen extends StatefulWidget {
  const LegalAcceptanceScreen({super.key});

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  bool _accepted = false;
  bool _loading = false;

  Future<void> _acceptDocuments() async {
    if (!_accepted || _loading) return;

    setState(() => _loading = true);

    try {
      await LegalAcceptanceService.registerCurrentAcceptance();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível registrar o aceite. Verifique sua conexão e tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openDocument(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Atualização dos documentos'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: AuvixTheme.accent,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Precisamos da sua confirmação',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Para continuar usando o AMBUX, leia e aceite os documentos atualizados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AuvixTheme.muted),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => _openDocument('Termos de Uso'),
                    child: const Text('Ler Termos de Uso'),
                  ),
                  OutlinedButton(
                    onPressed: () => _openDocument('Política de Privacidade'),
                    child: const Text('Ler Política de Privacidade'),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: _accepted,
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() => _accepted = value ?? false);
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Li e aceito os Termos de Uso e a Política de Privacidade.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _accepted && !_loading ? _acceptDocuments : null,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ACEITAR E CONTINUAR'),
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
