import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class Module2LessonsScreen extends StatefulWidget {
  const Module2LessonsScreen({super.key});

  @override
  State<Module2LessonsScreen> createState() => _Module2LessonsScreenState();
}

class _Module2LessonsScreenState extends State<Module2LessonsScreen> {
  final Set<int> completedLessons = {};

  static const List<Map<String, dynamic>> lessons = [
    {
      'title': 'O que é a Bolsa de Valores?',
      'duration': '6 minutos',
      'description':
          'Entenda o papel da Bolsa, por que ela existe e como aproxima investidores e empresas.',
      'sections': [
        {
          'title': '1. O que é uma Bolsa de Valores?',
          'body':
              'A Bolsa de Valores é um ambiente organizado em que determinados ativos financeiros podem ser negociados. No Brasil, a principal infraestrutura desse mercado é a B3. Nela, investidores podem negociar ações e outros produtos financeiros conforme as regras de cada mercado.'
        },
        {
          'title': '2. Por que a Bolsa existe?',
          'body':
              'Empresas podem utilizar o mercado de capitais para captar recursos para seus planos de crescimento. Os investidores, por sua vez, podem comprar ativos buscando participar dos resultados de uma empresa ou obter retorno financeiro. A negociação também permite que investidores comprem e vendam ativos entre si.'
        },
        {
          'title': '3. O que é uma ação?',
          'body':
              'Uma ação representa uma fração do capital social de uma companhia. Ao comprar uma ação, você passa a ter participação naquela empresa, conforme os direitos associados à classe da ação. Isso não significa retorno garantido: o preço pode cair e o investidor pode perder parte ou todo o valor aplicado.'
        },
        {
          'title': '4. A Bolsa não é uma máquina de lucro',
          'body':
              'Os preços variam conforme expectativas, resultados das empresas, condições econômicas e decisões dos participantes do mercado. Investir exige planejamento, conhecimento dos riscos e atenção ao prazo dos objetivos. Resultados passados não garantem resultados futuros.'
        },
      ],
      'question':
          'Qual é uma das funções do mercado de ações?',
      'answers': [
        'Garantir lucro a todas as pessoas que investem.',
        'Permitir a negociação de ações e ajudar empresas a captar recursos.',
        'Impedir que os preços das empresas mudem.',
        'Garantir que nenhuma empresa tenha prejuízo.',
      ],
      'correct': 1,
      'explanation':
          'A Bolsa organiza a negociação de ações. O mercado de capitais também pode ajudar empresas a captar recursos, mas não garante lucro aos investidores.',
    },
    {
      'title': 'Como funciona a B3?',
      'duration': '7 minutos',
      'description':
          'Conheça a B3, as corretoras, os sistemas de negociação e o caminho de uma ordem.',
      'sections': [
        {
          'title': '1. O que é a B3?',
          'body':
              'A B3 é a empresa que opera infraestrutura para diferentes mercados financeiros no Brasil. Entre suas atividades estão os ambientes de negociação, o registro de operações e serviços relacionados à compensação, liquidação e custódia, conforme o mercado e o produto.'
        },
        {
          'title': '2. Qual é o papel da corretora?',
          'body':
              'Em geral, o investidor utiliza uma instituição autorizada, como uma corretora, para acessar o mercado. Pelo aplicativo ou plataforma, informa qual ativo deseja negociar, a quantidade e as condições da ordem. Antes de investir, é importante verificar custos, serviços e se a instituição está devidamente autorizada.'
        },
        {
          'title': '3. Como uma ordem chega ao mercado?',
          'body':
              'O investidor envia uma ordem pela plataforma da corretora. A ordem é encaminhada ao ambiente de negociação, onde pode ser executada se houver condições compatíveis com as regras do mercado. Enviar uma ordem não significa que ela será necessariamente executada.'
        },
        {
          'title': '4. Negociação, liquidação e custódia',
          'body':
              'A negociação é a etapa em que compradores e vendedores combinam uma operação conforme as regras do mercado. A liquidação envolve a conclusão financeira e a entrega dos ativos nos prazos aplicáveis. A custódia corresponde aos serviços de guarda e controle dos ativos. Essas etapas são diferentes, embora façam parte do funcionamento do mercado.'
        },
      ],
      'question':
          'Qual alternativa descreve corretamente o papel da corretora?',
      'answers': [
        'Garantir que toda ordem seja executada com lucro.',
        'Definir sozinha o preço futuro de todas as ações.',
        'Permitir ao cliente acessar o mercado e encaminhar suas ordens.',
        'Eliminar os riscos de investir em renda variável.',
      ],
      'correct': 2,
      'explanation':
          'A corretora oferece acesso ao mercado e encaminha ordens. A execução depende das condições e regras aplicáveis; não há garantia de lucro.',
    },
    {
      'title': 'Entendendo os códigos das ações',
      'duration': '7 minutos',
      'description':
          'Aprenda a interpretar tickers e a conferir o ativo correto antes de negociar.',
      'sections': [
        {
          'title': '1. O que é um ticker?',
          'body':
              'Ticker é o código usado para identificar um ativo negociado no mercado. No Brasil, códigos de ações costumam combinar letras com um número final. O código facilita a pesquisa na plataforma, mas deve sempre ser conferido junto ao nome da companhia e às características do ativo.'
        },
        {
          'title': '2. O que os números podem indicar?',
          'body':
              'Em muitos tickers de ações brasileiras, o número final ajuda a identificar a classe ou modalidade do papel. Por exemplo, final 3 é frequentemente associado a ações ordinárias, enquanto final 4 é frequentemente associado a ações preferenciais. Existem outros finais e particularidades; por isso, não se deve presumir que todos os códigos seguem uma regra simples.'
        },
        {
          'title': '3. Exemplos conhecidos',
          'body':
              'PETR4 é um exemplo de ticker associado a ações preferenciais da Petrobras; VALE3 é um exemplo de ticker associado a ações ordinárias da Vale. Os exemplos servem para aprendizado e não representam recomendação de compra. O cadastro e as características de cada ativo devem ser conferidos na fonte oficial ou na plataforma utilizada.'
        },
        {
          'title': '4. Atenção antes de enviar a ordem',
          'body':
              'Antes de negociar, confira o código, o nome do emissor, a classe do ativo, a quantidade, o preço e o tipo de ordem. Ativos com códigos parecidos podem ter direitos e características diferentes. Uma conferência cuidadosa ajuda a evitar operações feitas por engano.'
        },
      ],
      'question':
          'Por que é importante conferir o ticker e o nome do ativo antes de negociar?',
      'answers': [
        'Porque todos os tickers representam exatamente o mesmo ativo.',
        'Porque conferir o ativo elimina qualquer possibilidade de prejuízo.',
        'Porque o ticker determina sozinho quanto o ativo valerá amanhã.',
        'Porque códigos parecidos podem identificar ativos diferentes.',
      ],
      'correct': 3,
      'explanation':
          'A conferência ajuda a identificar corretamente o ativo e suas características. Ela reduz erros operacionais, mas não elimina os riscos de mercado.',
    },
    {
      'title': 'Como funcionam as compras e vendas',
      'duration': '8 minutos',
      'description':
          'Conheça ordens, preços, quantidade, liquidez e cuidados básicos ao negociar.',
      'sections': [
        {
          'title': '1. Como comprar ou vender',
          'body':
              'Na plataforma da corretora, o investidor seleciona o ativo, informa a quantidade e define as condições da ordem. Uma ordem de compra busca adquirir o ativo; uma ordem de venda busca negociá-lo para outro participante. Antes de confirmar, revise todas as informações exibidas.'
        },
        {
          'title': '2. Ordem a mercado e ordem limitada',
          'body':
              'Uma ordem a mercado busca execução pelos preços disponíveis, conforme as regras do ambiente de negociação. O preço final pode variar em relação ao último preço visto. Uma ordem limitada estabelece um preço máximo de compra ou mínimo de venda, mas pode não ser executada se o mercado não alcançar condições compatíveis.'
        },
        {
          'title': '3. O que é liquidez?',
          'body':
              'Liquidez é a facilidade de negociar um ativo sem provocar grande impacto em seu preço. Ativos com mais participantes e ofertas disponíveis podem apresentar maior liquidez, mas isso não é garantido em todas as situações. Em ativos pouco negociados, pode ser mais difícil encontrar uma contraparte pelo preço desejado.'
        },
        {
          'title': '4. Custos e prazos',
          'body':
              'Uma operação pode envolver taxas, emolumentos, tributos e outros custos, dependendo do produto, da instituição e da situação do investidor. A liquidação também segue prazos específicos. Consulte as condições da corretora e as regras vigentes antes de operar; não considere apenas o preço da ação.'
        },
      ],
      'question':
          'Qual é uma característica de uma ordem limitada?',
      'answers': [
        'Ela garante execução imediata em qualquer situação.',
        'Ela estabelece um limite de preço, mas pode não ser executada.',
        'Ela impede que o ativo sofra desvalorização.',
        'Ela elimina todos os custos da operação.',
      ],
      'correct': 1,
      'explanation':
          'A ordem limitada define o preço máximo aceito na compra ou o mínimo aceito na venda. Se não houver condições compatíveis, a ordem pode ficar sem execução.',
    },
    {
      'title': 'O que faz os preços subirem e descerem?',
      'duration': '8 minutos',
      'description':
          'Descubra como oferta, demanda, expectativas e notícias influenciam os preços.',
      'sections': [
        {
          'title': '1. Oferta e demanda',
          'body':
              'O preço de negociação surge do encontro entre ofertas de compra e de venda. Quando compradores aceitam pagar preços mais altos e as ofertas disponíveis são absorvidas, o preço pode subir. Quando vendedores aceitam preços menores e predominam ofertas de venda, o preço pode cair. A dinâmica depende das ordens presentes no mercado.'
        },
        {
          'title': '2. Resultados das empresas',
          'body':
              'Receita, custos, lucro, endividamento, perspectivas de crescimento e decisões de gestão podem influenciar a avaliação de uma companhia. Um resultado positivo não significa necessariamente que a ação subirá: o mercado também compara os números com as expectativas anteriores e considera riscos futuros.'
        },
        {
          'title': '3. Economia e acontecimentos',
          'body':
              'Juros, inflação, câmbio, atividade econômica, acontecimentos internacionais e mudanças regulatórias podem influenciar os preços. O efeito não é igual para todas as empresas. Uma alteração econômica pode beneficiar alguns setores e prejudicar outros, dependendo de suas características.'
        },
        {
          'title': '4. Expectativas e volatilidade',
          'body':
              'Os preços refletem não apenas o que já aconteceu, mas também as expectativas dos participantes sobre o futuro. Por isso, uma notícia pode provocar oscilações rápidas e imprevisíveis. Volatilidade é a intensidade das variações de preço; ela não permite saber com certeza qual será o próximo movimento.'
        },
      ],
      'question':
          'O que pode influenciar a alta ou a queda do preço de uma ação?',
      'answers': [
        'Apenas o nome da empresa.',
        'Somente a quantidade de ações que o investidor possui.',
        'Oferta e demanda, resultados, expectativas e condições econômicas.',
        'Uma regra que garante valorização todos os meses.',
      ],
      'correct': 2,
      'explanation':
          'Os preços podem ser influenciados por vários fatores, incluindo oferta e demanda, resultados empresariais, expectativas e condições econômicas. Não existe garantia de valorização.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <int>{};

    for (var i = 1; i <= lessons.length; i++) {
      if (prefs.getBool('module_02_lesson_${i.toString().padLeft(2, '0')}_completed') ?? false) {
        loaded.add(i);
      }
    }

    if (!mounted) return;
    setState(() {
      completedLessons
        ..clear()
        ..addAll(loaded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = completedLessons.length;

    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: const Text(
          'Módulo 02',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Conhecendo a Bolsa de Valores',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descubra como funciona o mercado de ações.',
            style: TextStyle(color: AuvixTheme.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
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
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '$progress de ${lessons.length} aulas',
                      style: const TextStyle(
                        color: AuvixTheme.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress / lessons.length,
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
          const SizedBox(height: 22),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final number = index + 1;
            final isCompleted = completedLessons.contains(number);

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
                        builder: (_) => _Module2LessonDetailScreen(
                          lessonNumber: number,
                          lesson: lesson,
                        ),
                      ),
                    );
                    await _loadProgress();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted
                            ? AuvixTheme.accent
                            : const Color(0xFF183A4A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AuvixTheme.accent
                                : AuvixTheme.surface2,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AuvixTheme.background,
                                  size: 25,
                                )
                              : Text(
                                  number.toString().padLeft(2, '0'),
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
                                lesson['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lesson['duration'] as String,
                                style: const TextStyle(
                                  color: AuvixTheme.muted,
                                  fontSize: 12,
                                ),
                              ),
                              if (isCompleted)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    'Aula concluída',
                                    style: TextStyle(
                                      color: AuvixTheme.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
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

class _Module2LessonDetailScreen extends StatefulWidget {
  final int lessonNumber;
  final Map<String, dynamic> lesson;

  const _Module2LessonDetailScreen({
    required this.lessonNumber,
    required this.lesson,
  });

  @override
  State<_Module2LessonDetailScreen> createState() =>
      _Module2LessonDetailScreenState();
}

class _Module2LessonDetailScreenState
    extends State<_Module2LessonDetailScreen> {
  int? selectedAnswer;
  bool answerChecked = false;
  bool answerCorrect = false;
  bool completed = false;

  @override
  void initState() {
    super.initState();
    _loadCompletion();
  }

  Future<void> _loadCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'module_02_lesson_${widget.lessonNumber.toString().padLeft(2, '0')}_completed';
    final value = prefs.getBool(key) ?? false;

    if (!mounted) return;
    setState(() {
      completed = value;
    });
  }

  Future<void> _checkAnswer() async {
    if (selectedAnswer == null) return;

    final correctIndex = widget.lesson['correct'] as int;
    final isCorrect = selectedAnswer == correctIndex;

    setState(() {
      answerChecked = true;
      answerCorrect = isCorrect;
    });

    if (isCorrect) {
      final prefs = await SharedPreferences.getInstance();
      final key =
          'module_02_lesson_${widget.lessonNumber.toString().padLeft(2, '0')}_completed';
      await prefs.setBool(key, true);

      if (!mounted) return;
      setState(() {
        completed = true;
      });
    }
  }

  void _tryAgain() {
    setState(() {
      selectedAnswer = null;
      answerChecked = false;
      answerCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections =
        widget.lesson['sections'] as List<Map<String, String>>;
    final answers = widget.lesson['answers'] as List<String>;

    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        foregroundColor: AuvixTheme.text,
        title: Text(
          'Aula ${widget.lessonNumber.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.lesson['title'] as String,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 17,
                color: AuvixTheme.accent,
              ),
              const SizedBox(width: 6),
              Text(
                widget.lesson['duration'] as String,
                style: const TextStyle(color: AuvixTheme.muted),
              ),
              if (completed) ...[
                const SizedBox(width: 14),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: AuvixTheme.accent,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Concluída',
                  style: TextStyle(
                    color: AuvixTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.lesson['description'] as String,
            style: const TextStyle(
              color: AuvixTheme.muted,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          ...sections.map(
            (section) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFF183A4A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title']!,
                    style: const TextStyle(
                      color: AuvixTheme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section['body']!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1B665E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.quiz_rounded,
                      color: AuvixTheme.accent,
                      size: 25,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Teste seus conhecimentos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson['question'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isSelected = selectedAnswer == index;
                  final correctIndex = widget.lesson['correct'] as int;

                  Color borderColor = const Color(0xFF183A4A);
                  if (answerChecked && index == correctIndex) {
                    borderColor = AuvixTheme.accent;
                  } else if (answerChecked &&
                      isSelected &&
                      !answerCorrect) {
                    borderColor = AuvixTheme.danger;
                  } else if (isSelected) {
                    borderColor = AuvixTheme.accent;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: borderColor),
                      color: isSelected
                          ? AuvixTheme.surface2
                          : Colors.transparent,
                    ),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: selectedAnswer,
                      onChanged: answerChecked
                          ? null
                          : (value) {
                              setState(() {
                                selectedAnswer = value;
                              });
                            },
                      activeColor: AuvixTheme.accent,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }),
                if (answerChecked) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AuvixTheme.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answerCorrect
                              ? 'Resposta correta!'
                              : 'Ainda não foi dessa vez.',
                          style: TextStyle(
                            color: answerCorrect
                                ? AuvixTheme.accent
                                : AuvixTheme.danger,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.lesson['explanation'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!answerCorrect)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _tryAgain,
                        child: const Text('Tentar novamente'),
                      ),
                    )
                  else
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AuvixTheme.accent,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Seu progresso foi salvo.',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          selectedAnswer == null ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuvixTheme.accent,
                        foregroundColor: AuvixTheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Conferir resposta',
                        style: TextStyle(fontWeight: FontWeight.w900),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
