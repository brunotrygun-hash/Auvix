import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/auvix_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<IconData> _avatarIcons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.mood_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.emoji_emotions_rounded,
    Icons.account_circle_rounded,
    Icons.person_outline_rounded,
    Icons.tag_faces_rounded,
    Icons.child_friendly_rounded,
    Icons.support_agent_rounded,
    Icons.psychology_rounded,
    Icons.workspace_premium_rounded,
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF19E6B0),
    Color(0xFF56B4E9),
    Color(0xFFB39DDB),
    Color(0xFFFFB74D),
    Color(0xFFF48FB1),
    Color(0xFF80CBC4),
    Color(0xFF90CAF9),
    Color(0xFFFF8A65),
    Color(0xFFAED581),
    Color(0xFFCE93D8),
    Color(0xFFFFD54F),
    Color(0xFF80DEEA),
  ];

  int _selectedAvatar = 0;
  bool _loading = true;
  bool _sendingReset = false;

  User? get _user => Supabase.instance.client.auth.currentUser;

  String get _storageKey {
    final userId = _user?.id ?? 'unknown';
    return 'auvix_profile_avatar_$userId';
  }

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final preferences = await SharedPreferences.getInstance();
    final savedAvatar = preferences.getInt(_storageKey) ?? 0;

    if (!mounted) return;

    setState(() {
      _selectedAvatar = savedAvatar >= 0 && savedAvatar < _avatarIcons.length
          ? savedAvatar
          : 0;
      _loading = false;
    });
  }

  Future<void> _saveAvatar(int index) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_storageKey, index);

    if (!mounted) return;

    setState(() => _selectedAvatar = index);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar atualizado com sucesso!')),
    );
  }

  Future<void> _chooseAvatar() async {
    int temporarySelection = _selectedAvatar;

    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AuvixTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateSheet) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AuvixTheme.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Escolha seu avatar',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione uma opção para representar seu perfil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AuvixTheme.muted),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 220,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _avatarIcons.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          final selected = temporarySelection == index;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              updateSheet(() => temporarySelection = index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AuvixTheme.surface2,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected
                                      ? AuvixTheme.accent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    _avatarIcons[index],
                                    size: 38,
                                    color: _avatarColors[index],
                                  ),
                                  if (selected)
                                    const Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AuvixTheme.accent,
                                        size: 17,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(temporarySelection),
                        child: const Text('Confirmar avatar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      await _saveAvatar(result);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email;

    if (email == null || email.isEmpty) {
      _showMessage('Não foi possível identificar o e-mail da conta.');
      return;
    }

    setState(() => _sendingReset = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (!mounted) return;

      _showMessage('Enviamos as instruções de redefinição para $email.');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(
        'Não foi possível solicitar a redefinição: ${error.message}',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Erro ao solicitar a redefinição. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _sendingReset = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      color: AuvixTheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Icon(icon, color: AuvixTheme.accent, size: 26),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AuvixTheme.muted),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? 'E-mail não disponível';

    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: AuvixTheme.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AuvixTheme.accent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _avatarIcons[_selectedAvatar],
                          size: 62,
                          color: _avatarColors[_selectedAvatar],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Minha conta',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AuvixTheme.muted),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AuvixTheme.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Conta conectada',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _chooseAvatar,
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Alterar avatar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuvixTheme.accent,
                          side: const BorderSide(color: AuvixTheme.accent),
                          minimumSize: const Size(190, 48),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'DADOS DA CONTA',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _profileOption(
                  icon: Icons.email_outlined,
                  title: 'E-mail cadastrado',
                  subtitle: email,
                  trailing: const Icon(
                    Icons.verified_user_outlined,
                    color: AuvixTheme.accent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SEGURANÇA',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _profileOption(
                  icon: Icons.lock_outline_rounded,
                  title: 'Redefinir senha',
                  subtitle: 'Receba um link no seu e-mail',
                  onTap: _sendingReset ? null : _sendPasswordReset,
                  trailing: _sendingReset
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                ),
                const SizedBox(height: 10),
                _profileOption(
                  icon: Icons.shield_outlined,
                  title: 'Segurança da conta',
                  subtitle: 'Sua conta é protegida pelo Supabase',
                  onTap: () {
                    _showMessage(
                      'A autenticação da conta é gerenciada pelo Supabase.',
                    );
                  },
                ),
              ],
            ),
    );
  }
}
