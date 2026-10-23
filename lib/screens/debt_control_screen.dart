import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/auvix_theme.dart';

class DebtControlScreen extends StatefulWidget {
  const DebtControlScreen({super.key});

  @override
  State<DebtControlScreen> createState() => _DebtControlScreenState();
}

class _DebtControlScreenState extends State<DebtControlScreen> {
  static const String _storageKey = 'auvix_debts';

  List<Map<String, dynamic>> _debts = [];
  bool _loading = true;

  final List<String> _categories = const [
    'Moradia',
    'Cartões',
    'Contas básicas',
    'Veículos',
    'Impostos',
    'Compras',
    'Empréstimos',
    'Educação',
    'Saúde',
    'Outras',
  ];

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    List<Map<String, dynamic>> loaded = [];

    if (stored != null) {
      try {
        final decoded = jsonDecode(stored) as List;

        loaded = decoded.map((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      } catch (_) {
        loaded = [];
      }
    }

    if (!mounted) return;

    setState(() {
      _debts = loaded;
      _loading = false;
    });
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(_debts),
    );
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(double value) {
    final fixed = value.toStringAsFixed(2).split('.');
    final integer = fixed[0];
    final decimal = fixed[1];

    final formatted = integer.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return 'R\$ $formatted,$decimal';
  }

  DateTime _date(String value) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String _formatDate(String value) {
    final date = _date(value);

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime _monthStart(DateTime date) {
    return DateTime(date.year, date.month);
  }

  double get _totalDebt {
    return _debts.fold<double>(
      0,
      (total, debt) => total + _number(debt['amount']),
    );
  }

  double get _paidThisMonth {
    return _debts.fold<double>(0, (total, debt) {
      if (debt['paid'] == true) {
        final date = _date(debt['dueDate']);
        final now = DateTime.now();

        if (date.year == now.year && date.month == now.month) {
          return total + _number(debt['amount']);
        }
      }

      return total;
    });
  }

  double get _dueThisMonth {
    final now = DateTime.now();

    return _debts.fold<double>(0, (total, debt) {
      final date = _date(debt['dueDate']);

      if (debt['paid'] != true &&
          date.year == now.year &&
          date.month == now.month) {
        return total + _number(debt['amount']);
      }

      return total;
    });
  }

  double get _overdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _debts.fold<double>(0, (total, debt) {
      if (debt['paid'] == true) {
        return total;
      }

      final dueDate = _date(debt['dueDate']);
      final dueDay = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      );

      if (dueDay.isBefore(today)) {
        return total + _number(debt['amount']);
      }

      return total;
    });
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final nameController = TextEditingController(
      text: existing?['name']?.toString() ?? '',
    );

    final amountController = TextEditingController(
      text: existing == null
          ? ''
          : _number(existing['amount']).toStringAsFixed(2).replaceAll('.', ','),
    );

    final notesController = TextEditingController(
      text: existing?['notes']?.toString() ?? '',
    );

    String category = existing?['category']?.toString() ?? _categories.first;
    DateTime dueDate = existing == null
        ? DateTime.now().add(const Duration(days: 7))
        : _date(existing['dueDate']);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refreshDialog) {
            return AlertDialog(
              backgroundColor: AuvixTheme.surface,
              title: Text(
                existing == null ? 'Nova dívida' : 'Editar dívida',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Nome da conta ou dívida',
                            hintText: 'Ex.: Conta de energia',
                            prefixIcon: Icon(Icons.receipt_long_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome da dívida.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            prefixIcon: Icon(Icons.category_rounded),
                          ),
                          items: _categories.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              refreshDialog(() => category = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Valor da dívida (R\$)',
                            hintText: 'Ex.: 250,00',
                            prefixIcon: Icon(Icons.payments_rounded),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(
                              (value ?? '').trim().replaceAll(',', '.'),
                            );

                            if (amount == null || amount <= 0) {
                              return 'Informe um valor válido.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Data de vencimento',
                            style: TextStyle(
                              color: AuvixTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await showDatePicker(
                              context: dialogContext,
                              initialDate: dueDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AuvixTheme.accent,
                                      surface: Color(0xFF0B1C27),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (selected != null) {
                              refreshDialog(() => dueDate = selected);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: Text(_formatDate(dueDate.toIso8601String())),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Observações (opcional)',
                            hintText: 'Detalhes sobre esta dívida',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final amount = double.parse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );

                    Navigator.pop(dialogContext, {
                      'name': nameController.text.trim(),
                      'category': category,
                      'amount': amount,
                      'dueDate': DateTime(
                        dueDate.year,
                        dueDate.month,
                        dueDate.day,
                      ).toIso8601String(),
                      'notes': notesController.text.trim(),
                      'paid': existing?['paid'] == true,
                    });
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    amountController.dispose();
    notesController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (existing == null) {
        result['id'] = DateTime.now().microsecondsSinceEpoch.toString();
        _debts.add(result);
      } else {
        final index = _debts.indexWhere(
          (debt) => debt['id'] == existing['id'],
        );

        if (index != -1) {
          result['id'] = existing['id'];
          _debts[index] = result;
        }
      }
    });

    await _saveDebts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Dívida cadastrada com sucesso!'
              : 'Dívida atualizada com sucesso!',
        ),
      ),
    );
  }

  Future<void> _deleteDebt(Map<String, dynamic> debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AuvixTheme.surface,
          title: const Text('Excluir dívida?'),
          content: Text(
            'Deseja excluir "${debt['name']}"? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6577),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _debts.removeWhere((item) => item['id'] == debt['id']);
    });

    await _saveDebts();
  }

