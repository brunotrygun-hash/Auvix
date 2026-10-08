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

    final historyString = prefs.getString('auvix_money_history');

    setState(() {
      _total = prefs.getDouble('auvix_money_total') ?? 0;
      _monthlyGoal = prefs.getDouble('auvix_money_monthly_goal') ?? 0;
      _goal = prefs.getDouble('auvix_money_goal') ?? 0;

      if (historyString != null && historyString.isNotEmpty) {
        final decoded = jsonDecode(historyString);

        if (decoded is List) {
          _history = decoded
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(
      'auvix_money_total',
      _total,
    );

    await prefs.setDouble(
      'auvix_money_monthly_goal',
      _monthlyGoal,
    );

    await prefs.setDouble(
      'auvix_money_goal',
      _goal,
    );

    await prefs.setString(
      'auvix_money_history',
      jsonEncode(_history),
    );
  }

  Future<void> _registerMoney() async {
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
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
                  hintText: '100,00',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: Dinheiro separado para investir',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  valueController.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.'),
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

                Navigator.of(dialogContext).pop({
                  'value': value,
                  'description': description,
                });
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    valueController.dispose();
    descriptionController.dispose();

    if (result == null) {
      return;
    }

    final value = result['value'] as double;
    final description = result['description'] as String;

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

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dinheiro registrado com sucesso!'),
      ),
    );
  }

  Future<void> _setGoal() async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Definir meta'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Valor da meta',
              prefixText: 'R\$ ',
              hintText: '5000,00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.'),
                );

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) {
      return;
    }

    setState(() {
      _goal = result;
    });

    await _saveData();
  }

  Future<void> _setMonthlyGoal() async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
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
              hintText: '500,00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text
                      .replaceAll('.', '')
                      .replaceAll(',', '.'),
                );

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) {
      return;
    }

    setState(() {
      _monthlyGoal = result;
    });

    await _saveData();
  }

  String _money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _goal > _total ? _goal - _total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinheiro'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MoneySummaryCard(
              total: _total,
              goal: _goal,
              monthlyGoal: _monthlyGoal,
              remaining: remaining,
              money: _money,
            ),

            const SizedBox(height: 20),

            const Text(
              'Organização financeira',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.add_circle_outline,
              title: 'Registrar dinheiro',
              subtitle: 'Adicione um novo valor reservado',
              onTap: _registerMoney,
            ),

            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.flag_outlined,
              title: 'Definir meta',
              subtitle: 'Defina quanto pretende acumular',
              onTap: _setGoal,
            ),

            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'Meta mensal',
              subtitle: 'Defina quanto pretende guardar por mês',
              onTap: _setMonthlyGoal,
            ),

            const SizedBox(height: 24),

            const Text(
              'Histórico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (_history.isEmpty)
              _SectionCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 42,
                      color: AuvixTheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhum valor registrado ainda.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use "Registrar dinheiro" para começar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._history.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryCard(
                    description:
                        item['description']?.toString() ??
                            'Dinheiro reservado',
                    date: item['date']?.toString() ?? '',
                    value: (item['value'] as num?)?.toDouble() ?? 0,
                    money: _money,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _SectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AuvixTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O AUVIX usa esta área para ajudar você a organizar o dinheiro reservado para futuros investimentos.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _MoneySummaryCard extends StatelessWidget {
  final double total;
  final double goal;
  final double monthlyGoal;
  final double remaining;
  final String Function(double) money;

  const _MoneySummaryCard({
    required this.total,
    required this.goal,
    required this.monthlyGoal,
    required this.remaining,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AuvixTheme.primary.withValues(alpha: 0.15),
        border: Border.all(
          color: AuvixTheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dinheiro reservado',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            money(total),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SmallValue(
                  label: 'Meta',
                  value: goal > 0 ? money(goal) : 'Não definida',
                ),
              ),
              Expanded(
                child: _SmallValue(
                  label: 'Mensal',
                  value: monthlyGoal > 0
                      ? money(monthlyGoal)
                      : 'Não definida',
                ),
              ),
            ],
          ),
          if (goal > 0) ...[
            const SizedBox(height: 16),
            Text(
              remaining > 0
                  ? 'Faltam ${money(remaining)} para sua meta.'
                  : '🎯 Meta alcançada!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallValue extends StatelessWidget {
  final String label;
  final String value;

  const _SmallValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AuvixTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AuvixTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String description;
  final String date;
  final double value;
  final String Function(double) money;

  const _HistoryCard({
    required this.description,
    required this.date,
    required this.value,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+ ${money(value)}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
