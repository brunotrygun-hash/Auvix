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

double _totalPaid(Map<String, dynamic> debt) {
  final payments = debt['payments'];

  if (payments is List) {
    if (payments.isEmpty && debt['paid'] == true) {
      return _number(debt['amount']);
    }

    return payments.fold<double>(
      0,
      (total, payment) =>
          total + _number((payment as Map)['amount']),
    );
  }

  // Compatibilidade com dívidas antigas marcadas como pagas.
  return debt['paid'] == true ? _number(debt['amount']) : 0;
}

double _remainingBalance(Map<String, dynamic> debt) {
  final amount = _number(debt['amount']);
  final paid = _totalPaid(debt);

  return (amount - paid).clamp(0.0, amount).toDouble();
}

bool _isFullyPaid(Map<String, dynamic> debt) {
  return _remainingBalance(debt) <= 0.009;
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
    (total, debt) => total + _remainingBalance(debt),
  );
}

double get _paidThisMonth {
  final now = DateTime.now();

  return _debts.fold<double>(0, (total, debt) {
    final payments = debt['payments'];

    if (payments is List && payments.isNotEmpty) {
      final paidThisMonth = payments.fold<double>(0, (sum, payment) {
        final paymentDate = _date((payment as Map)['date']);

        if (paymentDate.year == now.year &&
            paymentDate.month == now.month) {
          return sum + _number(payment['amount']);
        }

        return sum;
      });

      return total + paidThisMonth;
    }

    // Compatibilidade com dívidas antigas sem histórico de pagamentos.
    if (debt['paid'] == true) {
      final dueDate = _date(debt['dueDate']);

      if (dueDate.year == now.year && dueDate.month == now.month) {
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
    final remaining = _remainingBalance(debt);

    if (remaining > 0 &&
        date.year == now.year &&
        date.month == now.month) {
      return total + remaining;
    }

    return total;
  });
}

  double get _overdue {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return _debts.fold<double>(0, (total, debt) {
    final remaining = _remainingBalance(debt);

    if (remaining <= 0) return total;

    final dueDate = _date(debt['dueDate']);
    final dueDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    if (dueDay.isBefore(today)) {
      return total + remaining;
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
                      'payments': existing?['payments'] ?? [],
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

Future<void> _registerPayment(Map<String, dynamic> debt) async {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime paymentDate = DateTime.now();
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, refreshDialog) {
          return AlertDialog(
            backgroundColor: AuvixTheme.surface,
            title: const Text('Registrar pagamento'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Saldo restante: ${_money(_remainingBalance(debt))}',
                        style: const TextStyle(
                          color: AuvixTheme.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor pago (R\$)',
                        hintText: 'Ex.: 50,00',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          (value ?? '').trim().replaceAll(',', '.'),
                        );

                        if (amount == null || amount <= 0) {
                          return 'Informe um valor válido.';
                        }

                        if (amount > _remainingBalance(debt) + 0.009) {
                          return 'O valor excede o saldo restante.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: dialogContext,
                          initialDate: paymentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selected != null) {
                          refreshDialog(() => paymentDate = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        'Data: ${_formatDate(paymentDate.toIso8601String())}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        hintText: 'Ex.: pagamento da primeira parcela',
                      ),
                    ),
                  ],
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

                  Navigator.pop(dialogContext, {
                    'amount': double.parse(
                      amountController.text.trim().replaceAll(',', '.'),
                    ),
                    'date': DateTime(
                      paymentDate.year,
                      paymentDate.month,
                      paymentDate.day,
                    ).toIso8601String(),
                    'notes': notesController.text.trim(),
                  });
                },
                child: const Text('Registrar'),
              ),
            ],
          );
        },
      );
    },
  );

  amountController.dispose();
  notesController.dispose();

  if (result == null || !mounted) return;

  setState(() {
    final payments = debt['payments'];

    if (payments is! List) {
      debt['payments'] = <Map<String, dynamic>>[];
    }

    (debt['payments'] as List).add(result);
    debt['paid'] = _isFullyPaid(debt);
  });

  await _saveDebts();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        _isFullyPaid(debt)
            ? 'Dívida quitada com sucesso!'
            : 'Pagamento registrado com sucesso!',
      ),
    ),
  );
}

  Future<void> _showPaymentHistory(
    Map<String, dynamic> debt,
  ) async {
    final payments = debt['payments'];
    final history = payments is List
        ? payments.whereType<Map>().toList()
        : <Map>[];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuvixTheme.surface,
        title: const Text('Histórico de pagamentos'),
        content: SizedBox(
          width: double.maxFinite,
          child: history.isEmpty
              ? const Text(
                  'Nenhum pagamento registrado ainda.',
                  style: TextStyle(color: AuvixTheme.muted),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final payment = history[index];
                    final amount = _number(payment['amount']);
                    final date = payment['date']?.toString() ?? '';
                    final notes = payment['notes']?.toString() ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _money(amount),
                          style: const TextStyle(
                            color: AuvixTheme.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Data: ${_formatDate(date)}',
                          style: const TextStyle(
                            color: AuvixTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        if (notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(notes),
                        ],
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
bool _isOverdue(Map<String, dynamic> debt) {
  if (_remainingBalance(debt) <= 0.009) return false;

  final now = DateTime.now();
  final date = _date(debt['dueDate']);

  final dueDay = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);

  return dueDay.isBefore(today);
}

  Color _debtColor(Map<String, dynamic> debt) {
if (_remainingBalance(debt) <= 0.009) {
  return AuvixTheme.accent;
}

    if (_isOverdue(debt)) {
      return const Color(0xFFFF6577);
    }

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
final remaining = _remainingBalance(debt);
final paid = remaining <= 0.009;
final hasPayments = _totalPaid(debt) > 0;
final overdue = _isOverdue(debt);

final status = paid
    ? 'PAGA'
    : hasPayments
        ? (overdue
            ? 'PARCIAL • EM ATRASO'
            : 'PARCIALMENTE PAGA')
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
                   } else if (value == 'payment') {
  _registerPayment(debt);
} else if (value == 'history') {
  _showPaymentHistory(debt);
}
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
const PopupMenuItem(
  value: 'payment',
  child: Text('Registrar pagamento'),
),
const PopupMenuItem(
  value: 'history',
  child: Text('Histórico de pagamentos'),
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
                      'Total: ${_money(_number(debt['amount']))}',
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pago: ${_money(_totalPaid(debt))}',
                      style: const TextStyle(
                        color: AuvixTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Restante: ${_money(remaining)}',
                      style: TextStyle(
                        color: remaining <= 0.009
                            ? AuvixTheme.accent
                            : color,
                        fontSize: 16,
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
