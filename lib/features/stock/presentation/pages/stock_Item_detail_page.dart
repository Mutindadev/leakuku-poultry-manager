import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/features/stock/presentation/widgets/bottom_sheets.dart';
import 'package:leakuku/features/stock/presentation/widgets/loading_error.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';

class StockItemDetailsPage extends ConsumerWidget {
  final String itemId;

  const StockItemDetailsPage({
    super.key,
    required this.itemId,
  });

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(stockItemsProvider);

    return itemsAsync.when(
      data: (items) {
        StockItemModel? item;
        for (final entry in items) {
          if (entry.id == itemId) {
            item = entry;
            break;
          }
        }

        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Details')),
            body: const Center(child: Text('Item not found.')),
          );
        }

        final historyAsync = ref.watch(stockHistoryProvider(item.id));

        return Scaffold(
          backgroundColor: AppColors.farmCream,
          appBar: AppBar(title: Text(item.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stock',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.earthCharcoal,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatQuantity(item.quantity)} ${item.unit}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.leakukuGreen,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _metaChip(
                            context,
                            item.isLowStock ? 'Low Stock' : 'In Stock',
                            isWarning: item.isLowStock,
                          ),
                          _metaChip(
                            context,
                            'Min: ${_formatQuantity(item.minimumLevel)} ${item.unit}',
                          ),
                          _metaChip(
                            context,
                            'Updated: ${DateFormat('dd MMM').format(item.lastUpdated)}',
                          ),
                          if (item.expiryDate != null)
                            _metaChip(
                              context,
                              'Expiry: ${DateFormat('dd MMM').format(item.expiryDate!)}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => openAddStockSheet(
                        context,
                        ref,
                        initialCategory: item!.category,
                        fixedItemName: item.name,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stock'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openUseStockSheet(
                        context,
                        ref,
                        selectedItem: item!,
                      ),
                      icon: const Icon(Icons.remove),
                      label: const Text('Use Stock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Movement History',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 10),
                      historyAsync.when(
                        data: (history) {
                          if (history.isEmpty) {
                            return Text(
                              'No stock history yet.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            );
                          }

                          return Column(
                            children: history
                                .take(12)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    // child: _HistoryRow(entry: entry),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.farmCream,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 76,
                                            child: Text(
                                              DateFormat('dd MMM')
                                                  .format(entry.date),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${entry.action} ${_formatQuantity(entry.quantity)} ${entry.unit}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: entry.action ==
                                                            'Used'
                                                        ? AppColors.warningAmber
                                                        : AppColors
                                                            .leakukuGreen,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            'Bal ${_formatQuantity(entry.balanceAfter)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(
                            color: AppColors.leakukuGreen,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Could not load history.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.errorRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.leakukuGreen),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: StockLoadError(
          message: '$error',
          onRetry: () => ref.invalidate(stockItemsProvider),
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, String label,
      {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.warningAmber.withValues(alpha: 0.16)
            : AppColors.leakukuGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isWarning ? AppColors.warningAmber : AppColors.leakukuGreen,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
