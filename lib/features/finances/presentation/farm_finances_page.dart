import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/presentation/providers/farm_finance_provider.dart';

class FarmFinancesPage extends ConsumerStatefulWidget {
  const FarmFinancesPage({super.key});

  @override
  ConsumerState<FarmFinancesPage> createState() => _FarmFinancesPageState();
}

class _FarmFinancesPageState extends ConsumerState<FarmFinancesPage> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(farmFinanceProvider.notifier).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final financeState = ref.watch(farmFinanceProvider);
    final incomeRecords = financeState.incomeTransactions;
    final expenseRecords = financeState.expenseTransactions;

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(title: const Text('Farm Finances')),
      body: RefreshIndicator(
        color: AppColors.leakukuGreen,
        onRefresh: () => ref.read(farmFinanceProvider.notifier).loadTransactions(),
        child: financeState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context: context,
                    title: 'Income',
                    icon: FontAwesomeIcons.arrowTrendUp,
                    iconColor: AppColors.successGreen,
                    actionLabel: 'Add Income',
                    emptyMessage: 'No income recorded yet.',
                    emptyDescription: 'Add your first income transaction to keep farm records up to date.',
                    records: incomeRecords,
                    onAdd: () => _openTransactionForm(
                      context,
                      transactionType: 'income',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context: context,
                    title: 'Expenses',
                    icon: FontAwesomeIcons.arrowTrendDown,
                    iconColor: AppColors.errorRed,
                    actionLabel: 'Add Expense',
                    emptyMessage: 'No expenses recorded yet.',
                    emptyDescription: 'Add your first expense transaction to keep farm records complete.',
                    records: expenseRecords,
                    onAdd: () => _openTransactionForm(
                      context,
                      transactionType: 'expense',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryCard(context, financeState.transactions),
                  if (financeState.error != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: AppColors.errorRed.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.errorRed),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                financeState.error!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.harvestGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.sackDollar,
                  color: AppColors.harvestGold,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Farm Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Capture every income and expense. This page is your finance data source.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required FaIconData icon,
    required Color iconColor,
    required String actionLabel,
    required String emptyMessage,
    required String emptyDescription,
    required List<FinancialTransactionModel> records,
    required VoidCallback onAdd,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, color: iconColor, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              _SectionEmptyState(
                message: emptyMessage,
                description: emptyDescription,
                onAdd: onAdd,
                actionLabel: actionLabel,
              )
            else
              ...records.take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TransactionTile(
                        transaction: item,
                        dateLabel: _dateFormat.format(item.date),
                        onView: () => _showTransactionDetails(context, item),
                        onEdit: () => _openTransactionForm(
                          context,
                          transactionType: item.transactionType,
                          existing: item,
                        ),
                        onDelete: () => _confirmDelete(context, item),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    List<FinancialTransactionModel> transactions,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              Text(
                'No transactions recorded yet. Add income or expense to get started.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              )
            else
              ...transactions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TransactionTile(
                    transaction: item,
                    dateLabel: _dateFormat.format(item.date),
                    onView: () => _showTransactionDetails(context, item),
                    onEdit: () => _openTransactionForm(
                      context,
                      transactionType: item.transactionType,
                      existing: item,
                    ),
                    onDelete: () => _confirmDelete(context, item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTransactionForm(
    BuildContext context, {
    required String transactionType,
    FinancialTransactionModel? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (context) {
        return _TransactionFormSheet(
          transactionType: transactionType,
          existing: existing,
          onSave: ({
            required String selectedType,
            required String category,
            required double amount,
            required DateTime date,
            String? notes,
            String? relatedFlock,
            String? paymentMethod,
          }) async {
            final notifier = ref.read(farmFinanceProvider.notifier);
            if (existing == null) {
              await notifier.addTransaction(
                transactionType: selectedType,
                category: category,
                amount: amount,
                date: date,
                notes: notes,
                relatedFlock: relatedFlock,
                paymentMethod: paymentMethod,
              );
            } else {
              await notifier.updateTransaction(
                existing.copyWith(
                  transactionType: selectedType,
                  category: category,
                  amount: amount,
                  date: date,
                  notes: notes,
                  relatedFlock: relatedFlock,
                  paymentMethod: paymentMethod,
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _showTransactionDetails(
    BuildContext context,
    FinancialTransactionModel transaction,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${transaction.isIncome ? 'Income' : 'Expense'}'),
            const SizedBox(height: 6),
            Text('Category: ${transaction.category}'),
            const SizedBox(height: 6),
            Text('Amount: KES ${transaction.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            Text('Date: ${_dateFormat.format(transaction.date)}'),
            const SizedBox(height: 6),
            Text('Notes: ${transaction.notes?.trim().isNotEmpty == true ? transaction.notes : 'None'}'),
            const SizedBox(height: 6),
            Text('Related Flock: ${transaction.relatedFlock?.trim().isNotEmpty == true ? transaction.relatedFlock : 'None'}'),
            const SizedBox(height: 6),
            Text('Payment Method: ${transaction.paymentMethod?.trim().isNotEmpty == true ? transaction.paymentMethod : 'None'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FinancialTransactionModel transaction,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Delete this ${transaction.isIncome ? 'income' : 'expense'} record for ${transaction.category}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await ref.read(farmFinanceProvider.notifier).deleteTransaction(transaction.id);
    }
  }
}

class _SectionEmptyState extends StatelessWidget {
  final String message;
  final String description;
  final String actionLabel;
  final VoidCallback onAdd;

  const _SectionEmptyState({
    required this.message,
    required this.description,
    required this.actionLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final FinancialTransactionModel transaction;
  final String dateLabel;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.dateLabel,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppColors.successGreen : AppColors.errorRed;
    final icon = transaction.isIncome
        ? FontAwesomeIcons.circleArrowUp
        : FontAwesomeIcons.circleArrowDown;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onView,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: FaIcon(icon, size: 14, color: color),
        ),
        title: Text(
          transaction.category,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          '${transaction.isIncome ? 'Income' : 'Expense'} • $dateLabel',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}KES ${transaction.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  onView();
                } else if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text('View')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionFormSheet extends StatefulWidget {
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

  const _TransactionFormSheet({
    required this.transactionType,
    required this.onSave,
    this.existing,
  });

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
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
                      (item) => DropdownMenuItem(value: item, child: Text(item)),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  label: Text(widget.existing == null ? 'Save Transaction' : 'Update Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
