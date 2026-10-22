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
  static const String _progressKey = 'lesson_01_completed';

  static const List<String> _answers = [
    'Investir é guardar dinheiro sem nenhum risco.',
    'Investir é aplicar recursos buscando atingir objetivos financeiros.',
    'Investir significa comprar somente ações.',
    'Investir garante lucro em qualquer situação.',
  ];

  int? _selectedAnswer;
  bool _answered = false;
  bool _lessonCompleted = false;
  bool _loadingProgress = true;
  bool _savingProgress = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_progressKey) ?? false;

      if (!mounted) return;

      setState(() {
        _lessonCompleted = completed;
        _loadingProgress = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar o progresso da aula.',
          ),
        ),
      );
    }
  }

  Future<void> _completeLesson() async {
    if (_savingProgress || _lessonCompleted) return;

    setState(() {
      _savingProgress = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_progressKey, true);

      if (!mounted) return;

      setState(() {
        _lessonCompleted = true;
        _savingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aula 01 concluída! Seu progresso foi salvo.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar. Tente novamente.',
          ),
        ),
      );
    }
  }

  void _checkAnswer() {
    if (_selectedAnswer == null || _answered) return;

    setState(() {
      _answered = true;
    });
  }

  void _tryAgain() {
    setState(() {
      _selectedAnswer = null;
      _answered = false;
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
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loadingProgress
          ? const Center(
              child: CircularProgressIndicator(
                color: AuvixTheme.accent,
              ),
            )
          : ListView(
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
                  'Aprenda os conceitos básicos para começar '
                  'a entender o mundo dos investimentos.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                if (_lessonCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AuvixTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AuvixTheme.accent,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AuvixTheme.accent,
                          size: 26,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aula concluída! Seu progresso está salvo.',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _section(
                  icon: Icons.lightbulb_outline_rounded,
                  title: '1. O que é investir?',
                  body:
                      'Investir é aplicar dinheiro em um ativo ou '
                      'produto financeiro com a expectativa de '
                      'obter um resultado futuro. Esse resultado '
                      'pode ajudar você a realizar objetivos, como '
                      'formar uma reserva, comprar um imóvel ou '
                      'complementar a renda no futuro.\n\n'
                      'Antes de investir, é importante entender '
                      'como o produto funciona, quais são os custos, '
                      'os riscos e quando você poderá resgatar '
                      'o dinheiro.',
                ),
                _section(
                  icon: Icons.account_balance_wallet_outlined,
                  title: '2. Exemplos de investimentos',
                  body:
                      '• Poupança: modalidade de depósito com '
                      'regras próprias de remuneração.\n\n'
                      '• CDB: título emitido por um banco. A '
                      'remuneração pode ser prefixada, pós-fixada '
                      'ou híbrida.\n\n'
                      '• Ações: representam pequenas parcelas do '
                      'capital de uma empresa. Seus preços podem '
                      'subir ou cair.\n\n'
                      '• Fundos imobiliários (FIIs): fundos que '
                      'investem em ativos relacionados ao mercado '
                      'imobiliário. Suas cotas também podem perder '
                      'valor.\n\n'
                      'Cada opção possui características, riscos, '
                      'custos e condições diferentes.',
                ),
                _section(
                  icon: Icons.flag_outlined,
                  title: '3. Defina seus objetivos',
                  body:
                      'Imagine que você queira juntar dinheiro '
                      'para comprar uma moto daqui a dois anos. '
                      'Esse objetivo tem um prazo definido e exige '
                      'planejamento.\n\n'
                      'Pergunte a si mesmo:\n'
                      '• Quanto preciso juntar?\n'
                      '• Quando precisarei do dinheiro?\n'
                      '• Posso correr o risco de perder parte '
                      'do valor?\n'
                      '• Tenho uma reserva para emergências?\n\n'
                      'O prazo e a necessidade de resgate ajudam '
                      'a escolher alternativas compatíveis com '
                      'seus objetivos.',
                ),
                _section(
                  icon: Icons.warning_amber_rounded,
                  title: '4. Entenda os riscos',
                  body:
                      'Nenhum investimento deve ser tratado como '
                      'uma promessa de lucro. Alguns produtos '
                      'podem oscilar de preço, apresentar '
                      'dificuldades de resgate ou envolver risco '
                      'de crédito.\n\n'
                      'A diversificação pode ajudar a distribuir '
                      'riscos, mas não elimina a possibilidade '
                      'de perdas.\n\n'
                      'Antes de investir, leia as condições do '
                      'produto e verifique se ele combina com '
                      'sua situação financeira.',
                ),
                const SizedBox(height: 8),
                _buildQuiz(),
                const SizedBox(height: 20),
                const Text(
                  'Conteúdo educacional. Não constitui '
                  'recomendação de compra ou venda de ativos.',
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

  Widget _buildQuiz() {
    final isCorrect = _selectedAnswer == 1;

    return Container(
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
              color: AuvixTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_answers.length, (index) {
            final selected = _selectedAnswer == index;
            final correctOption = index == 1;

            Color borderColor = const Color(0xFF183A4A);
            Color iconColor = AuvixTheme.muted;

            if (_answered && correctOption) {
              borderColor = AuvixTheme.accent;
              iconColor = AuvixTheme.accent;
            } else if (_answered && selected && !correctOption) {
              borderColor = AuvixTheme.danger;
              iconColor = AuvixTheme.danger;
            } else if (selected) {
              borderColor = AuvixTheme.accent;
              iconColor = AuvixTheme.accent;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _answered
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswer = index;
                        });
                      },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: selected
                        ? AuvixTheme.surface2
                        : AuvixTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: iconColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _answers[index],
                          style: const TextStyle(
                            color: AuvixTheme.text,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (_answered && correctOption)
                        const Icon(
                          Icons.check_circle,
                          color: AuvixTheme.accent,
                          size: 20,
                        ),
                      if (_answered && selected && !correctOption)
                        const Icon(
                          Icons.cancel,
                          color: AuvixTheme.danger,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 12),
            Text(
              isCorrect
                  ? 'Resposta correta! Investir envolve '
                      'planejamento e busca de resultados, '
                      'mas não garante lucro.'
                  : 'Resposta incorreta. Revise o conteúdo '
                      'e tente novamente. A alternativa correta '
                      'é a segunda.',
              style: TextStyle(
                color: isCorrect
                    ? AuvixTheme.accent
                    : AuvixTheme.danger,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (isCorrect && !_lessonCompleted)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _savingProgress
                      ? null
                      : _completeLesson,
                  style: FilledButton.styleFrom(
                    backgroundColor: AuvixTheme.accent,
                    foregroundColor: AuvixTheme.background,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: _savingProgress
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AuvixTheme.background,
                          ),
                        )
                      : const Text(
                          'Concluir aula e salvar progresso',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            if (isCorrect && _lessonCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AuvixTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AuvixTheme.accent,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AuvixTheme.accent,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Aula concluída e progresso salvo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AuvixTheme.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isCorrect)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _tryAgain,
                  child: const Text('Tentar novamente'),
                ),
              ),
          ] else ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _selectedAnswer == null ? null : _checkAnswer,
                style: FilledButton.styleFrom(
                  backgroundColor: AuvixTheme.accent,
                  foregroundColor: AuvixTheme.background,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Conferir resposta',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
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
