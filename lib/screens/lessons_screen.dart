import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';
import 'lesson_content.dart';
import 'interactive_lesson_screen.dart';

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
  final Set<int> completedLessons = {};
  bool loadingProgress = true;

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
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = <int>{};

      for (int lesson = 1; lesson <= fundamentalsLessons.length; lesson++) {
        final saved = lesson == 1
            ? prefs.getBool('lesson_01_completed') ?? false
            : prefs.getBool('lesson_${lesson}_completed') ?? false;

        if (saved) completed.add(lesson);
      }

      if (!mounted) return;

      setState(() {
        completedLessons
          ..clear()
          ..addAll(completed);
        loadingProgress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingProgress = false;
      });

      debugPrint('Erro ao carregar progresso das aulas: $e');
    }
  }

  Future<void> _openLesson(
    BuildContext context,
    int lessonNumber,
    Map<String, String> lesson,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => lessonNumber == 1
            ? const LessonContentScreen()
            : InteractiveLessonScreen(
                lessonNumber: lessonNumber,
                title: lesson['title']!,
                duration: lesson['duration']!,
                description: lesson['description']!,
              ),
      ),
    );

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.moduleNumber == '01'
        ? fundamentalsLessons
        : <Map<String, String>>[];

    final completedCount = completedLessons.length;
    final progress = lessons.isEmpty
        ? 0.0
        : completedCount / lessons.length;

    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: Text(
          'Módulo ${widget.moduleNumber}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.moduleTitle,
            style: const TextStyle(
              color: AuvixTheme.text,
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
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF183A4A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seu progresso',
                        style: TextStyle(
                          color: AuvixTheme.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$completedCount de ${lessons.length} aulas',
                        style: const TextStyle(
                          color: AuvixTheme.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AuvixTheme.surface2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AuvixTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (loadingProgress)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AuvixTheme.accent,
                ),
              ),
            )
          else if (lessons.isEmpty)
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
            )
          else
            ...lessons.asMap().entries.map((entry) {
              final lessonNumber = entry.key + 1;
              final lesson = entry.value;
              final isCompleted = completedLessons.contains(lessonNumber);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AuvixTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openLesson(
                      context,
                      lessonNumber,
                      lesson,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AuvixTheme.accent
                                  : AuvixTheme.surface2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AuvixTheme.background,
                                  )
                                : Text(
                                    lessonNumber.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      color: AuvixTheme.accent,
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
                                  style: const TextStyle(
                                    color: AuvixTheme.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isCompleted
                                      ? '${lesson['duration']} • Concluída'
                                      : lesson['duration']!,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? AuvixTheme.accent
                                        : AuvixTheme.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.chevron_right_rounded,
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
