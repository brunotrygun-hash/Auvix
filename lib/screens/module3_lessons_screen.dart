import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/auvix_theme.dart';

class Module3LessonsScreen extends StatefulWidget {
  const Module3LessonsScreen({super.key});

  @override
  State<Module3LessonsScreen> createState() =>
      _Module3LessonsScreenState();
}

class _Module3LessonsScreenState extends State<Module3LessonsScreen> {
  final List<Map<String, dynamic>> lessons = [
    {
      'title': 'O que são ações?',
      'duration': '7 min',
      'sections': [
        {
          'heading': 'O que é uma ação?',
          'body': 'Uma ação representa uma pequena parcela do capital social de uma empresa. Ao comprar uma ação, o investidor passa a deter uma participação na companhia e fica exposto aos resultados e às oscilações do mercado.'
        },
        {
          'heading': 'Como funciona na prática?',
          'body': 'As empresas podem disponibilizar ações na bolsa para captar recursos. Os investidores negociam esses papéis entre si, e os preços variam conforme as expectativas, os resultados da empresa e as condições econômicas.'
        },
        {
          'heading': 'Como ganhar ou perder dinheiro?',
          'body': 'O resultado pode vir da valorização da ação e de eventuais proventos distribuídos pela empresa. O preço também pode cair, e não existe garantia de lucro ou de pagamento de dividendos.'
        }
      ],
      'question': 'O que uma ação representa?',
      'answers': [
        'Um empréstimo garantido pelo governo',
        'Uma participação no capital de uma empresa',
        'Uma aplicação sem risco de perda',
        'Um rendimento mensal obrigatório'
      ],
      'correct': 1,
      'explanation': 'A ação representa uma participação no capital de uma empresa. Seu preço pode subir ou cair, e os proventos não são garantidos.'
    },
    {
      'title': 'Ações ordinárias e preferenciais',
      'duration': '7 min',
      'sections': [
        {
          'heading': 'Ações ordinárias (ON)',
          'body': 'As ações ordinárias geralmente concedem direito de voto nas assembleias de acionistas, conforme as regras aplicáveis à companhia e à classe da ação. Costumam ser identificadas pelo número 3 no ticker brasileiro.'
        },
        {
          'heading': 'Ações preferenciais (PN)',
          'body': 'As ações preferenciais podem oferecer prioridade em determinados pagamentos, como dividendos ou reembolso de capital, conforme seus direitos previstos. Em geral, são identificadas pelo número 4, embora existam outras classes.'
        },
        {
          'heading': 'Como comparar?',
          'body': 'É importante consultar os direitos de cada classe, a liquidez, os custos e as informações oficiais da companhia. O tipo de ação, por si só, não garante maior retorno.'
        }
      ],
      'question': 'O que normalmente caracteriza uma ação ordinária (ON)?',
      'answers': [
        'Garantia de valorização',
        'Pagamento obrigatório mensal',
        'Direito de voto, conforme as regras aplicáveis',
        'Ausência de risco de mercado'
      ],
      'correct': 2,
      'explanation': 'A ação ordinária geralmente concede direito de voto. Isso não garante valorização nem dividendos maiores.'
    },
    {
      'title': 'O que são Fundos Imobiliários (FIIs)?',
      'duration': '8 min',
      'sections': [
        {
          'heading': 'Entendendo os FIIs',
          'body': 'Um Fundo de Investimento Imobiliário reúne recursos de diversos investidores para aplicar conforme uma política definida. Suas cotas podem ser negociadas na bolsa, quando admitidas à negociação.'
        },
        {
          'heading': 'Tipos de fundos',
          'body': 'Alguns FIIs investem em imóveis físicos, como galpões logísticos, escritórios e shopping centers. Outros investem em títulos e recebíveis imobiliários. Existem também fundos com estratégias variadas.'
        },
        {
          'heading': 'O que o cotista possui?',
          'body': 'Quem compra uma cota participa economicamente do fundo, de acordo com suas regras. Isso não significa ser proprietário direto de um imóvel específico nem ter direito de uso sobre ele.'
        }
      ],
      'question': 'Qual alternativa descreve melhor um FII?',
      'answers': [
        'Um imóvel com aluguel garantido',
        'Uma conta bancária sem risco',
        'Uma ação ordinária de uma construtora',
        'Um fundo que investe em ativos relacionados ao mercado imobiliário'
      ],
      'correct': 3,
      'explanation': 'FIIs reúnem recursos para investir em ativos relacionados ao setor imobiliário. Seus resultados e suas cotas podem oscilar.'
    },
    {
      'title': 'Rendimentos e riscos dos FIIs',
      'duration': '8 min',
      'sections': [
        {
          'heading': 'De onde vêm os rendimentos?',
          'body': 'Os resultados de um FII podem vir de aluguéis, juros de títulos imobiliários e outras receitas. As distribuições dependem dos resultados e das regras aplicáveis.'
        },
        {
          'heading': 'Principais riscos',
          'body': 'Os riscos incluem imóveis vagos, inadimplência, oscilações dos juros e queda no preço das cotas. Fundos de recebíveis também estão expostos ao risco de crédito.'
        },
        {
          'heading': 'Como estudar um FII?',
          'body': 'Leia relatórios gerenciais, observe a diversificação, a ocupação, os custos e a qualidade dos ativos. Distribuições passadas não garantem rendimentos futuros.'
        }
      ],
      'question': 'Qual afirmação sobre os rendimentos dos FIIs está correta?',
      'answers': [
        'São sempre iguais todos os meses',
        'Podem variar conforme os resultados e os riscos do fundo',
        'São garantidos pelo governo',
        'Nunca sofrem influência da economia'
      ],
      'correct': 1,
      'explanation': 'Os rendimentos podem variar e não são garantidos. É importante estudar os riscos e os relatórios do fundo.'
    },
    {
      'title': 'O que são ETFs?',
      'duration': '7 min',
      'sections': [
        {
          'heading': 'Conhecendo os ETFs',
          'body': 'ETF significa Exchange Traded Fund. É um fundo negociado em bolsa que normalmente busca acompanhar um índice ou uma estratégia definida.'
        },
        {
          'heading': 'Diversificação',
          'body': 'Um ETF pode oferecer exposição a vários ativos por meio de uma única cota. O nível de diversificação depende da estratégia e não elimina o risco de perdas.'
        },
        {
          'heading': 'Custos e riscos',
          'body': 'Avalie a taxa de administração, a liquidez, o índice acompanhado e os custos de negociação. ETFs também podem perder valor.'
        }
      ],
      'question': 'Qual é uma característica comum dos ETFs?',
      'answers': [
        'São sempre livres de risco',
        'Garantem o mesmo rendimento do mês anterior',
        'Podem oferecer exposição a uma cesta de ativos em uma única cota',
        'Precisam investir exclusivamente em imóveis'
      ],
      'correct': 2,
      'explanation': 'Muitos ETFs oferecem exposição a uma cesta de ativos. A estratégia e os riscos variam conforme cada fundo.'
    },
    {
      'title': 'Como comparar ações, FIIs e ETFs',
      'duration': '8 min',
      'sections': [
        {
          'heading': 'O que cada ativo representa?',
          'body': 'Ações representam participação em empresas. FIIs investem em ativos relacionados ao mercado imobiliário. ETFs são fundos negociados em bolsa que seguem um índice ou uma estratégia.'
        },
        {
          'heading': 'Objetivos e riscos',
          'body': 'Considere objetivos financeiros, prazo, tolerância a perdas, liquidez, custos e diversificação. Nenhuma dessas categorias garante lucro ou é adequada para todas as pessoas.'
        },
        {
          'heading': 'Pesquise antes de decidir',
          'body': 'Consulte documentos oficiais, informações da B3 e relatórios dos fundos. Compare informações equivalentes e não tome decisões apenas com base em preços ou rendimentos passados.'
        }
      ],
      'question': 'O que é importante ao comparar ações, FIIs e ETFs?',
      'answers': [
        'Escolher sempre o ativo com menor preço',
        'Considerar objetivos, riscos, custos, liquidez e diversificação',
        'Investir no ativo que mais subiu ontem',
        'Ignorar documentos e relatórios'
      ],
      'correct': 1,
      'explanation': 'A comparação deve considerar os objetivos e as características e riscos de cada investimento. O desempenho passado não garante resultados futuros.'
    },
  ];

