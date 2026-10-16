import 'package:flutter/material.dart';

import '../theme/auvix_theme.dart';
import 'lesson_content.dart';
import 'interactive_lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonsScreen extends StatefulWidget {
  final String moduleNumber;
  final String moduleTitle;

  const LessonsScreen({
    super.key,
    required this.moduleNumber,
    required this.moduleTitle,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool lesson01Completed = false;
  final Set<int> completedLessons = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool("lesson_01_completed") ?? false;
    final completedNumbers = <int>{};
    for (var lesson = 2; lesson <= 5; lesson++) {
      if (prefs.getBool("lesson_${lesson}_completed") ?? false) {
        completedNumbers.add(lesson);
      }
    }
    if (!mounted) return;
    setState(() {
      lesson01Completed = completed;
      completedLessons.clear();
      completedLessons.addAll(completedNumbers);
    });
  }

  static const List<Map<String, String>> fundamentalsLessons = [
    {
      'title': 'O que são investimentos?',
      'duration': '5 minutos',
      'description':
          'Entenda o conceito de investimento, seus objetivos e a importância do planejamento financeiro.',
    },
    {
      'title': 'Renda fixa e renda variável',
      'duration': '7 minutos',
      'description':
          'Conheça as diferenças entre renda fixa e renda variável e entenda como cada modalidade funciona.',
    },
    {
      'title': 'Entendendo risco e retorno',
      'duration': '6 minutos',
      'description':
          'Aprenda por que todo investimento exige atenção aos riscos e como eles se relacionam com os possíveis retornos.',
    },
    {
      'title': 'Como funcionam os juros compostos',
      'duration': '6 minutos',
      'description':
          'Descubra como os juros sobre juros podem influenciar o crescimento de um investimento ao longo do tempo.',
    },
    {
      'title': 'Definindo seus objetivos financeiros',
      'duration': '5 minutos',
      'description':
          'Aprenda a organizar suas metas e considerar prazo, necessidade de dinheiro e tolerância a riscos.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lessons = widget.moduleNumber == '01'
        ? fundamentalsLessons
        : <Map<String, String>>[];

    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: Text(
          'Módulo $widget.moduleNumber',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.moduleTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha uma aula para iniciar seus estudos.',
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (lessons.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Este módulo está sendo preparado. '
                'Em breve, novas aulas estarão disponíveis.',
                style: TextStyle(
                  color: AuvixTheme.muted,
                  height: 1.5,
                ),
              ),
            ),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final isCompleted = index == 0 ? lesson01Completed : completedLessons.contains(index + 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => index == 0 ? const LessonContentScreen() : InteractiveLessonScreen(
                          lessonNumber: index + 1,
                          title: lesson['title']!,
                          duration: lesson['duration']!,
                          description: lesson['description']!,
                        ),
                      ),
                    );
                      await _loadProgress();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCompleted ? AuvixTheme.accent : AuvixTheme.surface2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: TextStyle(
                              color: isCompleted ? AuvixTheme.background : AuvixTheme.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson['title']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lesson['duration']!,
                                style: TextStyle(
                                  color: AuvixTheme.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AuvixTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Conteúdo educacional. Não constitui recomendação de compra ou venda de ativos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final int lessonNumber;
  final String title;
  final String duration;
  final String description;

  const LessonDetailScreen({
    super.key,
    required this.lessonNumber,
    required this.title,
    required this.duration,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: const Text(
          'Aula',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'AULA ${lessonNumber.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AuvixTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AuvixTheme.muted,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                duration,
                style: TextStyle(
                  color: AuvixTheme.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF183A4A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O que você vai aprender',
                  style: TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Continue aprendendo',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Leia a explicação, reflita sobre os exemplos e avance '
            'para a próxima etapa quando estiver pronto.',
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AuvixTheme.accent,
                foregroundColor: AuvixTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A marcação de aulas concluídas será implementada '
                      'na próxima etapa.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Concluir leitura',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
