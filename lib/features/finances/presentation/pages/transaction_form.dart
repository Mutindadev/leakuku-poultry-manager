import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/presentation/providers/farm_finance_provider.dart';

class TransactionFormSheet extends StatefulWidget {
  final String transactionType;
  final FinancialTransactionModel? existing;
  final Future<void> Function({
    required String selectedType,
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
    String? relatedFlock,
    String? paymentMethod,
  }) onSave;

  const TransactionFormSheet({
    super.key,
    required this.transactionType,
    required this.onSave,
    this.existing,
  });

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _relatedFlockController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  late String _selectedType;
  late DateTime _selectedDate;
  String? _selectedCategory;
  bool _isSaving = false;

  List<String> get _categories =>
      _selectedType == 'income' ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existing?.transactionType ?? widget.transactionType;
    _selectedDate = widget.existing?.date ?? DateTime.now();
    _selectedCategory = widget.existing?.category;
    _amountController.text = widget.existing?.amount.toStringAsFixed(2) ?? '';
    _notesController.text = widget.existing?.notes ?? '';
    _relatedFlockController.text = widget.existing?.relatedFlock ?? '';
    _paymentMethodController.text = widget.existing?.paymentMethod ?? '';

    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _relatedFlockController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onSave(
      selectedType: _selectedType,
      category: _selectedCategory!,
      amount: amount,
      date: _selectedDate,
      notes: _notesController.text,
      relatedFlock: _relatedFlockController.text,
      paymentMethod: _paymentMethodController.text,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null
                    ? (_selectedType == 'income' ? 'Add Income' : 'Add Expense')
                    : 'Edit Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedType = value;
                          _selectedCategory = null;
                        });
                      },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() {
                          _selectedCategory = value;
                        }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose a category.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                enabled: !_isSaving,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'KES ',
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter an amount greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(dateFormat.format(_selectedDate)),
                trailing: TextButton(
                  onPressed: _isSaving ? null : _pickDate,
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                enabled: !_isSaving,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _relatedFlockController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Related Flock (optional)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _paymentMethodController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Payment Method (optional)',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.existing == null
                      ? 'Save Transaction'
                      : 'Update Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
