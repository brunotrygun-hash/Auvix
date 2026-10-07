import 'package:flutter/material.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() =>
      _CompoundInterestScreenState();
}

class _CompoundInterestScreenState
    extends State<CompoundInterestScreen> {
  final capitalController = TextEditingController();
  final monthlyController = TextEditingController();
  final rateController = TextEditingController();
  final monthsController = TextEditingController();

  double totalInvested = 0;
  double totalInterest = 0;
  double finalAmount = 0;

  void calculate() {
    final capital =
        double.tryParse(capitalController.text.replaceAll(',', '.')) ?? 0;
    final monthly =
        double.tryParse(monthlyController.text.replaceAll(',', '.')) ?? 0;
    final rate =
        double.tryParse(rateController.text.replaceAll(',', '.')) ?? 0;
    final months = int.tryParse(monthsController.text) ?? 0;

    final monthlyRate = rate / 100;

    double amount = capital;

    for (int i = 0; i < months; i++) {
      amount = amount * (1 + monthlyRate);
      amount += monthly;
    }

    final invested = capital + (monthly * months);

    setState(() {
      totalInvested = invested;
      finalAmount = amount;
      totalInterest = amount - invested;
    });
  }

  @override
  void dispose() {
    capitalController.dispose();
    monthlyController.dispose();
    rateController.dispose();
    monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juros Compostos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: capitalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capital inicial',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: monthlyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Aporte mensal',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Taxa mensal (%)',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prazo (meses)',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculate,
                child: const Text('CALCULAR'),
              ),
            ),

            const SizedBox(height: 30),

            _ResultCard(
              title: 'Total investido',
              value: totalInvested,
            ),
            _ResultCard(
              title: 'Total em juros',
              value: totalInterest,
            ),
            _ResultCard(
              title: 'Valor final',
              value: finalAmount,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final double value;

  const _ResultCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
