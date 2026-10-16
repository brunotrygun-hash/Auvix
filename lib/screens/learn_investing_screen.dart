import 'package:flutter/material.dart';

import '../theme/auvix_theme.dart';
import 'lessons_screen.dart';
import 'module2_lessons_screen.dart';
import 'module3_lessons_screen.dart';

class LearnInvestingScreen extends StatelessWidget {
  const LearnInvestingScreen({super.key});

  static const List<Map<String, dynamic>> modules = [
    {
      'number': '01',
      'title': 'Fundamentos dos investimentos',
      'description': 'Entenda como o dinheiro pode trabalhar para você.',
      'icon': Icons.account_balance_wallet_rounded,
      'lessons': '5 aulas',
    },
    {
      'number': '02',
      'title': 'Conhecendo a Bolsa de Valores',
      'description': 'Descubra como funciona o mercado de ações.',
      'icon': Icons.show_chart_rounded,
      'lessons': '5 aulas',
    },
    {
      'number': '03',
      'title': 'Ações, FIIs e ETFs',
      'description': 'Conheça os principais tipos de investimentos.',
      'icon': Icons.pie_chart_rounded,
      'lessons': '6 aulas',
    },
    {
      'number': '04',
      'title': 'Riscos e diversificação',
      'description': 'Aprenda sobre riscos e distribuição de recursos.',
      'icon': Icons.shield_rounded,
      'lessons': '4 aulas',
    },
    {
      'number': '05',
      'title': 'Como analisar seus investimentos',
      'description': 'Conheça indicadores e acompanhe resultados.',
      'icon': Icons.analytics_rounded,
      'lessons': '5 aulas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: const Text(
          'Aprenda a Investir',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF103847),
                  Color(0xFF0B1C27),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF1B665E)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AuvixTheme.accent,
                  size: 42,
                ),
                SizedBox(height: 16),
                Text(
                  'INVISTA NO SEU CONHECIMENTO',
                  style: TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Aprenda no seu ritmo.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Uma jornada para conhecer os investimentos, '
                  'entender os riscos e tomar decisões mais conscientes.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sua jornada',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha um módulo para começar.',
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          ...modules.map(
            (module) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ModuleCard(module: module),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Conteúdo educacional. Não constitui recomendação de compra ou venda de ativos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuvixTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => module['number'] == '02'
                  ? const Module2LessonsScreen()
                  : module['number'] == '03'
                      ? const Module3LessonsScreen()
                  : LessonsScreen(
                      moduleNumber: module['number'] as String,
                      moduleTitle: module['title'] as String,
                    ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF183A4A),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AuvixTheme.surface2,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  module['icon'] as IconData,
                  color: AuvixTheme.accent,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MÓDULO ${module['number']}',
                      style: const TextStyle(
                        color: AuvixTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      module['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      module['description'] as String,
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module['lessons'] as String,
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AuvixTheme.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
