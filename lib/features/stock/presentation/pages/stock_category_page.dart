import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/stock/presentation/pages/stock_Item_detail_page.dart';
import 'package:leakuku/features/stock/presentation/widgets/bottom_sheets.dart';
import 'package:leakuku/features/stock/presentation/widgets/loading_error.dart';
import 'package:leakuku/features/stock/presentation/widgets/stock_item_list_tile.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';

class StockCategoryPage extends ConsumerWidget {
  final String category;
  final String title;
  final String emptyMessage;
  final String emptyDescription;
  final String addButtonLabel;
  final FaIconData icon;

  const StockCategoryPage({
    super.key,
    required this.category,
    required this.title,
    required this.emptyMessage,
    required this.emptyDescription,
    required this.addButtonLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(title: Text(title)),
      body: stockItemsAsync.when(
        data: (items) {
          final categoryItems = items
              .where((item) => item.category == category)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return RefreshIndicator(
            color: AppColors.leakukuGreen,
            onRefresh: () async {
              ref.invalidate(stockItemsProvider);
              await ref.read(stockItemsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        FaIcon(icon, size: 18, color: AppColors.leakukuGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap an item to view details, add stock, or record usage.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (categoryItems.isEmpty)
                  StockEmptyState(
                    message: emptyMessage,
                    description: emptyDescription,
                    buttonLabel: addButtonLabel,
                    onPressed: () => openAddStockSheet(
                      context,
                      ref,
                      initialCategory: category,
                    ),
                  )
                else ...[
                  ...categoryItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StockItemListTile(
                        item: item,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StockItemDetailsPage(itemId: item.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => openAddStockSheet(
                        context,
                        ref,
                        initialCategory: category,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(addButtonLabel),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.leakukuGreen),
        ),
        error: (error, _) => StockLoadError(
          message: '$error',
          onRetry: () => ref.invalidate(stockItemsProvider),
        ),
      ),
    );
  }
}
