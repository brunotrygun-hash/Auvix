import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class InteractiveLessonScreen extends StatefulWidget {
  final int lessonNumber;
  final String title;
  final String duration;
  final String description;

  const InteractiveLessonScreen({
    super.key,
    required this.lessonNumber,
    required this.title,
    required this.duration,
    required this.description,
  });

  @override
  State<InteractiveLessonScreen> createState() =>
      _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState
    extends State<InteractiveLessonScreen> {
  int? selectedAnswer;
  bool answered = false;

  static const Map<int, Map<String, dynamic>> lessonData = {
    2: {
      'sections': [
        {
          'title': '1. O que é renda fixa?',
          'body':
              'Na renda fixa, a remuneração segue regras definidas '
              'no momento da aplicação. Isso não significa que todo '
              'produto seja livre de riscos ou que o dinheiro possa '
              'ser resgatado a qualquer momento.\n\n'
              'Exemplos incluem títulos públicos do Tesouro Direto '
              'e CDBs emitidos por bancos. Cada produto possui suas '
              'próprias condições, custos e riscos.'
        },
        {
          'title': '2. Tipos de remuneração',
          'body':
              'Prefixada: a taxa é definida no momento da aplicação.\n\n'
              'Pós-fixada: o rendimento acompanha um indicador, '
              'como uma porcentagem do CDI.\n\n'
              'Híbrida: combina uma taxa fixa com um indicador, '
              'como a inflação medida pelo IPCA.\n\n'
              'O resultado efetivo depende das condições do produto '
              'e, quando aplicável, de impostos e taxas.'
        },
        {
          'title': '3. O que é renda variável?',
          'body':
              'Na renda variável, o preço do investimento pode '
              'oscilar conforme as condições do mercado e os '
              'resultados dos ativos.\n\n'
              'Ações, fundos imobiliários e ETFs negociados em Bolsa '
              'são exemplos. O investidor pode obter ganhos, mas '
              'também pode perder parte ou todo o capital investido, '
              'conforme o ativo e as circunstâncias.'
        },
        {
          'title': '4. Como diferenciar?',
          'body':
              'Imagine que duas pessoas tenham objetivos financeiros '
              'diferentes. Uma pode priorizar previsibilidade e '
              'condições de resgate conhecidas. A outra pode aceitar '
              'oscilações em busca de valorização no longo prazo.\n\n'
              'A escolha não deve depender apenas do rendimento '
              'esperado. Considere também os riscos, o prazo, a '
              'liquidez e sua capacidade de suportar perdas.'
        },
      ],
      'question':
          'Qual afirmação sobre renda fixa e renda variável está correta?',
      'answers': [
        'Todo investimento de renda fixa é livre de riscos.',
        'A renda variável sempre oferece lucro no longo prazo.',
        'Renda fixa tem regras de remuneração definidas, enquanto '
            'ativos de renda variável podem oscilar de preço.',
        'Ações são títulos de renda fixa.',
      ],
      'correct': 2,
      'explanation':
          'Correto! A renda fixa segue regras de remuneração '
          'definidas, enquanto os preços dos ativos de renda variável '
          'podem oscilar. As duas modalidades possuem riscos.',
    },
    3: {
      'sections': [
        {
          'title': '1. O que é risco?',
          'body':
              'Risco é a possibilidade de o resultado de um '
              'investimento ser diferente do esperado. Dependendo '
              'do produto, pode haver oscilação de preço, perdas, '
              'risco de crédito ou dificuldade para resgatar o dinheiro.\n\n'
              'Entender os riscos ajuda a tomar decisões mais '
              'conscientes, sem tratar expectativas como garantias.'
        },
        {
          'title': '2. O que é retorno?',
          'body':
              'Retorno é o resultado financeiro de um investimento '
              'em determinado período. Ele pode ser positivo ou '
              'negativo e deve considerar, quando aplicável, custos '
              'e impostos.\n\n'
              'Por exemplo, se um investimento de R\$ 1.000 passar '
              'a valer R\$ 1.080, houve uma valorização bruta de '
              'R\$ 80, equivalente a 8%, antes de eventuais custos '
              'e tributos.'
        },
        {
          'title': '3. A relação entre risco e retorno',
          'body':
              'Uma possibilidade de retorno maior normalmente vem '
              'acompanhada de riscos ou incertezas que precisam ser '
              'avaliados. Isso não significa que assumir mais risco '
              'garanta um ganho maior.\n\n'
              'Compare as características dos investimentos e não '
              'escolha um produto apenas porque alguém promete '
              'rendimentos elevados.'
        },
        {
          'title': '4. Conheça seu perfil',
          'body':
              'Seu perfil de investidor considera objetivos, prazo, '
              'conhecimento financeiro e capacidade emocional e '
              'financeira de lidar com perdas.\n\n'
              'Uma pessoa que precisa do dinheiro em breve pode ter '
              'necessidades diferentes de alguém que investe para '
              'um objetivo distante. O prazo, sozinho, não elimina '
              'os riscos.'
        },
      ],
      'question':
          'O que significa dizer que um investimento possui risco?',
      'answers': [
        'Que ele necessariamente dará prejuízo.',
        'Que seu resultado pode ser diferente do esperado, inclusive '
            'com possibilidade de perdas.',
        'Que o lucro é garantido, mas pode demorar.',
        'Que seu preço nunca muda.',
      ],
      'correct': 1,
      'explanation':
          'Isso mesmo! Risco envolve incerteza sobre os resultados '
          'e pode incluir perdas. Por isso, é importante conhecer '
          'o produto antes de investir.',
    },
    4: {
      'sections': [
        {
          'title': '1. O que são juros compostos?',
          'body':
              'Juros compostos são conhecidos como juros sobre juros. '
              'Em uma situação com capitalização periódica, os '
              'rendimentos acumulados passam a fazer parte da base '
              'sobre a qual os próximos rendimentos são calculados.\n\n'
              'O resultado depende da taxa, do tempo, dos aportes '
              'e das condições do investimento.'
        },
        {
          'title': '2. Um exemplo simples',
          'body':
              'Imagine, apenas para fins didáticos, uma aplicação '
              'de R\$ 1.000 com rendimento hipotético de 1% ao mês, '
              'sem aportes, impostos ou taxas.\n\n'
              'Após o primeiro mês, o saldo seria R\$ 1.010. '
              'No segundo mês, os 1% seriam calculados sobre '
              'R\$ 1.010, resultando em R\$ 1.020,10.\n\n'
              'A taxa usada neste exemplo não representa uma promessa '
              'de rendimento de qualquer investimento.'
        },
        {
          'title': '3. Tempo e regularidade',
          'body':
              'Quando existe rendimento positivo e reinvestimento, '
              'o efeito dos juros compostos pode se tornar mais '
              'visível ao longo do tempo.\n\n'
              'Aportes regulares também podem contribuir para o '
              'crescimento do patrimônio. Entretanto, investimentos '
              'reais podem ter oscilações, custos, impostos e períodos '
              'de rendimento negativo.'
        },
        {
          'title': '4. Não confunda simulação com garantia',
          'body':
              'Uma calculadora de juros compostos apresenta um '
              'resultado matemático baseado nas taxas e nos aportes '
              'informados. Ela não prevê com certeza o desempenho '
              'futuro de um investimento.\n\n'
              'Use simulações para comparar cenários e planejar '
              'metas, sempre considerando que os resultados reais '
              'podem ser diferentes.'
        },
      ],
      'question':
          'Por que os juros compostos são chamados de juros sobre juros?',
      'answers': [
        'Porque os rendimentos acumulados podem entrar na base '
            'de cálculo dos rendimentos seguintes.',
        'Porque garantem uma taxa positiva todos os meses.',
        'Porque eliminam todos os riscos do investimento.',
        'Porque impedem o investidor de fazer novos aportes.',
      ],
      'correct': 0,
      'explanation':
          'Correto! Na capitalização composta, os rendimentos '
          'acumulados passam a compor a base dos cálculos seguintes. '
          'O resultado real depende das condições do investimento.',
    },
    5: {
      'sections': [
        {
          'title': '1. Transforme desejos em objetivos',
          'body':
              'Um objetivo financeiro deve ser claro e, sempre que '
              'possível, ter um valor e um prazo definidos.\n\n'
              'Em vez de apenas dizer “quero juntar dinheiro”, '
              'você pode estabelecer uma meta, como formar uma '
              'reserva de emergência ou guardar uma quantia para '
              'um projeto futuro.'
        },
        {
          'title': '2. Defina o valor e o prazo',
          'body':
              'Estime quanto dinheiro será necessário e quando '
              'pretende utilizá-lo. Depois, avalie quanto consegue '
              'guardar regularmente sem comprometer despesas '
              'essenciais.\n\n'
              'Revise a meta quando sua renda ou suas despesas '
              'mudarem. Um plano realista costuma ser mais útil '
              'do que uma meta impossível de manter.'
        },
        {
          'title': '3. Considere a reserva de emergência',
          'body':
              'Uma reserva de emergência ajuda a lidar com despesas '
              'inesperadas, como um conserto urgente ou uma redução '
              'de renda.\n\n'
              'Em geral, é importante considerar alternativas com '
              'liquidez e riscos compatíveis com essa finalidade. '
              'O valor adequado depende das despesas e da situação '
              'de cada pessoa.'
        },
        {
          'title': '4. Relacione prazo e investimento',
          'body':
              'O dinheiro que será necessário em breve pede atenção '
              'especial à liquidez e à possibilidade de perdas. '
              'Objetivos distantes podem permitir outras estratégias, '
              'conforme o perfil e a capacidade de assumir riscos.\n\n'
              'Antes de escolher, entenda o produto, os custos, '
              'as condições de resgate e os riscos envolvidos.'
        },
      ],
      'question':
          'O que é importante considerar ao definir um objetivo financeiro?',
      'answers': [
        'Escolher primeiro o investimento que mais subiu recentemente.',
        'Ignorar despesas para investir o máximo possível.',
        'Considerar valor, prazo, capacidade de poupar e necessidade '
            'de acesso ao dinheiro.',
        'Investir sempre no mesmo ativo, independentemente do objetivo.',
      ],
      'correct': 2,
      'explanation':
          'Muito bem! Um objetivo deve considerar valor, prazo e '
          'sua realidade financeira. Essas informações ajudam a '
          'avaliar alternativas compatíveis com suas necessidades.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = lessonData[widget.lessonNumber]!;

    final sections =
        data['sections'] as List<Map<String, String>>;
    final answers = data['answers'] as List<String>;
    final correctAnswer = data['correct'] as int;

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
          const Text(
            'FUNDAMENTOS DOS INVESTIMENTOS',
            style: TextStyle(
              color: AuvixTheme.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: const TextStyle(
              color: AuvixTheme.text,
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
                widget.duration,
                style: const TextStyle(
                  color: AuvixTheme.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.description,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 22),
          ...sections.map(
            (section) => _section(
              title: section['title']!,
              body: section['body']!,
            ),
          ),
          const SizedBox(height: 8),
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
                  '📝 TESTE SEUS CONHECIMENTOS',
                  style: TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data['question'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(answers.length, (index) {
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == correctAnswer;

                  Color borderColor =
                      const Color(0xFF183A4A);

                  if (answered && isSelected) {
                    borderColor = isCorrect
                        ? AuvixTheme.accent
                        : AuvixTheme.danger;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: answered
                          ? null
                          : () {
                              setState(() {
                                selectedAnswer = index;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AuvixTheme.surface2
                              : AuvixTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: AuvixTheme.accent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                answers[index],
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (answered) ...[
                  const SizedBox(height: 12),
                  Text(
                    selectedAnswer == correctAnswer
                        ? data['explanation'] as String
                        : 'Resposta incorreta. Revise o conteúdo e '
                            'tente novamente.',
                    style: TextStyle(
                      color: selectedAnswer == correctAnswer
                          ? AuvixTheme.accent
                          : AuvixTheme.danger,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedAnswer == correctAnswer)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar ao módulo'),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedAnswer = null;
                          answered = false;
                        });
                      },
                      child: const Text('Tentar novamente'),
                    ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AuvixTheme.accent,
                        foregroundColor: AuvixTheme.background,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onPressed: selectedAnswer == null
                          ? null
                          : () {
                              setState(() {
                                answered = true;
                                if (selectedAnswer == correctAnswer) {
                                  SharedPreferences.getInstance().then((prefs) => prefs.setBool("lesson_${widget.lessonNumber}_completed", true));
                                }
                              });
                            },
                      child: const Text(
                        'Conferir resposta',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Conteúdo educacional. Não constitui recomendação '
            'de compra ou venda de ativos.',
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

  Widget _section({
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
          Text(
            title,
            style: const TextStyle(
              color: AuvixTheme.accent,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: AuvixTheme.text,
              fontSize: 14,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}