  Set<int> completedLessons = {};
  int? activeLesson;
  int? selectedAnswer;
  bool showResult = false;

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
      if (prefs.getBool('module_03_lesson_${number}_completed') ?? false) {
        completed.add(i);
      }
    }

    if (mounted) {
      setState(() => completedLessons = completed);
    }
  }

  Future<void> _completeLesson(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final number = (index + 1).toString().padLeft(2, '0');

    await prefs.setBool('module_03_lesson_${number}_completed', true);

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
        backgroundColor: AuvixTheme.surface,
        foregroundColor: AuvixTheme.text,
        title: const Text('Módulo 03'),
        leading: activeLesson == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  activeLesson = null;
                  selectedAnswer = null;
                  showResult = false;
                }),
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
          'Ações, FIIs e ETFs',
          style: TextStyle(
            color: AuvixTheme.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Conheça diferentes tipos de investimentos negociados em bolsa.',
          style: TextStyle(color: AuvixTheme.muted, fontSize: 15),
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AuvixTheme.surface2,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AuvixTheme.accent,
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
            child: ListTile(
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
              subtitle: Text(
                '${lesson['duration']} • ${completed ? 'Concluída' : 'Aula'}',
                style: const TextStyle(color: AuvixTheme.muted),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AuvixTheme.accent,
              ),
              onTap: () => setState(() {
                activeLesson = index;
                selectedAnswer = null;
                showResult = false;
              }),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text(
          'Conteúdo educacional. Não constitui recomendação de compra ou venda de ativos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
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
          'Leitura • ${lesson['duration']}',
          style: const TextStyle(color: AuvixTheme.muted),
        ),
        const SizedBox(height: 20),
        ...sections.map((section) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['heading']!,
                    style: const TextStyle(
                      color: AuvixTheme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['body']!,
                    style: const TextStyle(
                      color: AuvixTheme.text,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )),
        const Divider(color: AuvixTheme.surface2),
        const SizedBox(height: 16),
        const Text(
          'Teste seus conhecimentos',
          style: TextStyle(
            color: AuvixTheme.text,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson['question'] as String,
          style: const TextStyle(
            color: AuvixTheme.text,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(answers.length, (answerIndex) {
          final isSelected = selectedAnswer == answerIndex;
          Color borderColor = const Color(0xFF183A4A);
          if (showResult && answerIndex == correct) {
            borderColor = AuvixTheme.accent;
          } else if (showResult && isSelected && !isCorrect) {
            borderColor = AuvixTheme.danger;
          } else if (isSelected) {
            borderColor = AuvixTheme.accent;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: borderColor),
              color: isSelected ? AuvixTheme.surface2 : Colors.transparent,
            ),
            child: RadioListTile<int>(
              value: answerIndex,
              groupValue: selectedAnswer,
              onChanged: showResult ? null : (value) {
                setState(() => selectedAnswer = value);
              },
              activeColor: AuvixTheme.accent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                String.fromCharCode(65 + answerIndex) + ". " + answers[answerIndex],
                style: TextStyle(
                  color: showResult && answerIndex == correct
                      ? AuvixTheme.background
                      : AuvixTheme.text,
                ),
              ),
            ),
          );
        }),
        if (showResult) ...[
          const SizedBox(height: 12),
          Text(
            isCorrect ? 'Resposta correta!' : 'Ainda não! Tente novamente.',
            style: TextStyle(
              color: isCorrect ? AuvixTheme.accent : AuvixTheme.danger,
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
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (!showResult)
          ElevatedButton(
            onPressed: selectedAnswer == null
                ? null
                : () => setState(() => showResult = true),
            child: const Text('Verificar resposta'),
          )
        else if (!isCorrect)
          ElevatedButton(
            onPressed: () => setState(() {
              selectedAnswer = null;
              showResult = false;
            }),
            child: const Text('Tentar novamente'),
          )
        else
          ElevatedButton(
            onPressed: () => _completeLesson(index),
            child: Text(
              completedLessons.contains(index)
                  ? 'Voltar às aulas'
                  : 'Concluir aula',
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Conteúdo educacional. Não constitui recomendação de compra ou venda de ativos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}
