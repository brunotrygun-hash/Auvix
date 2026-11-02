import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/auvix_theme.dart';

class WealthBuildingScreen extends StatefulWidget {
  const WealthBuildingScreen({super.key});

  @override
  State<WealthBuildingScreen> createState() => _WealthBuildingScreenState();
}

class _WealthBuildingScreenState extends State<WealthBuildingScreen> {
  final TextEditingController _contributionController = TextEditingController(
    text: '300',
  );

  final TextEditingController _rateController = TextEditingController(
    text: '0,8',
  );

  final TextEditingController _monthsController = TextEditingController(
    text: '60',
  );

  final TextEditingController _goalController = TextEditingController(
    text: '50000',
  );
  final TextEditingController _incomeController = TextEditingController();

  final TextEditingController _expensesController = TextEditingController();

  final TextEditingController _reserveController = TextEditingController();

  double _contribution = 300;
  double _monthlyRate = 0.008;
  int _months = 60;
  double _goal = 50000;
  double _suggestedContribution = 0;
  bool _hasCalculatedBudget = false;

  double get _totalInvested => _contribution * _months;

  double get _futureValue {
    if (_monthlyRate == 0) return _totalInvested;

    return _contribution *
        ((pow(1 + _monthlyRate, _months).toDouble() - 1) / _monthlyRate);
  }

  double get _interestEarned => _futureValue - _totalInvested;

  @override
  void dispose() {
    _contributionController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    _goalController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    _reserveController.dispose();
    super.dispose();
  }

  double? _readNumber(String value) {
    final normalized = value.trim().replaceAll(' ', '');

    if (normalized.isEmpty) return null;

    final parsed = normalized.contains(',')
        ? normalized.replaceAll('.', '').replaceAll(',', '.')
        : normalized;

    return double.tryParse(parsed);
  }

  void _simulate() {
    final contribution = _readNumber(_contributionController.text);
    final rate = _readNumber(_rateController.text);
    final months = int.tryParse(_monthsController.text.trim());
    final goal = _readNumber(_goalController.text);

    if (contribution == null ||
        rate == null ||
        goal == null ||
        months == null) {
      _showError('Preencha todos os campos com valores válidos.');
      return;
    }

    if (!contribution.isFinite ||
        !rate.isFinite ||
        !goal.isFinite ||
        contribution < 0 ||
        rate < 0 ||
        rate > 10 ||
        months <= 0 ||
        months > 600 ||
        goal <= 0) {
      _showError(
        'Confira os valores. O prazo deve ser de 1 a 600 meses e a taxa de até 10% ao mês.',
      );
      return;
    }

    setState(() {
      _contribution = contribution;
      _monthlyRate = rate / 100;
      _months = months;
      _goal = goal;
    });
  }

