import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/finances/presentation/pages/transaction_form.dart';
import 'package:leakuku/features/finances/presentation/widget/history_card.dart';
import 'package:leakuku/features/finances/presentation/widget/section_card.dart';
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
    Future.microtask(
        () => ref.read(farmFinanceProvider.notifier).loadTransactions());
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
        onRefresh: () =>
            ref.read(farmFinanceProvider.notifier).loadTransactions(),
        child: financeState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Income',
                    icon: FontAwesomeIcons.arrowTrendUp,
                    iconColor: AppColors.successGreen,
                    actionLabel: 'Add Income',
                    emptyMessage: 'No income recorded yet.',
                    emptyDescription:
                        'Add your first income transaction to keep farm records up to date.',
                    records: incomeRecords,
                    onAdd: () => _openTransactionForm(
                      transactionType: 'income',
                    ),
                    onOpenTransactionForm: ({
                      required String transactionType,
                      FinancialTransactionModel? existing,
                    }) =>
                        _openTransactionForm(
                      transactionType: transactionType,
                      existing: existing,
                    ),
                    onViewTransaction: (transaction) =>
                        _showTransactionDetails(transaction),
                    onDeleteTransaction: (transaction) =>
                        _confirmDelete(transaction),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Expenses',
                    icon: FontAwesomeIcons.arrowTrendDown,
                    iconColor: AppColors.errorRed,
                    actionLabel: 'Add Expense',
                    emptyMessage: 'No expenses recorded yet.',
                    emptyDescription:
                        'Add your first expense transaction to keep farm records complete.',
                    records: expenseRecords,
                    onAdd: () => _openTransactionForm(
                      transactionType: 'expense',
                    ),
                    onOpenTransactionForm: ({
                      required String transactionType,
                      FinancialTransactionModel? existing,
                    }) =>
                        _openTransactionForm(
                      transactionType: transactionType,
                      existing: existing,
                    ),
                    onViewTransaction: (transaction) =>
                        _showTransactionDetails(transaction),
                    onDeleteTransaction: (transaction) =>
                        _confirmDelete(transaction),
                  ),
                  const SizedBox(height: 12),
                  HistoryCard(
                    transactions: financeState.transactions,
                    onOpenTransactionForm: ({
                      required String transactionType,
                      FinancialTransactionModel? existing,
                    }) =>
                        _openTransactionForm(
                      transactionType: transactionType,
                      existing: existing,
                    ),
                    onViewTransaction: (transaction) =>
                        _showTransactionDetails(transaction),
                    onDeleteTransaction: (transaction) =>
                        _confirmDelete(transaction),
                  ),
                  if (financeState.error != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: AppColors.errorRed.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.errorRed),
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

  Future<void> _openTransactionForm({
    required String transactionType,
    FinancialTransactionModel? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (context) {
        return TransactionFormSheet(
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
    FinancialTransactionModel transaction,
  ) async {
    await showDialog(
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
            Text(
                'Notes: ${transaction.notes?.trim().isNotEmpty == true ? transaction.notes : 'None'}'),
            const SizedBox(height: 6),
            Text(
                'Related Flock: ${transaction.relatedFlock?.trim().isNotEmpty == true ? transaction.relatedFlock : 'None'}'),
            const SizedBox(height: 6),
            Text(
                'Payment Method: ${transaction.paymentMethod?.trim().isNotEmpty == true ? transaction.paymentMethod : 'None'}'),
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
      await ref
          .read(farmFinanceProvider.notifier)
          .deleteTransaction(transaction.id);
    }
  }
}
