import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/widgets/section_empty_state.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/finances/presentation/widget/transaction_tile.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final FaIconData icon;
  final Color iconColor;
  final String actionLabel;
  final String emptyMessage;
  final String emptyDescription;
  final List<FinancialTransactionModel> records;
  final VoidCallback onAdd;

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

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.emptyMessage,
    required this.emptyDescription,
    required this.records,
    required this.onAdd,
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
              SectionEmptyState(
                message: emptyMessage,
                description: emptyDescription,
                onAdd: onAdd,
                actionLabel: actionLabel,
              )
            else
              ...records.take(4).map(
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
