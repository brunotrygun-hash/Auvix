import 'package:flutter/material.dart';

import '../theme/auvix_theme.dart';
import '../screens/money_screen.dart';
import '../screens/compound_interest_screen.dart';
import '../screens/news_screen.dart';

import '../screens/learn_investing_screen.dart';
import '../screens/debt_control_screen.dart';
import '../screens/wealth_building_screen.dart';

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({
      String label,
      IconData icon,
      Widget Function() screen,
    })>[
      (
        label: 'Carteira',
        icon: Icons.account_balance_wallet_rounded,
        screen: () => const MoneyScreen(),
      ),
      (
        label: 'Notícias',
        icon: Icons.newspaper_rounded,
        screen: () => const NewsScreen(),
      ),
      (
        label: 'Calculadora',
        icon: Icons.calculate_rounded,
        screen: () => const CompoundInterestScreen(),
      ),
      (
        label: 'Aprender',
        icon: Icons.school_rounded,
        screen: () => const LearnInvestingScreen(),
      ),
      (
        label: 'Objetivos',
        icon: Icons.flag_rounded,
        screen: () => const WealthBuildingScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso rápido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final colors = Theme.of(context).colorScheme;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == items.length - 1 ? 0 : 10,
                ),
                child: SizedBox(
                  width: 100,
                  child: Material(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => item.screen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              color: const Color(0xFF19E6B0),
                              size: 25,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
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
              Icon(Icons.public_rounded, color: AuvixTheme.accent, size: 30),
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
                      style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
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
            MaterialPageRoute(builder: (_) => const LearnInvestingScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF103847), Color(0xFF0B1C27)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1B665E)),
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
                      style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.school_rounded, color: AuvixTheme.accent, size: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class WealthAndDebtCards extends StatelessWidget {
  final VoidCallback? onWealthUpdated;

  const WealthAndDebtCards({
    super.key,
    this.onWealthUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WealthBuildingScreen()),
              );
              onWealthUpdated?.call();
            },
            child: _buildCard(
              title: 'Construa seu Patrimônio',
              subtitle: 'Dê o próximo passo',
              icon: Icons.trending_up_rounded,
              accent: AuvixTheme.accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebtControlScreen()),
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
        border: Border.all(color: accent.withValues(alpha: 0.45)),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: AuvixTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
