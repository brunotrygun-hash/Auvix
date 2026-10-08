import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  double _total = 0;
  double _monthlyGoal = 0;
  double _goal = 0;

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final historyData = prefs.getString('auvix_money_history');

    setState(() {
      _total = prefs.getDouble('auvix_money_total') ?? 0;
      _monthlyGoal = prefs.getDouble('auvix_money_monthly_goal') ?? 0;
      _goal = prefs.getDouble('auvix_money_goal') ?? 0;

      if (historyData != null) {
        final decoded = jsonDecode(historyData);

        if (decoded is List) {
          _history = decoded
              .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('auvix_money_total', _total);
    await prefs.setDouble('auvix_money_monthly_goal', _monthlyGoal);
    await prefs.setDouble('auvix_money_goal', _goal);
    await prefs.setString(
      'auvix_money_history',
      jsonEncode(_history),
    );
  }

  Future<void> _registerMoney() async {
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Registrar dinheiro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: Reserva para investimento',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(
                  valueController.text.replaceAll(',', '.'),
                );

                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Digite um valor válido.'),
                    ),
                  );
                  return;
                }

                final description =
                    descriptionController.text.trim().isEmpty
                        ? 'Dinheiro reservado'
                        : descriptionController.text.trim();

                final now = DateTime.now();

                setState(() {
                  _total += value;

                  _history.insert(
                    0,
                    {
                      'value': value,
                      'description': description,
                      'date':
                          '${now.day.toString().padLeft(2, '0')}/'
                          '${now.month.toString().padLeft(2, '0')}/'
                          '${now.year}',
                    },
                  );
                });

                await _saveData();

                if (context.mounted) {
                 Navigator.of(context, rootNavigator: true).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Dinheiro registrado com sucesso!',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    valueController.dispose();
    descriptionController.dispose();
  }

  Future<void> _setGoal() async {
    final controller = TextEditingController(
      text: _goal == 0 ? '' : _goal.toStringAsFixed(2),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Definir meta'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Meta financeira',
              prefixText: 'R\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );

                if (value == null || value <= 0) {
                  return;
                }

                setState(() {
                  _goal = value;
                });

                await _saveData();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _setMonthlyGoal() async {
    final controller = TextEditingController(
      text: _monthlyGoal == 0
          ? ''
          : _monthlyGoal.toStringAsFixed(2),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Meta mensal'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Quanto pretende guardar por mês?',
              prefixText: 'R\$ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );

                if (value == null || value <= 0) {
                  return;
                }

                setState(() {
                  _monthlyGoal = value;
                });

                await _saveData();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
 final double remaining = _goal > _total ? _goal - _total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinheiro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu dinheiro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Organize o dinheiro que você está reservando para investir.',
              style: TextStyle(
                color: AuvixTheme.muted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF183A4A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Reservado para investir',
                    style: TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _money(_total),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.savings_rounded,
                    title: 'Meta',
                    value: _money(_goal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Por mês',
                    value: _money(_monthlyGoal),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_goal > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AuvixTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        remaining > 0
                            ? 'Faltam ${_money(remaining)} para sua meta.'
                            : 'Parabéns! Sua meta foi atingida.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            const Text(
              'Planejamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'Registrar dinheiro',
              subtitle: 'Adicione um valor reservado para investir.',
              onTap: _registerMoney,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.flag_outlined,
              title: 'Definir meta',
              subtitle: 'Escolha quanto você pretende acumular.',
              onTap: _setGoal,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.calendar_month_rounded,
              title: 'Meta mensal',
              subtitle: 'Defina quanto pretende guardar por mês.',
              onTap: _setMonthlyGoal,
            ),

            const SizedBox(height: 28),

            const Text(
              'Histórico de aportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            if (_history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AuvixTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Nenhum valor registrado ainda.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                  ),
                ),
              )
            else
              ..._history.map(
                (item) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AuvixTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_rounded,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['description'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date'] as String,
                              style: const TextStyle(
                                color: AuvixTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _money((item['value'] as num).toDouble()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O objetivo do AUVIX é ajudar você a organizar o dinheiro antes, durante e depois dos seus investimentos.',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AuvixTheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
