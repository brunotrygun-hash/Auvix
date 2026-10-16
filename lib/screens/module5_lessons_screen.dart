import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class Module5LessonsScreen extends StatefulWidget {
  const Module5LessonsScreen({super.key});

  @override
  State<Module5LessonsScreen> createState() =>
      _Module5LessonsScreenState();
}

class _Module5LessonsScreenState extends State<Module5LessonsScreen> {
  final Set<int> completedLessons = {};

  int? activeLesson;
  int? selectedAnswer;
  bool showResult = false;

  static const List<Map<String, dynamic>> lessons = [
    {
      'title': 'Entendendo os indicadores financeiros',
      'duration': '8 min',
      'sections': [
        {
          'heading': '1. O que são indicadores financeiros?',
          'body': 'Indicadores financeiros são medidas calculadas a partir de informações econômicas e contábeis. Ajudam a compreender rentabilidade, endividamento, preço e desempenho de uma empresa. Nenhum indicador deve ser analisado isoladamente.'
        },
        {
          'heading': '2. Para que servem?',
          'body': 'Os indicadores ajudam a organizar informações e comparar empresas ou períodos. Podem revelar tendências, pontos fortes e questões que merecem investigação. Resultados passados, porém, não garantem resultados futuros.'
        },
        {
          'heading': '3. Comparar empresas corretamente',
          'body': 'Uma comparação útil considera empresas de setores semelhantes, períodos equivalentes e critérios consistentes. Uma indústria pode ter características muito diferentes de um banco ou de uma empresa de tecnologia.'
        },
        {
          'heading': '4. Cuidados na interpretação',
          'body': 'Os indicadores dependem da qualidade dos dados, das regras contábeis e do contexto econômico. Entenda como cada indicador é calculado e quais são suas limitações antes de tirar conclusões.'
        }
      ],
      'question': 'Qual é a maneira mais adequada de usar indicadores financeiros?',
      'answers': [
        'Escolher uma empresa apenas pelo maior número.',
        'Analisar vários indicadores e considerar o contexto da empresa.',
        'Ignorar os resultados anteriores.',
        'Usar o mesmo indicador para qualquer setor.'
      ],
      'correct': 1,
      'explanation': 'A análise ganha qualidade quando combina indicadores diferentes com o contexto, o setor e os resultados da empresa.'
    },
    {
      'title': 'Analisando os resultados de uma empresa',
      'duration': '9 min',
      'sections': [
        {
          'heading': '1. Receita não é lucro',
          'body': 'A receita representa o valor obtido com as atividades da empresa antes da dedução de todos os custos e despesas. O lucro é o resultado que sobra após considerar os gastos e outros efeitos contábeis. Receita crescente não significa necessariamente lucro crescente.'
        },
        {
          'heading': '2. Observe custos e despesas',
          'body': 'Custos e despesas influenciam a rentabilidade. Se aumentarem mais rapidamente que a receita, a margem de lucro poderá diminuir. Investigue os motivos das mudanças e se são temporárias ou recorrentes.'
        },
        {
          'heading': '3. Entenda as dívidas',
          'body': 'O endividamento deve ser analisado junto com a geração de caixa, os prazos de pagamento e o custo das dívidas. Ter dívida não significa automaticamente que uma empresa está em dificuldades, mas dívidas excessivas podem elevar seus riscos.'
        },
        {
          'heading': '4. Compare diferentes períodos',
          'body': 'Consultar resultados de vários trimestres e anos ajuda a identificar tendências. Considere também eventos extraordinários, sazonalidade, inflação e mudanças no negócio que possam distorcer as comparações.'
        }
      ],
      'question': 'Uma empresa aumentou sua receita, mas seu lucro diminuiu. O que isso pode indicar?',
      'answers': [
        'Que a empresa certamente se tornou mais eficiente.',
        'Que custos, despesas ou outros efeitos podem ter aumentado.',
        'Que a receita sempre determina o lucro.',
        'Que não é necessário analisar os demonstrativos.'
      ],
      'correct': 1,
      'explanation': 'O lucro também depende dos custos, das despesas, do resultado financeiro e de outros fatores. É necessário investigar o que mudou.'
    },
    {
      'title': 'Indicadores fundamentalistas',
      'duration': '10 min',
      'sections': [
        {
          'heading': '1. O que é análise fundamentalista?',
          'body': 'A análise fundamentalista procura compreender a situação financeira e econômica de uma empresa, seu negócio, seus riscos e suas perspectivas. Pode utilizar balanços, demonstrações de resultados, fluxo de caixa e informações do setor.'
        },
        {
          'heading': '2. Preço sobre Lucro (P/L)',
          'body': 'O P/L relaciona o preço de mercado da ação ao lucro por ação. Pode ajudar a contextualizar o preço, mas precisa ser interpretado com cuidado. Lucros extraordinários, prejuízos e diferentes perspectivas de crescimento podem tornar comparações enganosas.'
        },
        {
          'heading': '3. Preço sobre Valor Patrimonial (P/VP)',
          'body': 'O P/VP compara o preço da ação com o valor patrimonial por ação. Sua interpretação varia conforme o setor e a natureza dos ativos da empresa. Um valor baixo, sozinho, não prova que uma ação está barata.'
        },
        {
          'heading': '4. Dividend Yield',
          'body': 'O Dividend Yield relaciona os proventos distribuídos em determinado período ao preço do ativo, conforme a metodologia utilizada. Um percentual elevado pode decorrer de distribuições extraordinárias ou de uma queda no preço. Pagamentos passados não garantem pagamentos futuros.'
        }
      ],
      'question': 'O que podemos concluir ao encontrar uma ação com P/L baixo?',
      'answers': [
        'Que ela é obrigatoriamente um ótimo investimento.',
        'Que seu preço nunca mais irá cair.',
        'Que precisamos investigar lucros, riscos, perspectivas e outros indicadores.',
        'Que a empresa não possui dívidas.'
      ],
      'correct': 2,
      'explanation': 'Um P/L baixo pode ter diferentes causas. A análise precisa considerar a qualidade dos resultados, as perspectivas e os riscos do negócio.'
    },
    {
      'title': 'Como analisar Fundos Imobiliários',
      'duration': '10 min',
      'sections': [
        {
          'heading': '1. Conheça o tipo de fundo',
          'body': 'Fundos Imobiliários podem investir em imóveis, títulos relacionados ao mercado imobiliário ou combinar estratégias. Conhecer o tipo de fundo ajuda a compreender de onde vêm suas receitas e quais riscos merecem atenção.'
        },
        {
          'heading': '2. Rendimentos e distribuição',
          'body': 'Os rendimentos distribuídos podem variar conforme receitas, despesas, reservas e regras aplicáveis. Não presuma que o valor pago em um mês será repetido nos seguintes. Examine o histórico e a origem dos rendimentos.'
        },
        {
          'heading': '3. Vacância e qualidade dos imóveis',
          'body': 'Em fundos que possuem imóveis, a vacância indica espaços que não estão ocupados ou alugados, conforme a métrica utilizada. Observe também localização, concentração de inquilinos, contratos, qualidade dos imóveis e custos de manutenção.'
        },
        {
          'heading': '4. Riscos e diversificação',
          'body': 'Fundos imobiliários podem estar sujeitos a riscos de mercado, crédito, liquidez, vacância, concentração e gestão. Avalie relatórios, estratégia e características da carteira. Diversificar pode reduzir determinadas concentrações, mas não elimina os riscos.'
        }
      ],
      'question': 'Ao avaliar um Fundo Imobiliário, qual atitude é mais adequada?',
      'answers': [
        'Escolher exclusivamente pelo maior rendimento recente.',
        'Ignorar os relatórios do fundo.',
        'Considerar estratégia, riscos, carteira, rendimentos e gestão.',
        'Presumir que as cotas nunca perdem valor.'
      ],
      'correct': 2,
      'explanation': 'Uma avaliação mais completa considera a origem dos rendimentos, a composição da carteira, a gestão e os diferentes riscos do fundo.'
    },
    {
      'title': 'Montando sua análise de investimentos',
      'duration': '9 min',
      'sections': [
        {
          'heading': '1. Defina seus objetivos',
          'body': 'Antes de comparar investimentos, esclareça o objetivo do dinheiro, o prazo e a necessidade de liquidez. Esses fatores influenciam quais riscos podem ser compatíveis com sua situação e seus planos.'
        },
        {
          'heading': '2. Reúna informações confiáveis',
          'body': 'Consulte demonstrações financeiras, relatórios oficiais, comunicados ao mercado e documentos publicados pelos fundos. Verifique datas e períodos dos dados. Informações antigas ou incompletas podem levar a conclusões equivocadas.'
        },
        {
          'heading': '3. Compare riscos e características',
          'body': 'Compare alternativas considerando modelo de negócio, resultados, endividamento, preço, liquidez e perspectivas. Para fundos, examine também a composição da carteira, a estratégia e os riscos específicos. Não existe um único indicador que responda a todas as perguntas.'
        },
        {
          'heading': '4. Revise sua análise periodicamente',
          'body': 'Acompanhe mudanças relevantes nos resultados, nos riscos e nos seus objetivos. Registre os motivos das decisões e revise suas premissas quando surgirem novas informações. Uma análise organizada ajuda a evitar decisões impulsivas, mas não elimina a possibilidade de perdas.'
        }
      ],
      'question': 'Qual é uma boa prática ao montar uma análise de investimentos?',
      'answers': [
        'Decidir apenas com base em comentários nas redes sociais.',
        'Escolher sempre o ativo que mais subiu recentemente.',
        'Usar informações confiáveis, comparar riscos e considerar os objetivos.',
        'Ignorar mudanças nos resultados depois de investir.'
      ],
      'correct': 2,
      'explanation': 'Uma análise organizada combina informações confiáveis, comparação de riscos, objetivos claros e revisão das premissas ao longo do tempo.'
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

      if (prefs.getBool('module_05_lesson_${number}_completed') ??
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

    await prefs.setBool('module_05_lesson_${number}_completed', true);

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
