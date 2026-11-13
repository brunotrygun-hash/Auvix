import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';
import 'portfolio_screen.dart';
import 'money_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final GlobalKey<PortfolioScreenState> _homeKey =
      GlobalKey<PortfolioScreenState>();

  late final List<Widget> _pages = [
    PortfolioScreen(
      key: _homeKey,
      onOpenAlerts: () {
        setState(() => _selectedIndex = 2);
      },
    ),
    const MoneyScreen(),
    const AlertsScreen(),
    MoreScreen(onOpenPage: _openPage),
  ];

  Future<void> _openPage(String title) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MoreDetailScreen(title: title)));

    if (!mounted) return;
    if (title == 'Perfil') {
      await _homeKey.currentState?.refreshProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Dinheiro',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}

class _AuvixAnnouncement {
  final String id;
  final String category;
  final String title;
  final String message;
  final String date;

  const _AuvixAnnouncement({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.date,
  });
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const String _storageKey = 'auvix_read_announcement_ids';

  // Os comunicados oficiais serão cadastrados aqui quando existirem.
  List<_AuvixAnnouncement> _announcements = [];

  Set<String> _readIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  String? _loadError;

  Future<void> _loadAnnouncements() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final preferences = await SharedPreferences.getInstance();
      final savedIds = preferences.getStringList(_storageKey) ?? [];

      final rows = await Supabase.instance.client
          .from('official_announcements')
          .select('id, category, title, message, published_at')
          .eq('is_published', true)
          .order('published_at', ascending: false);

      final announcements = rows.map((row) {
        final data = Map<String, dynamic>.from(row);
        final publishedAt = DateTime.tryParse(
          data['published_at']?.toString() ?? '',
        )?.toLocal();

        final date = publishedAt == null
            ? ''
            : '${publishedAt.day.toString().padLeft(2, '0')}/'
                  '${publishedAt.month.toString().padLeft(2, '0')}/'
                  '${publishedAt.year}';

        return _AuvixAnnouncement(
          id: data['id'].toString(),
          category: data['category']?.toString() ?? 'Novidade',
          title: data['title']?.toString() ?? '',
          message: data['message']?.toString() ?? '',
          date: date,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _readIds = savedIds.toSet();
        _announcements = announcements;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = 'Erro ao carregar comunicados: ${error.toString()}';
        _loading = false;
      });
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56),
            const SizedBox(height: 16),
            Text(_loadError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadAnnouncements,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markRead(String id) async {
    if (_readIds.contains(id)) return;

    setState(() {
      _readIds.add(id);
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, _readIds.toList());
  }

  Future<void> _markAllRead() async {
    setState(() {
      _readIds.addAll(_announcements.map((item) => item.id));
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, _readIds.toList());
  }

  Future<void> _openAnnouncement(_AuvixAnnouncement item) async {
    await _markRead(item.id);

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuvixTheme.surface,
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.category} • ${item.date}',
                style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(item.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _announcements
        .where((item) => !_readIds.contains(item.id))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _buildErrorState()
          : _announcements.isEmpty
          ? _buildEmptyState()
          : _buildAnnouncementList(unreadCount),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AuvixTheme.accent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum comunicado no momento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quando houver uma atualização, novidade ou novo recurso '
              'do AUVIX, o comunicado aparecerá aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuvixTheme.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementList(int unreadCount) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Comunicados oficiais',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                child: const Text('Marcar todos como lidos'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in _announcements)
          Card(
            color: AuvixTheme.surface,
            child: ListTile(
              leading: Icon(
                item.category == 'Atualização'
                    ? Icons.system_update_rounded
                    : Icons.campaign_outlined,
                color: AuvixTheme.accent,
              ),
              title: Text(item.title),
              subtitle: Text('${item.category} • ${item.date}'),
              trailing: _readIds.contains(item.id)
                  ? Icon(Icons.check_circle_outline, color: AuvixTheme.muted)
                  : Icon(Icons.circle, color: AuvixTheme.accent, size: 11),
              onTap: () => _openAnnouncement(item),
            ),
          ),
      ],
    );
  }
}

class MoreScreen extends StatefulWidget {
  final ValueChanged<String> onOpenPage;

  const MoreScreen({super.key, required this.onOpenPage});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isSigningOut = false;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você precisará entrar novamente para acessar o AUVIX.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    setState(() => _isSigningOut = true);

    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSigningOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair da conta. Tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Perfil', Icons.person_outline_rounded),
      ('Configurações', Icons.settings_outlined),
      ('Ajuda', Icons.help_outline_rounded),
      ('Sobre o AUVIX', Icons.info_outline_rounded),
      ('Política de Privacidade', Icons.privacy_tip_outlined),
      ('Termos de Uso', Icons.description_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in items)
            Card(
              color: AuvixTheme.surface,
              child: ListTile(
                leading: Icon(item.$2, color: AuvixTheme.accent),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => widget.onOpenPage(item.$1),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            color: AuvixTheme.surface,
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: Text(
                _isSigningOut ? 'Saindo...' : 'Sair da conta',
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: _isSigningOut ? null : _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class MoreDetailScreen extends StatelessWidget {
  final String title;

  const MoreDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    if (title == 'Perfil') {
      return const ProfileScreen();
    }

    if (title == 'Configurações') {
      return const SettingsScreen();
    }

    if (title == 'Política de Privacidade' || title == 'Termos de Uso') {
      return _LegalDocumentScreen(title: title);
    }

    if (title == 'Sobre o AUVIX') {
      return const _AboutAuvixScreen();
    }

    if (title == 'Ajuda') {
      return const HelpScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Esta seção será preparada na próxima etapa.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AuvixTheme.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _notificationKey = 'auvix_official_notifications_enabled';

  bool _officialNotificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationKey) ?? true;

    if (!mounted) return;

    setState(() {
      _officialNotificationsEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    setState(() => _officialNotificationsEnabled = value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _settingsSectionTitle('Aparência'),
          Card(
            color: AuvixTheme.surface,
            child: const ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: AuvixTheme.accent),
              title: Text(
                'Tema escuro',
                style: TextStyle(color: AuvixTheme.text),
              ),
              subtitle: Text(
                'O AUVIX utiliza sempre o tema escuro.',
                style: TextStyle(color: AuvixTheme.muted),
              ),
              trailing: Icon(
                Icons.lock_outline_rounded,
                color: AuvixTheme.muted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _settingsSectionTitle('Notificações'),
          Card(
            color: AuvixTheme.surface,
            child: SwitchListTile(
              secondary: const Icon(
                Icons.notifications_active_outlined,
                color: AuvixTheme.accent,
              ),
              title: const Text(
                'Comunicados oficiais',
                style: TextStyle(color: AuvixTheme.text),
              ),
              subtitle: Text(
                _loading
                    ? 'Carregando preferência...'
                    : 'Avisos sobre novidades e atualizações do AUVIX.',
                style: const TextStyle(color: AuvixTheme.muted),
              ),
              value: _officialNotificationsEnabled,
              onChanged: _loading ? null : _saveNotificationPreference,
              activeThumbColor: AuvixTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Essa opção salva sua preferência. O envio de notificações '
              'ao celular dependerá da integração futura com o serviço '
              'de notificações do AUVIX.',
              style: TextStyle(
                color: AuvixTheme.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AuvixTheme.accent,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<_HelpTopic> _topics = [
    _HelpTopic(
      icon: Icons.rocket_launch_outlined,
      title: 'Primeiros passos',
      description:
          'Conheça as áreas do AUVIX. Use a navegação inferior para acessar '
          'Início, Dinheiro, Alertas e Mais. No menu Mais você encontra '
          'outras opções do aplicativo.',
    ),
    _HelpTopic(
      icon: Icons.trending_up_rounded,
      title: 'Carteira de investimentos',
      description:
          'Na tela inicial, acompanhe os dados da sua carteira e os ativos '
          'cadastrados. Você também pode acessar as opções de consulta e '
          'detalhamento disponíveis na própria carteira.',
    ),
    _HelpTopic(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Meus Bens',
      description:
          'Use a área Meus Bens para cadastrar e organizar bens, como casa '
          'e veículo. Informe o nome e o valor para acompanhar seu patrimônio '
          'cadastrado.',
    ),
    _HelpTopic(
      icon: Icons.savings_outlined,
      title: 'Dinheiro',
      description:
          'Registre valores reservados, defina uma meta e informe quanto '
          'pretende guardar por mês. Você pode acompanhar os valores '
          'apresentados nessa área.',
    ),
    _HelpTopic(
      icon: Icons.show_chart_rounded,
      title: 'Construa seu Patrimônio',
      description:
          'Informe o aporte mensal, a taxa mensal estimada, o prazo em meses '
          'e sua meta financeira. Toque em Simular meu patrimônio para '
          'visualizar uma projeção. Os resultados são estimativas e não '
          'representam garantia de rentabilidade.',
    ),
    _HelpTopic(
      icon: Icons.receipt_long_outlined,
      title: 'Controle de Dívidas',
      description:
          'Cadastre suas dívidas, informe os dados solicitados e acompanhe '
          'os valores. A área também permite registrar pagamentos e consultar '
          'o histórico.',
    ),
    _HelpTopic(
      icon: Icons.school_outlined,
      title: 'Aprenda a Investir',
      description:
          'Acesse a área de aprendizado para consultar as aulas e os módulos '
          'disponíveis no AUVIX. Siga o conteúdo apresentado em cada aula '
          'e utilize as atividades de aprendizado quando disponíveis.',
    ),
    _HelpTopic(
      icon: Icons.notifications_none_rounded,
      title: 'Alertas',
      description:
          'Consulte os comunicados oficiais do AUVIX sobre novidades, '
          'atualizações e novos recursos. Quando não houver comunicados '
          'publicados, a tela informará que não há novidades no momento.',
    ),
  ];

  static const List<_HelpTopic> _questions = [
    _HelpTopic(
      icon: Icons.lock_outline_rounded,
      title: 'Meus dados ficam salvos?',
      description:
          'O salvamento depende da funcionalidade utilizada. O AUVIX usa '
          'recursos de conta e armazenamento para manter informações. '
          'Confira sempre se a operação foi concluída com sucesso.',
    ),
    _HelpTopic(
      icon: Icons.calculate_outlined,
      title: 'A simulação garante o resultado?',
      description:
          'Não. A simulação de patrimônio é apenas uma estimativa baseada '
          'nos valores e na taxa informados. Resultados reais podem ser '
          'diferentes e investimentos envolvem riscos.',
    ),
    _HelpTopic(
      icon: Icons.support_agent_outlined,
      title: 'Como pedir ajuda?',
      description:
          'Se encontrar um problema, descreva o que estava fazendo e '
          'qual mensagem apareceu. Essas informações ajudam a identificar '
          'a dificuldade.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(title: const Text('Ajuda')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AuvixTheme.accent.withValues(alpha: 0.35),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AuvixTheme.accent,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'Como podemos ajudar?',
                  style: TextStyle(
                    color: AuvixTheme.text,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Encontre orientações para aproveitar melhor os recursos '
                  'do AUVIX.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'GUIA DO APLICATIVO',
            style: TextStyle(
              color: AuvixTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          for (final topic in _topics) _buildTopic(topic),
          const SizedBox(height: 22),
          const Text(
            'DÚVIDAS FREQUENTES',
            style: TextStyle(
              color: AuvixTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          for (final question in _questions) _buildTopic(question),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'AUVIX • Sua vida financeira em evolução',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopic(_HelpTopic topic) {
    return Card(
      color: AuvixTheme.surface,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: Icon(topic.icon, color: AuvixTheme.accent),
        title: Text(
          topic.title,
          style: const TextStyle(
            color: AuvixTheme.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: AuvixTheme.accent,
        collapsedIconColor: AuvixTheme.muted,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.description,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String title;
  final String description;

  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _AboutAuvixScreen extends StatelessWidget {
  const _AboutAuvixScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(title: const Text('Sobre o AUVIX')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AuvixTheme.surface2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'A',
                    style: TextStyle(
                      color: AuvixTheme.accent,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AUVIX',
                  style: TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sua vida financeira em evolução.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organização • Patrimônio • Investimentos',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _AboutSectionTitle(title: 'Sobre o aplicativo'),
          const Text(
            'O AUVIX foi desenvolvido para ajudar você a organizar sua '
            'vida financeira, acompanhar seus investimentos, construir '
            'patrimônio e planejar seus objetivos com mais conhecimento.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 24),
          const _AboutSectionTitle(title: 'O que você encontra no AUVIX'),
          const _AboutFeature(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Acompanhamento de investimentos',
            description: 'Organize e acompanhe seus ativos e sua carteira.',
          ),
          const _AboutFeature(
            icon: Icons.trending_up_rounded,
            title: 'Construção de patrimônio',
            description: 'Planeje aportes, metas e projeções financeiras.',
          ),
          const _AboutFeature(
            icon: Icons.account_balance_outlined,
            title: 'Controle financeiro',
            description: 'Organize seu dinheiro e acompanhe suas dívidas.',
          ),
          const _AboutFeature(
            icon: Icons.notifications_none_rounded,
            title: 'Alertas e economia',
            description: 'Acompanhe informações econômicas e de mercado.',
          ),
          const _AboutFeature(
            icon: Icons.school_outlined,
            title: 'Educação financeira',
            description: 'Aprenda conceitos para tomar decisões conscientes.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              border: Border.all(
                color: AuvixTheme.accent.withValues(alpha: 0.7),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AuvixTheme.accent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Importante',
                        style: TextStyle(
                          color: AuvixTheme.accent,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'O AUVIX não é uma plataforma de investimentos, '
                  'corretora ou instituição financeira. É um aplicativo '
                  'de organização e acompanhamento financeiro, destinado '
                  'a auxiliar o usuário no controle de seus investimentos, '
                  'patrimônio e planejamento financeiro.\n\n'
                  'O aplicativo não realiza operações de compra ou venda '
                  'de ativos nem recebe ou movimenta recursos financeiros '
                  'dos usuários.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Desenvolvido para aproximar você dos seus objetivos financeiros.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Versão 0.1.0',
              style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
            ),
          ),
          Center(
            child: Text(
              'Contato: techalkstore@gmail.com',
              style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AboutSectionTitle extends StatelessWidget {
  final String title;

  const _AboutSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AuvixTheme.accent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AboutFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AuvixTheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: AuvixTheme.accent, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: TextStyle(color: AuvixTheme.muted, height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _LegalDocumentScreen extends StatelessWidget {
  final String title;

  const _LegalDocumentScreen({required this.title});

  static const _privacySections = <(String, String)>[
    (
      '1. Responsável pelo aplicativo',
      'O AUVIX é um aplicativo de acompanhamento e organização financeira. '
          'O responsável pelo tratamento dos dados pessoais relacionados ao aplicativo é Bruno Fernandes. '
          'Contato: techalkstore@gmail.com.',
    ),
    (
      '2. Quais informações são armazenadas',
      'O aplicativo pode armazenar informações que o próprio usuário cadastra, '
          'como ativos, valores financeiros, metas, aportes, despesas, dívidas e bens pessoais. '
          'Também podem ser armazenadas informações sobre o progresso nas atividades educativas.',
    ),
    (
      '3. Onde os dados ficam armazenados',
      'O cadastro e a autenticação da conta são realizados pelo serviço Supabase. '
          'Os dados financeiros e demais informações cadastradas no aplicativo '
          'permanecem armazenados localmente no dispositivo do usuário nesta versão. '
          'Ainda não há sincronização desses dados financeiros com a nuvem.',
    ),
    (
      '4. Cadastro e autenticação',
      'O AUVIX permite criar uma conta e entrar com e-mail e senha por meio do Supabase. '
          'As informações necessárias à autenticação são processadas por esse serviço externo, '
          'conforme suas próprias práticas e políticas de privacidade. '
          'O usuário deve utilizar uma senha forte e evitar reutilizar senhas de outros serviços.',
    ),
    (
      '5. Serviços externos',
      'O AUVIX consulta fontes externas para apresentar notícias econômicas e indicadores de mercado. '
          'Entre elas estão o Google News e os serviços públicos de dados do Banco Central do Brasil. '
          'Essas consultas utilizam parâmetros relacionados às notícias e aos indicadores, '
          'não os valores financeiros cadastrados pelo usuário. '
          'Quando o usuário abre uma notícia, o conteúdo pode ser acessado em um site externo, '
          'sujeito às políticas desse serviço.',
    ),
    (
      '6. Compartilhamento de informações',
      'O aplicativo não possui, na versão atual, uma funcionalidade própria de envio '
          'dos dados financeiros cadastrados para outros usuários ou para um servidor do AUVIX. '
          'Os serviços externos utilizados possuem suas próprias regras de privacidade '
          'e podem receber informações técnicas necessárias à conexão.',
    ),
    (
      '7. Segurança e cuidados do usuário',
      'O acesso à conta utiliza autenticação fornecida pelo Supabase. '
          'Os dados financeiros cadastrados permanecem no armazenamento privado '
          'do aplicativo no dispositivo. A versão atual não oferece criptografia própria '
          'desses dados nem sincronização financeira em nuvem. '
          'Recomendamos proteger o aparelho com bloqueio de tela, manter o sistema atualizado '
          'e evitar compartilhar o dispositivo com pessoas não autorizadas.',
    ),
    (
      '8. Exclusão dos dados e da conta',
      'Os dados financeiros armazenados localmente podem ser apagados nas configurações '
          'do Android, limpando os dados do aplicativo ou desinstalando-o. '
          'Essas ações podem causar a perda das informações cadastradas, mas não excluem '
          'automaticamente a conta de autenticação. '
          'A versão atual não oferece exclusão de conta diretamente pelo aplicativo. '
          'Para solicitar a exclusão da conta, entre em contato pelo e-mail '
          'techalkstore@gmail.com.',
    ),
    (
      '9. Direitos do titular',
      'Nos termos da Lei Geral de Proteção de Dados (Lei nº 13.709/2018), '
          'o titular pode solicitar informações sobre o tratamento de seus dados e exercer '
          'os direitos previstos na legislação. Para dúvidas ou solicitações, entre em contato '
          'pelo e-mail techalkstore@gmail.com.',
    ),
    (
      '10. Alterações nesta política',
      'Esta política poderá ser atualizada quando o aplicativo receber novas funcionalidades '
          'ou quando houver mudanças legais ou operacionais. A versão mais recente será '
          'disponibilizada no próprio aplicativo.',
    ),
    ('Última atualização', '9 de novembro de 2026.'),
  ];

  static const _termsSections = <(String, String)>[
    (
      '1. Sobre o AUVIX',
      'O AUVIX é um aplicativo destinado à organização e ao acompanhamento pessoal '
          'de informações financeiras, investimentos, patrimônio, metas e conteúdos educativos.',
    ),
    (
      '2. Aceitação dos termos',
      'Ao utilizar o aplicativo, o usuário declara que leu e compreendeu estes Termos de Uso. '
          'Caso não concorde com as condições, deverá deixar de utilizar o aplicativo.',
    ),
    (
      '3. Cadastro e autenticação',
      'O AUVIX exige cadastro e autenticação com e-mail e senha por meio do Supabase '
          'para acessar as funcionalidades protegidas. O usuário deve utilizar '
          'credenciais próprias e manter sua senha em segurança. '
          'O acesso depende da disponibilidade do serviço de autenticação.',
    ),
    (
      '4. Responsabilidade pelas informações',
      'O usuário é responsável pelos dados e valores que cadastra no aplicativo. '
          'O AUVIX funciona como ferramenta de organização e acompanhamento; '
          'não substitui extratos oficiais, documentos de instituições financeiras '
          'ou registros mantidos por corretoras e bancos.',
    ),
    (
      '5. Informações de mercado e notícias',
      'Indicadores econômicos e notícias são obtidos de fontes externas e podem apresentar '
          'atrasos, indisponibilidade ou alterações. Embora o aplicativo procure apresentar '
          'informações úteis, não garante que todo conteúdo esteja sempre atualizado, '
          'completo ou livre de erros.',
    ),
    (
      '6. Não é recomendação de investimento',
      'O AUVIX não é uma corretora, banco, consultoria ou instituição financeira. '
          'Os conteúdos e cálculos apresentados têm finalidade informativa e educativa. '
          'Não constituem recomendação individual de compra, venda ou manutenção de ativos. '
          'Toda decisão financeira deve ser avaliada pelo próprio usuário, considerando '
          'seus objetivos e sua tolerância a riscos.',
    ),
    (
      '7. Projeções e cálculos',
      'Simulações, metas e projeções são estimativas baseadas nos valores e nas premissas '
          'informados pelo usuário. Resultados futuros podem ser diferentes dos valores '
          'projetados, especialmente em razão de oscilações de mercado, taxas, impostos '
          'e outros fatores.',
    ),
    (
      '8. Uso adequado',
      'O usuário compromete-se a utilizar o aplicativo de forma lícita, '
          'sem tentar comprometer seu funcionamento, acessar indevidamente dados de terceiros '
          'ou utilizar o conteúdo para fins ilegais.',
    ),
    (
      '9. Disponibilidade e alterações',
      'O aplicativo pode receber atualizações, correções ou mudanças em suas funcionalidades. '
          'Também poderá haver períodos de indisponibilidade decorrentes de manutenção, '
          'problemas no dispositivo ou falhas em serviços externos.',
    ),
    (
      '10. Limitação de responsabilidade',
      'O aplicativo é disponibilizado como ferramenta de apoio. O responsável não garante '
          'resultados financeiros e não se responsabiliza por decisões de investimento tomadas '
          'exclusivamente com base nas informações, estimativas ou conteúdos apresentados.',
    ),
    (
      '11. Propriedade intelectual',
      'Os elementos próprios do aplicativo, incluindo sua identidade visual, organização '
          'e conteúdos originais, são protegidos pela legislação aplicável. '
          'Conteúdos de terceiros permanecem sujeitos aos direitos de seus respectivos titulares.',
    ),
    (
      '12. Contato',
      'Dúvidas, sugestões ou solicitações relacionadas ao AUVIX podem ser encaminhadas para '
          'techalkstore@gmail.com. Responsável pelo aplicativo: Bruno Fernandes.',
    ),
    ('Última atualização', '9 de novembro de 2026.'),
  ];

  @override
  Widget build(BuildContext context) {
    final sections = title == 'Política de Privacidade'
        ? _privacySections
        : _termsSections;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AuvixTheme.accent,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'AUVIX • Documento informativo',
            style: TextStyle(color: AuvixTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          for (final section in sections) ...[
            Text(
              section.$1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AuvixTheme.accent,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              section.$2,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AuvixTheme.text,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
