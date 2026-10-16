import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class Module4LessonsScreen extends StatefulWidget {
  const Module4LessonsScreen({super.key});

  @override
  State<Module4LessonsScreen> createState() =>
      _Module4LessonsScreenState();
}

class _Module4LessonsScreenState extends State<Module4LessonsScreen> {
  final Set<int> completedLessons = {};

  int? activeLesson;
  int? selectedAnswer;
  bool showResult = false;

  static const List<Map<String, dynamic>> lessons = [
    {
      'title': 'Entendendo os riscos dos investimentos',
      'duration': '8 min',
      'sections': [
        {
          'heading': '1. O que é risco?',
          'body':
              'Risco é a possibilidade de um investimento apresentar um resultado diferente do esperado. O valor aplicado pode diminuir, os rendimentos podem variar e, em determinadas situações, o investidor pode perder parte ou todo o dinheiro investido.'
        },
        {
          'heading': '2. Risco de mercado',
          'body':
              'O risco de mercado está relacionado às oscilações dos preços dos ativos. Ações e cotas de fundos podem subir ou cair por causa de expectativas, resultados empresariais, juros, inflação e acontecimentos econômicos.'
        },
        {
          'heading': '3. Risco de crédito',
          'body':
              'O risco de crédito é a possibilidade de uma instituição ou empresa não cumprir suas obrigações financeiras. Antes de investir em produtos sujeitos a esse risco, é importante conhecer o emissor, as condições do investimento e as garantias eventualmente aplicáveis.'
        },
        {
          'heading': '4. Risco de liquidez',
          'body':
              'O risco de liquidez ocorre quando pode ser difícil vender um investimento rapidamente por um preço considerado adequado. Um ativo pode ter valor estimado, mas isso não significa que haverá compradores disponíveis naquele momento.'
        },
      ],
      'question': 'O que caracteriza o risco de liquidez?',
      'answers': [
        'A garantia de lucro em qualquer investimento.',
        'A impossibilidade de os preços variarem.',
        'A dificuldade de vender um ativo rapidamente por um preço adequado.',
        'A certeza de receber rendimentos todos os meses.',
      ],
      'correct': 2,
      'explanation':
          'O risco de liquidez está relacionado à dificuldade de vender um ativo rapidamente por um preço adequado. A facilidade de negociação depende do ativo e das condições do mercado.',
    },
    {
      'title': 'Como funciona a diversificação',
      'duration': '8 min',
      'sections': [
        {
          'heading': '1. O que significa diversificar?',
          'body':
              'Diversificar significa distribuir os investimentos entre diferentes ativos, empresas, setores ou classes de investimento. A ideia é evitar que todo o resultado da carteira dependa de uma única aplicação ou de um único acontecimento.'
        },
        {
          'heading': '2. Por que diversificar?',
          'body':
              'Imagine uma carteira concentrada em apenas uma empresa. Se essa empresa enfrentar dificuldades, uma parcela importante do patrimônio poderá ser afetada. A diversificação pode reduzir a dependência de um único investimento.'
        },
        {
          'heading': '3. Diversificar entre setores',
          'body':
              'Empresas de setores diferentes podem reagir de maneiras distintas às mudanças econômicas. Distribuir investimentos entre setores pode ajudar a reduzir a concentração, embora diferentes empresas também possam cair ao mesmo tempo.'
        },
        {
          'heading': '4. Diversificação não elimina todos os riscos',
          'body':
              'Mesmo uma carteira diversificada pode sofrer perdas quando muitos ativos são afetados pelo mesmo acontecimento econômico. A diversificação ajuda a administrar determinados riscos, mas não garante lucro nem protege contra toda desvalorização.'
        },
      ],
      'question': 'Qual é um dos principais objetivos da diversificação?',
      'answers': [
        'Garantir que todos os investimentos tenham lucro.',
        'Reduzir a dependência de um único investimento.',
        'Eliminar completamente os riscos do mercado.',
        'Investir somente em empresas do mesmo setor.',
      ],
      'correct': 1,
      'explanation':
          'A diversificação procura reduzir a concentração dos investimentos. Ela pode ajudar a administrar riscos, mas não elimina todas as possibilidades de perda.',
    },
    {
      'title': 'Como distribuir os investimentos',
      'duration': '9 min',
      'sections': [
        {
          'heading': '1. Conheça as classes de ativos',
          'body':
              'Uma carteira pode reunir diferentes classes de ativos, como produtos de renda fixa, ações, fundos imobiliários e ETFs. Cada categoria possui características, custos, riscos e formas de funcionamento próprios.'
        },
        {
          'heading': '2. Considere os objetivos financeiros',
          'body':
              'O dinheiro reservado para uma despesa próxima pode exigir características diferentes do dinheiro destinado a um objetivo de longo prazo. O prazo, a necessidade de acesso ao dinheiro e a tolerância a perdas devem fazer parte do planejamento.'
        },
        {
          'heading': '3. Observe a concentração',
          'body':
              'Ter muitos ativos cadastrados não significa necessariamente ter uma carteira bem diversificada. Se vários investimentos dependem da mesma empresa, setor ou fator econômico, eles ainda podem estar concentrados em riscos semelhantes.'
        },
        {
          'heading': '4. Distribuição adequada ao investidor',
          'body':
              'Não existe uma divisão única que sirva para todas as pessoas. A distribuição depende dos objetivos, do prazo, da situação financeira, da capacidade de suportar perdas e do conhecimento sobre cada investimento.'
        },
      ],
      'question':
          'O que deve ser considerado ao distribuir os investimentos?',
      'answers': [
        'Somente o ativo que mais valorizou recentemente.',
        'A quantidade de ativos, sem analisar suas características.',
        'A promessa de obter o maior rendimento possível.',
        'Os objetivos, os prazos, os riscos e a necessidade de liquidez.',
      ],
      'correct': 3,
      'explanation':
          'Uma distribuição coerente considera objetivos, prazos, riscos e necessidade de acesso ao dinheiro. A escolha deve respeitar a realidade de cada investidor.',
    },
    {
      'title': 'Como montar uma carteira equilibrada',
      'duration': '9 min',
      'sections': [
        {
          'heading': '1. Defina seus objetivos',
          'body':
              'Antes de organizar uma carteira, identifique para que o dinheiro será utilizado e quando poderá ser necessário. Objetivos bem definidos ajudam a estabelecer prioridades e a escolher investimentos compatíveis com cada finalidade.'
        },
        {
          'heading': '2. Avalie sua tolerância a perdas',
          'body':
              'A tolerância a riscos representa como o investidor lida com as oscilações e as possíveis perdas. Também é importante avaliar a capacidade financeira de suportá-las sem comprometer despesas essenciais ou objetivos importantes.'
        },
        {
          'heading': '3. Acompanhe e revise a carteira',
          'body':
              'Com o tempo, os preços dos ativos variam e a participação de cada investimento na carteira pode mudar. Revisões periódicas ajudam a verificar se a distribuição continua alinhada aos objetivos e às condições financeiras.'
        },
        {
          'heading': '4. Evite decisões impulsivas',
          'body':
              'Comprar ou vender apenas por medo, euforia ou comentários nas redes sociais pode prejudicar o planejamento. Procure entender os motivos de cada decisão, confira informações confiáveis e considere os custos envolvidos.'
        },
      ],
      'question':
          'Qual atitude ajuda a manter uma carteira alinhada aos objetivos?',
      'answers': [
        'Revisar periodicamente a carteira e seus objetivos.',
        'Vender todos os ativos sempre que houver uma queda.',
        'Escolher investimentos apenas pela valorização recente.',
        'Ignorar os riscos e as necessidades financeiras.',
      ],
      'correct': 0,
      'explanation':
          'Revisar a carteira e os objetivos ajuda a verificar se os investimentos continuam adequados ao planejamento. Isso não garante resultados, mas favorece decisões mais conscientes.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int>{};

    for (int i = 0; i < lessons.length; i++) {
      final number = (i + 1).toString().padLeft(2, '0');

      if (prefs.getBool('module_04_lesson_${number}_completed') ??
          false) {
        completed.add(i);
      }
    }

    if (mounted) {
      setState(() => completedLessons.addAll(completed));
    }
  }

  Future<void> _completeLesson(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final number = (index + 1).toString().padLeft(2, '0');

    await prefs.setBool('module_04_lesson_${number}_completed', true);

    if (!mounted) return;

    setState(() {
      completedLessons.add(index);
      activeLesson = null;
      selectedAnswer = null;
      showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: const Text(
          'Módulo 4',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (activeLesson != null) {
              setState(() {
                activeLesson = null;
                selectedAnswer = null;
                showResult = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: activeLesson == null
          ? _buildLessonList()
          : _buildLessonDetail(activeLesson!),
    );
  }

  Widget _buildLessonList() {
    final progress = completedLessons.length / lessons.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Riscos e diversificação',
          style: TextStyle(
            color: AuvixTheme.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aprenda a compreender os riscos e a distribuir seus investimentos.',
          style: TextStyle(
            color: AuvixTheme.muted,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AuvixTheme.surface2,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AuvixTheme.accent,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${completedLessons.length} de ${lessons.length} aulas concluídas',
          style: const TextStyle(color: AuvixTheme.muted),
        ),
        const SizedBox(height: 20),
        ...List.generate(lessons.length, (index) {
          final lesson = lessons[index];
          final completed = completedLessons.contains(index);

          return Card(
            color: AuvixTheme.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF183A4A)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: completed
                    ? AuvixTheme.accent
                    : AuvixTheme.surface2,
                child: Icon(
                  completed ? Icons.check : Icons.menu_book,
                  color: completed
                      ? AuvixTheme.background
                      : AuvixTheme.accent,
                ),
              ),
              title: Text(
                lesson['title'] as String,
                style: const TextStyle(
                  color: AuvixTheme.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${lesson['duration']} • '
                  '${completed ? 'Concluída' : 'Aula'}',
                  style: const TextStyle(color: AuvixTheme.muted),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AuvixTheme.accent,
              ),
              onTap: () {
                setState(() {
                  activeLesson = index;
                  selectedAnswer = null;
                  showResult = false;
                });
              },
            ),
          );
        }),
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
      ],
    );
  }

  Widget _buildLessonDetail(int index) {
    final lesson = lessons[index];
    final sections = lesson['sections'] as List<Map<String, String>>;
    final answers = lesson['answers'] as List<String>;
    final correct = lesson['correct'] as int;
    final isCorrect = selectedAnswer == correct;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          lesson['title'] as String,
          style: const TextStyle(
            color: AuvixTheme.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lesson['duration'] as String,
          style: const TextStyle(
            color: AuvixTheme.accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        ...sections.map((section) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF183A4A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section['heading']!,
                  style: const TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  section['body']!,
                  style: const TextStyle(
                    color: AuvixTheme.text,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuvixTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF183A4A),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teste seus conhecimentos',
                style: TextStyle(
                  color: AuvixTheme.accent,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lesson['question'] as String,
                style: const TextStyle(
                  color: AuvixTheme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(answers.length, (answerIndex) {
                final isSelected = selectedAnswer == answerIndex;
                final isCorrectOption = answerIndex == correct;

                Color borderColor = const Color(0xFF183A4A);

                if (showResult && isCorrectOption) {
                  borderColor = AuvixTheme.accent;
                } else if (showResult &&
                    isSelected &&
                    !isCorrect) {
                  borderColor = AuvixTheme.danger;
                } else if (isSelected) {
                  borderColor = AuvixTheme.accent;
                }

                Color tileColor = Colors.transparent;

                if (showResult && isCorrectOption) {
                  tileColor = AuvixTheme.accent.withOpacity(0.15);
                } else if (showResult && isSelected && !isCorrect) {
                  tileColor = AuvixTheme.danger.withOpacity(0.12);
                } else if (isSelected) {
                  tileColor = AuvixTheme.surface2;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: borderColor),
                    color: tileColor,
                  ),
                  child: RadioListTile<int>(
                    value: answerIndex,
                    groupValue: selectedAnswer,
                    onChanged: showResult
                        ? null
                        : (value) {
                            setState(() => selectedAnswer = value);
                          },
                    activeColor: AuvixTheme.accent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    title: Text(
                      '${String.fromCharCode(65 + answerIndex)}. '
                      '${answers[answerIndex]}',
                      style: TextStyle(
                        color: showResult && isCorrectOption
                            ? AuvixTheme.accent
                            : showResult && isSelected && !isCorrect
                                ? AuvixTheme.danger
                                : AuvixTheme.text,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              }),
              if (showResult) ...[
                const SizedBox(height: 12),
                Text(
                  isCorrect
                      ? 'Resposta correta!'
                      : 'Resposta incorreta. Tente novamente.',
                  style: TextStyle(
                    color: isCorrect
                        ? AuvixTheme.accent
                        : AuvixTheme.danger,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson['explanation'] as String,
                  style: const TextStyle(
                    color: AuvixTheme.text,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (!showResult)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedAnswer == null
                        ? null
                        : () => setState(() => showResult = true),
                    child: const Text('Verificar resposta'),
                  ),
                )
              else if (!isCorrect)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAnswer = null;
                        showResult = false;
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completeLesson(index),
                    child: Text(
                      completedLessons.contains(index)
                          ? 'Voltar às aulas'
                          : 'Concluir aula',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
    );
  }
}