  Future<void> _togglePaid(Map<String, dynamic> debt) async {
    setState(() {
      debt['paid'] = !(debt['paid'] == true);
    });

    await _saveDebts();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          debt['paid'] == true
              ? 'Dívida marcada como paga.'
              : 'Dívida marcada como pendente.',
        ),
      ),
    );
  }

  bool _isOverdue(Map<String, dynamic> debt) {
    if (debt['paid'] == true) return false;

    final now = DateTime.now();
    final date = _date(debt['dueDate']);

    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  Color _debtColor(Map<String, dynamic> debt) {
    if (debt['paid'] == true) return AuvixTheme.accent;
    if (_isOverdue(debt)) return const Color(0xFFFF6577);

    final now = DateTime.now();
    final date = _date(debt['dueDate']);

    if (date.difference(
          DateTime(now.year, now.month, now.day),
        ).inDays <=
        3) {
      return const Color(0xFFFFC857);
    }

    return const Color(0xFF43C7FF);
  }

  Widget _summaryCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 125),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _money(value),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _debtCard(Map<String, dynamic> debt) {
    final color = _debtColor(debt);
    final paid = debt['paid'] == true;
    final overdue = _isOverdue(debt);

    final status = paid
        ? 'PAGA'
        : overdue
            ? 'EM ATRASO'
            : 'VENCE ${_formatDate(debt['dueDate'])}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  paid
                      ? Icons.check_circle_rounded
                      : Icons.receipt_long_rounded,
                  color: color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt['name']?.toString() ?? 'Dívida',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt['category']?.toString() ?? 'Outras',
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openForm(existing: debt);
                  } else if (value == 'delete') {
                    _deleteDebt(debt);
                  } else if (value == 'paid') {
                    _togglePaid(debt);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'paid',
                    child: Text(paid ? 'Marcar pendente' : 'Marcar como paga'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(_number(debt['amount'])),
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if ((debt['notes']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                debt['notes'].toString(),
                style: const TextStyle(
                  color: AuvixTheme.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Controle de Dívidas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              children: [
                const Text(
                  'Organize suas contas e mantenha sua vida financeira em dia.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Total das dívidas',
                        value: _totalDebt,
                        icon: Icons.account_balance_wallet_rounded,
                        color: AuvixTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Contas do mês',
                        value: _dueThisMonth,
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF43C7FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Já pagas',
                        value: _paidThisMonth,
                        icon: Icons.check_circle_rounded,
                        color: AuvixTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Em atraso',
                        value: _overdue,
                        icon: Icons.warning_rounded,
                        color: const Color(0xFFFF6577),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Minhas dívidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${_debts.length} ${_debts.length == 1 ? 'conta' : 'contas'}',
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_debts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AuvixTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AuvixTheme.muted.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: AuvixTheme.accent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma dívida cadastrada',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Adicione sua primeira conta para começar a organizar seus vencimentos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AuvixTheme.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._debts.map(_debtCard),
              ],
            ),
    );
  }
}
