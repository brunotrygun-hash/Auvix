import 'package:flutter/material.dart';
import '../models/asset_position.dart';
import '../theme/auvix_theme.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final tickerController = TextEditingController();
  final quantityController = TextEditingController();
  final averageController = TextEditingController();

  @override
  void dispose() {
    tickerController.dispose();
    quantityController.dispose();
    averageController.dispose();
    super.dispose();
  }

  void save() {
    final ticker = tickerController.text.trim().toUpperCase();
    final quantity = double.tryParse(
      quantityController.text.trim().replaceAll(',', '.'),
    ) ?? 0;
    final average = double.tryParse(
      averageController.text.trim().replaceAll(',', '.'),
    ) ?? 0;

    if (ticker.isEmpty ||
        !RegExp(r'^[A-Z0-9]{5,6}$').hasMatch(ticker)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um código de ativo válido.')),
      );
      return;
    }

    if (quantity <= 0 || average <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe quantidade e preço médio válidos.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      AssetPosition(
        ticker: ticker,
        company: ticker,
        quantity: quantity,
        averagePrice: average,
        currentPrice: average,
        dailyChangePercent: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar ativo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Qual ativo você possui?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: tickerController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Código do ativo',
              hintText: 'Ex.: PETR4, VALE3, BHIA3',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sua posição',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Quantidade de ações',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: averageController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Preço médio (R\$)',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuvixTheme.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'O investimento será calculado com base na quantidade e no preço médio informados.',
              style: TextStyle(color: AuvixTheme.muted),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: save,
            child: const Text('Salvar investimento'),
          ),
        ],
      ),
    );
  }
}
