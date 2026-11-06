import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class MyAssetsScreen extends StatefulWidget {
  const MyAssetsScreen({super.key});

  @override
  State<MyAssetsScreen> createState() => _MyAssetsScreenState();
}

class _MyAssetsScreenState extends State<MyAssetsScreen> {
  static const _storageKey = 'auvix_personal_assets';

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  double get _total =>
      _items.fold(0, (sum, item) => sum + (item['value'] as num).toDouble());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          _items = decoded
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      } catch (_) {
        _items = [];
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_items));
  }

  double? _parseValue(String text) {
    var value = text.trim().replaceAll(' ', '');

    if (value.contains(',')) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    }

    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  Future<void> _showForm({
    Map<String, dynamic>? item,
    String? fixedName,
  }) async {
    final nameController = TextEditingController(
      text: item?['name'] as String? ?? fixedName ?? '',
    );
    final valueController = TextEditingController(
      text: item == null
          ? ''
          : (item['value'] as num).toString().replaceAll('.', ','),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Adicionar bem' : 'Editar bem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fixedName == null && item?['fixed'] != true)
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do bem',
                  hintText: 'Ex.: Terreno, moto, imóvel',
                ),
              )
            else
              TextField(
                controller: nameController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Tipo de bem'),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: valueController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor atual',
                prefixText: 'R\$ ',
                hintText: '0,00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final value = _parseValue(valueController.text);

              if (name.isEmpty || value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe o nome e um valor válido.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, {'name': name, 'value': value});
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    nameController.dispose();
    valueController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (item != null) {
        item['name'] = result['name'];
        item['value'] = result['value'];
      } else {
        _items.add({
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'name': result['name'],
          'value': result['value'],
          'fixed': fixedName != null,
        });
      }
    });

    await _saveData();
  }

  Future<void> _addFixed(String name) async {
    if (_items.any((item) => item['name'] == name)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$name já está cadastrado.')));
      return;
    }

    await _showForm(fixedName: name);
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir bem?'),
        content: Text('Deseja excluir "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(
      () => _items.removeWhere((element) => element['id'] == item['id']),
    );

    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Bens')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AuvixTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF183A4A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patrimônio cadastrado',
                        style: TextStyle(color: AuvixTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _money(_total),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AuvixTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Adicionar patrimônio',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _addFixed('Casa'),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Casa'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _addFixed('Veículo'),
                      icon: const Icon(Icons.directions_car_outlined),
                      label: const Text('Veículo'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _addFixed('Total investido'),
                      icon: const Icon(Icons.trending_up),
                      label: const Text('Total investido'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar outro bem'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bens cadastrados',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Você ainda não cadastrou nenhum bem.',
                        style: TextStyle(color: AuvixTheme.muted),
                      ),
                    ),
                  ),
                ..._items.map(
                  (item) => Card(
                    color: AuvixTheme.surface,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      title: Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(_money((item['value'] as num).toDouble())),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => _showForm(item: item),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            onPressed: () => _deleteItem(item),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AuvixTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
