import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class LessonContentScreen extends StatefulWidget {
  const LessonContentScreen({super.key});

  @override
  State<LessonContentScreen> createState() =>
      _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  int? selectedAnswer;
  bool answered = false;
  bool lessonCompleted = false;

  Future<void> completeLesson() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("lesson_01_completed", true);
    if (!mounted) return;
    setState(() {
      lessonCompleted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aula 01 concluída e progresso salvo!"),
      ),
    );
  }

  static const List<String> answers = [
    'Investir é guardar dinheiro sem nenhum risco.',
    'Investir é aplicar recursos buscando atingir objetivos financeiros.',
    'Investir significa comprar somente ações.',
    'Investir garante lucro em qualquer situação.',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool("lesson_01_completed") ?? false;
    if (!mounted) return;
    setState(() {
      lessonCompleted = completed;
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
          'Aula 01 • Fundamentos',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'SEU PRIMEIRO PASSO',
            style: TextStyle(
              color: AuvixTheme.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'O que são investimentos?',
            style: TextStyle(
              color: AuvixTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aprenda os conceitos básicos para começar a '
            'entender o mundo dos investimentos.',
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _section(
            icon: Icons.lightbulb_outline_rounded,
            title: '1. O que é investir?',
            body:
                'Investir é aplicar dinheiro em um ativo ou produto '
                'financeiro com a expectativa de obter um resultado '
                'futuro. Esse resultado pode ajudar você a realizar '
                'objetivos, como formar uma reserva, comprar um imóvel '
                'ou complementar a renda no futuro.\n\n'
                'Antes de investir, é importante entender como o '
                'produto funciona, quais são os custos, os riscos e '
                'quando você poderá resgatar o dinheiro.',
          ),
          _section(
            icon: Icons.account_balance_wallet_outlined,
            title: '2. Exemplos de investimentos',
            body:
                '• Poupança: modalidade de depósito com regras '
                'próprias de remuneração.\n\n'
                '• CDB: título emitido por um banco. A remuneração '
                'pode ser prefixada, pós-fixada ou híbrida.\n\n'
                '• Ações: representam pequenas parcelas do capital '
                'de uma empresa. Seus preços podem subir ou cair.\n\n'
                '• Fundos imobiliários (FIIs): fundos que investem '
                'em ativos relacionados ao mercado imobiliário. '
                'Suas cotas também podem perder valor.\n\n'
                'Cada opção possui características, riscos, custos '
                'e condições diferentes.',
          ),
          _section(
            icon: Icons.flag_outlined,
            title: '3. Defina seus objetivos',
            body:
                'Imagine que você queira juntar dinheiro para comprar '
                'uma moto daqui a dois anos. Esse objetivo tem um '
                'prazo definido e exige planejamento.\n\n'
                'Pergunte a si mesmo:\n'
                '• Quanto preciso juntar?\n'
                '• Quando precisarei do dinheiro?\n'
                '• Posso correr o risco de perder parte do valor?\n'
                '• Tenho uma reserva para emergências?\n\n'
                'O prazo e a necessidade de resgate ajudam a escolher '
                'alternativas compatíveis com seus objetivos.',
          ),
          _section(
            icon: Icons.warning_amber_rounded,
            title: '4. Entenda os riscos',
            body:
                'Nenhum investimento deve ser tratado como uma '
                'promessa de lucro. Alguns produtos podem oscilar '
                'de preço, apresentar dificuldades de resgate ou '
                'envolver risco de crédito.\n\n'
                'A diversificação pode ajudar a distribuir riscos, '
                'mas não elimina a possibilidade de perdas.\n\n'
                'Antes de investir, leia as condições do produto e '
                'verifique se ele combina com sua situação financeira.',
          ),
          const SizedBox(height: 12),
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
                const Text(
                  'Qual alternativa descreve melhor o objetivo '
                  'de um investimento?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(answers.length, (index) {
                  final isCorrect = index == 1;
                  final isSelected = selectedAnswer == index;

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
                    selectedAnswer == 1
                        ? 'Resposta correta! Investir envolve '
                            'planejamento e busca de resultados, '
                            'sem garantia de lucro.'
                        : 'Ainda não! Revise a primeira seção e '
                            'tente novamente.',
                    style: TextStyle(
                      color: selectedAnswer == 1
                          ? AuvixTheme.accent
                          : AuvixTheme.danger,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedAnswer == 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: completeLesson,
                        child: const Text("Concluir aula"),
                      ),
                    ),
                  ],
                  if (selectedAnswer != 1)
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
    required IconData icon,
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
          Row(
            children: [
              Icon(
                icon,
                color: AuvixTheme.accent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AuvixTheme.accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
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
