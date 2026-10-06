import 'package:flutter/material.dart';
import '../models/asset_position.dart';
import '../theme/auvix_theme.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});
  @override State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final tickerController = TextEditingController(text: 'BHIA3');
  final quantityController = TextEditingController(text: '500');
  final averageController = TextEditingController(text: '3,20');
  bool bhiaSelected = true;

  @override void dispose() { tickerController.dispose(); quantityController.dispose(); averageController.dispose(); super.dispose(); }

  void save() {
    final quantity = double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
    final average = double.tryParse(averageController.text.replaceAll(',', '.')) ?? 0;
    if (quantity <= 0 || average <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe quantidade e preço médio válidos.')));
      return;
    }
    Navigator.pop(context, AssetPosition(ticker: 'BHIA3', company: 'Casas Bahia', quantity: quantity, averagePrice: average, currentPrice: 3.45, dailyChangePercent: 2.38));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar ativo')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: tickerController, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Código do ativo', prefixIcon: Icon(Icons.search_rounded), hintText: 'Ex.: BHIA3')),
        const SizedBox(height: 18),
        const Text('Resultado da busca', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => bhiaSelected = true),
          borderRadius: BorderRadius.circular(18),
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AuvixTheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: bhiaSelected ? AuvixTheme.accent : const Color(0xFF183A4A))), child: const Row(children: [CircleAvatar(child: Text('B')), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BHIA3', style: TextStyle(fontWeight: FontWeight.w800)), Text('Casas Bahia', style: TextStyle(color: AuvixTheme.muted))])), Icon(Icons.add_circle_outline_rounded, color: AuvixTheme.accent)])),
        ),
        const SizedBox(height: 26),
        const Text('Sua posição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        TextField(controller: quantityController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantidade de ações')),
        const SizedBox(height: 14),
        TextField(controller: averageController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Preço médio (R\$)')),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AuvixTheme.surface2, borderRadius: BorderRadius.circular(14)), child: Text('Valor investido: R\$ ${((double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0) * (double.tryParse(averageController.text.replaceAll(',', '.')) ?? 0)).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontWeight: FontWeight.w800))),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: save, child: const Text('Salvar investimento')),
      ]),
    );
  }
}