  void _calculateSuggestedContribution() {
    final income = _readNumber(_incomeController.text);
    final expenses = _readNumber(_expensesController.text);
    final reserve = _readNumber(_reserveController.text);

    if (income == null || expenses == null || reserve == null) {
      _showError('Preencha todos os campos com valores válidos.');
      return;
    }

    if (!income.isFinite ||
        !expenses.isFinite ||
        !reserve.isFinite ||
        income <= 0 ||
        expenses < 0 ||
        reserve < 0 ||
        expenses + reserve > income) {
      _showError('Confira sua renda, despesas e margem para imprevistos.');
      return;
    }

    final available = income - expenses - reserve;

    setState(() {
      _suggestedContribution = available * 0.5;
      _hasCalculatedBudget = true;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _money(double value) {
    final fixed = value.toStringAsFixed(2).split('.');
    final integer = fixed[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'R\$ $integer,${fixed[1]}';
  }

  void _showHelp(String title, String explanation) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuvixTheme.surface2,
        title: Text(title),
        content: Text(
          explanation,
          style: const TextStyle(color: AuvixTheme.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _indicator({
    required String title,
    required String value,
    required Color color,
    required String help,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AuvixTheme.muted, fontSize: 13),
                ),
              ),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: AuvixTheme.muted,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AuvixTheme.muted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_futureValue / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Construa seu Patrimônio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planeje seu futuro financeiro',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            const Text(
              'Descubra como seus aportes podem crescer ao longo do tempo.',
              style: TextStyle(color: AuvixTheme.muted, height: 1.4),
            ),
            const SizedBox(height: 22),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _indicator(
                  title: 'Aportar',
                  value: _money(_contribution),
                  color: const Color(0xFF19E6B0),
                  help: 'É o valor que você pretende investir todos os meses.',
                  onTap: () => _showHelp(
                    'Aportar',
                    'É o valor que você pretende investir todos os meses. Escolha uma quantia que caiba no seu orçamento.',
                  ),
                ),
                _indicator(
                  title: 'Juros',
                  value: '${(_monthlyRate * 100).toStringAsFixed(2)}%',
                  color: const Color(0xFFB68AFF),
                  help: 'É a taxa mensal usada nesta simulação. Ela não representa uma rentabilidade garantida.',
                  onTap: () => _showHelp(
                    'Juros',
                    'É a taxa mensal usada nesta simulação. A rentabilidade real depende do investimento escolhido e pode variar.',
                  ),
                ),
                _indicator(
                  title: 'Tempo',
                  value: '$_months meses',
                  color: const Color(0xFF65AFFF),
                  help: 'É por quanto tempo você pretende fazer os aportes.',
                  onTap: () => _showHelp(
                    'Tempo',
                    'É o período durante o qual você pretende investir. Quanto maior o prazo, maior pode ser o efeito dos juros compostos.',
                  ),
                ),
                _indicator(
                  title: 'Meta',
                  value: _money(_goal),
                  color: const Color(0xFFFF986B),
                  help: 'É o patrimônio que você deseja alcançar.',
                  onTap: () => _showHelp(
                    'Meta',
                    'É o valor que você deseja acumular. A simulação mostra quanto falta para chegar até ele.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Ajuste sua simulação',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 15),

            _input(
              label: 'Aporte mensal (R\$)',
              controller: _contributionController,
              hint: 'Ex.: 300',
            ),
            const SizedBox(height: 14),
            _input(
              label: 'Taxa mensal estimada (%)',
              controller: _rateController,
              hint: 'Ex.: 0,8',
            ),
            const SizedBox(height: 14),
            _input(
              label: 'Prazo em meses',
              controller: _monthsController,
              hint: 'Ex.: 60',
            ),
            const SizedBox(height: 14),
            _input(
              label: 'Meta financeira (R\$)',
              controller: _goalController,
              hint: 'Ex.: 50000',
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simulate,
                child: const Text('Simular meu patrimônio'),
              ),
            ),

            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patrimônio projetado',
                    style: TextStyle(color: AuvixTheme.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _money(_futureValue),
                    style: const TextStyle(
                      color: AuvixTheme.accent,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _resultRow('Total aportado', _money(_totalInvested)),
                  const SizedBox(height: 9),
                  _resultRow('Juros estimados', _money(_interestEarned)),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: AuvixTheme.surface2,
                      valueColor: const AlwaysStoppedAnimation(
                        AuvixTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}% da sua meta',
                    style: const TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: AuvixTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AuvixTheme.accent,
                ),
                title: const Text(
                  'Quanto posso investir?',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Descubra um valor que cabe no seu orçamento.',
                  style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                children: [
                  _input(
                    label: 'Renda mensal líquida (R\$)',
                    controller: _incomeController,
                    hint: 'Ex.: 3500',
                  ),
                  const SizedBox(height: 14),
                  _input(
                    label: 'Despesas mensais (R\$)',
                    controller: _expensesController,
                    hint: 'Ex.: 2200',
                  ),
                  const SizedBox(height: 14),
                  _input(
                    label: 'Margem para imprevistos (R\$)',
                    controller: _reserveController,
                    hint: 'Ex.: 300',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _calculateSuggestedContribution,
                      child: const Text('Calcular valor disponível'),
                    ),
                  ),
                  if (_hasCalculatedBudget) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AuvixTheme.surface2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sugestão de aporte mensal',
                            style: TextStyle(color: AuvixTheme.muted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _money(_suggestedContribution),
                            style: const TextStyle(
                              color: AuvixTheme.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'A sugestão considera 50% do valor que sobra após as despesas e a margem para imprevistos.',
                            style: TextStyle(
                              color: AuvixTheme.muted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_suggestedContribution > 0) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _contribution = _suggestedContribution;
                              _contributionController.text =
                                  _suggestedContribution
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ',');
                            });
                          },
                          child: const Text('Usar esse valor na simulação'),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              'Importante: esta é uma simulação matemática, não uma promessa de rentabilidade nem uma recomendação de investimento. Taxas, impostos, custos e inflação podem alterar o resultado real.',
              style: TextStyle(
                color: AuvixTheme.muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AuvixTheme.muted)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
