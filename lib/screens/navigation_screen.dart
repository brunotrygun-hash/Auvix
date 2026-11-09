import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';
import 'portfolio_screen.dart';
import 'money_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const PortfolioScreen(),
    const MoneyScreen(),
    const AlertsScreen(),
    MoreScreen(onOpenPage: _openPage),
  ];

  void _openPage(String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MoreDetailScreen(title: title)));
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
  static const List<_AuvixAnnouncement> _announcements = [];

  Set<String> _readIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReadAnnouncements();
  }

  Future<void> _loadReadAnnouncements() async {
    final preferences = await SharedPreferences.getInstance();
    final savedIds = preferences.getStringList(_storageKey) ?? [];

    if (!mounted) return;

    setState(() {
      _readIds = savedIds.toSet();
      _loading = false;
    });
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

class MoreScreen extends StatelessWidget {
  final ValueChanged<String> onOpenPage;

  const MoreScreen({super.key, required this.onOpenPage});

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
                onTap: () => onOpenPage(item.$1),
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
    if (title == 'Política de Privacidade' || title == 'Termos de Uso') {
      return _LegalDocumentScreen(title: title);
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
      'Na versão atual, as informações cadastradas ficam armazenadas localmente '
          'no espaço de dados do aplicativo no dispositivo do usuário. '
          'O AUVIX não possui, nesta versão, sistema de contas reais, sincronização em nuvem '
          'ou serviço próprio de armazenamento remoto dos dados financeiros.',
    ),
    (
      '4. Login em modo demonstração',
      'A tela de entrada funciona em modo demonstração. O e-mail e a senha digitados '
          'não são validados por um servidor e não criam uma conta real. '
          'Portanto, não utilize senhas pessoais ou reutilizadas de outros serviços nessa tela.',
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
      'Os dados ficam no armazenamento privado do aplicativo no dispositivo. '
          'A versão atual não oferece criptografia própria dos dados financeiros nem autenticação real. '
          'Recomendamos proteger o aparelho com bloqueio de tela, manter o sistema atualizado '
          'e evitar compartilhar o dispositivo com pessoas não autorizadas.',
    ),
    (
      '8. Exclusão dos dados',
      'Como os dados ficam armazenados localmente, o usuário pode apagá-los por meio '
          'das configurações do Android, limpando os dados do aplicativo, ou desinstalando-o. '
          'Essas ações podem causar a perda das informações cadastradas. '
          'A versão atual não oferece uma função de exclusão de conta, pois não há contas reais.',
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
    ('Última atualização', '8 de novembro de 2026.'),
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
      '3. Modo demonstração',
      'A versão atual possui uma tela de entrada demonstrativa. '
          'O preenchimento de e-mail e senha não representa autenticação, '
          'criação de conta ou validação de identidade.',
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
    ('Última atualização', '8 de novembro de 2026.'),
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
