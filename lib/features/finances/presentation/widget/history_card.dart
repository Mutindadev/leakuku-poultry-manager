import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/finances/presentation/widget/transaction_tile.dart';

class HistoryCard extends StatelessWidget {
  final List<FinancialTransactionModel> transactions;

  final Future<void> Function({
    required String transactionType,
    FinancialTransactionModel? existing,
  }) onOpenTransactionForm;

  final Future<void> Function(
    FinancialTransactionModel transaction,
  ) onViewTransaction;

  final Future<void> Function(
    FinancialTransactionModel transaction,
  ) onDeleteTransaction;

  const HistoryCard({
    super.key,
    required this.transactions,
    required this.onOpenTransactionForm,
    required this.onViewTransaction,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

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
                  child: TransactionTile(
                    transaction: item,
                    dateLabel: _dateFormat.format(item.date),
                    onView: () => onViewTransaction(item),
                    onEdit: () => onOpenTransactionForm(
                      transactionType: item.transactionType,
                      existing: item,
                    ),
                    onDelete: () => onDeleteTransaction(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
