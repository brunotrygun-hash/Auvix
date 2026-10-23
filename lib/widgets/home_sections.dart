import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';
import '../screens/learn_investing_screen.dart';
import '../screens/debt_control_screen.dart';

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ShortcutData('Carteira', Icons.account_balance_wallet_rounded),
      _ShortcutData('Mercado', Icons.show_chart_rounded),
      _ShortcutData('Calculadora', Icons.calculate_rounded),
      _ShortcutData('Aprender', Icons.school_rounded),
      _ShortcutData('Objetivos', Icons.flag_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso rápido',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];

              return Container(
                width: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AuvixTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF183A4A)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AuvixTheme.accent, size: 27),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShortcutData {
  final String label;
  final IconData icon;

  const _ShortcutData(this.label, this.icon);
}

class MarketNewsSection extends StatelessWidget {
  const MarketNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giro do Mercado',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'Entenda os assuntos que movimentam os investimentos.',
          style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuvixTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF183A4A)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.public_rounded,
                color: AuvixTheme.accent,
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Economia em foco',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Acompanhe notícias sobre juros, inflação, bolsa e câmbio.',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'CONTEÚDO INFORMATIVO',
                      style: TextStyle(
                        color: AuvixTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LearnInvestingBanner extends StatelessWidget {
  const LearnInvestingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LearnInvestingScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF103847),
                Color(0xFF0B1C27),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1B665E),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APRENDA A INVESTIR',
                      style: TextStyle(
                        color: AuvixTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Seu conhecimento é o primeiro investimento.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comece do básico e avance no seu ritmo.',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.school_rounded,
                color: AuvixTheme.accent,
                size: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WealthAndDebtCards extends StatelessWidget {
  const WealthAndDebtCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Construa seu Patrimônio',
            subtitle: 'Dê o próximo passo',
            icon: Icons.trending_up_rounded,
            accent: AuvixTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DebtControlScreen(),
                ),
              );
            },
            child: _buildCard(
              title: 'Controle de Dívidas',
              subtitle: 'Organize suas contas',
              icon: Icons.account_balance_rounded,
              accent: const Color(0xFFFF6577),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.07),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 29),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
