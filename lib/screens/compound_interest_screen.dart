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

  bool calculated = false;

  void calculate() {
    final capital = double.tryParse(
          capitalController.text.replaceAll(',', '.'),
        ) ??
        0;

    final monthly = double.tryParse(
          monthlyController.text.replaceAll(',', '.'),
        ) ??
        0;

    final rate = double.tryParse(
          rateController.text.replaceAll(',', '.'),
        ) ??
        0;

    final months = int.tryParse(monthsController.text) ?? 0;

    if (capital < 0 ||
        monthly < 0 ||
        rate < 0 ||
        months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha os valores corretamente.',
          ),
        ),
      );
      return;
    }

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
      calculated = true;
    });
  }

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
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
        title: const Text('Calculadora'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧮 Juros Compostos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Simule o crescimento do seu dinheiro ao longo do tempo.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            _InputField(
              controller: capitalController,
              label: 'Capital inicial',
              hint: 'Ex.: 1000',
              prefix: 'R\$ ',
            ),

            const SizedBox(height: 16),

            _InputField(
              controller: monthlyController,
              label: 'Aporte mensal',
              hint: 'Ex.: 500',
              prefix: 'R\$ ',
            ),

            const SizedBox(height: 16),

            _InputField(
              controller: rateController,
              label: 'Taxa mensal',
              hint: 'Ex.: 1',
              suffix: '%',
            ),

            const SizedBox(height: 16),

            _InputField(
              controller: monthsController,
              label: 'Prazo',
              hint: 'Ex.: 60',
              suffix: 'meses',
              integer: true,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: calculate,
                icon: const Icon(Icons.calculate),
                label: const Text(
                  'CALCULAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (calculated) ...[
              const SizedBox(height: 32),

              const Text(
                'Resultado da simulação',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _ResultCard(
                title: 'Valor final',
                value: money(finalAmount),
                icon: Icons.account_balance_wallet,
                highlight: true,
              ),

              _ResultCard(
                title: 'Total investido',
                value: money(totalInvested),
                icon: Icons.savings,
              ),

              _ResultCard(
                title: 'Rendimento estimado',
                value: money(totalInterest),
                icon: Icons.trending_up,
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Text(
                  '⚠️ Esta é uma simulação. A rentabilidade real dos investimentos pode variar e não é garantida.',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;
  final String? suffix;
  final bool integer;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.integer = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: integer
          ? TextInputType.number
          : const TextInputType.numberWithOptions(
              decimal: true,
            ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool highlight;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
