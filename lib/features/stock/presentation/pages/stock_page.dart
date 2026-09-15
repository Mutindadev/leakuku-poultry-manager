import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/features/stock/presentation/pages/stock_category_page.dart';
import 'package:leakuku/features/stock/presentation/widgets/loading_error.dart';
import 'package:leakuku/features/stock/presentation/widgets/stock_category_card.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(
        title: const Text('Stock Management'),
      ),
      body: stockItemsAsync.when(
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _StockHeaderCard(),
            const SizedBox(height: 14),
            StockCategoryCard(
              icon: FontAwesomeIcons.bowlFood,
              title: 'Feed',
              description: 'Manage poultry feeds and remaining stock.',
              itemCountLabel: _itemCountLabel(items, 'Feed'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StockCategoryPage(
                    category: 'Feed',
                    title: 'Feed Stock',
                    emptyMessage: 'No feed has been added yet.',
                    emptyDescription:
                        'Keep your feed inventory up to date by adding your first item.',
                    addButtonLabel: 'Add Feed',
                    icon: FontAwesomeIcons.bowlFood,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StockCategoryCard(
              icon: FontAwesomeIcons.syringe,
              title: 'Vaccines',
              description: 'Track available vaccines and vaccine usage.',
              itemCountLabel: _itemCountLabel(items, 'Vaccines'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StockCategoryPage(
                    category: 'Vaccines',
                    title: 'Vaccines',
                    emptyMessage: 'No vaccines have been added yet.',
                    emptyDescription:
                        'Keep vaccine inventory up to date by adding your first item.',
                    addButtonLabel: 'Add Vaccine',
                    icon: FontAwesomeIcons.syringe,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StockCategoryCard(
              icon: FontAwesomeIcons.briefcaseMedical,
              title: 'Medicines',
              description: 'Manage treatments and health supplies.',
              itemCountLabel: _itemCountLabel(items, 'Medicines'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StockCategoryPage(
                    category: 'Medicines',
                    title: 'Medicines',
                    emptyMessage: 'No medicines have been added yet.',
                    emptyDescription:
                        'Keep your medicine inventory up to date by adding your first item.',
                    addButtonLabel: 'Add Medicine',
                    icon: FontAwesomeIcons.briefcaseMedical,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StockCategoryCard(
              icon: FontAwesomeIcons.bucket,
              title: 'Farm Supplies',
              description: 'Manage equipment and consumable farm materials.',
              itemCountLabel: _itemCountLabel(items, 'Farm Supplies'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StockCategoryPage(
                    category: 'Farm Supplies',
                    title: 'Farm Supplies',
                    emptyMessage: 'No farm supplies have been added yet.',
                    emptyDescription:
                        'Keep your farm supplies inventory up to date by adding your first item.',
                    addButtonLabel: 'Add Supply',
                    icon: FontAwesomeIcons.bucket,
                  ),
                ),
              ),
            ),
          ],
        ),
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

class _StockHeaderCard extends StatelessWidget {
  const _StockHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.boxOpen,
                  color: AppColors.leakukuGreen,
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
                    'Choose Inventory Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.earthCharcoal,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select what you want to manage today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}

String _itemCountLabel(List<StockItemModel> items, String category) {
  final count = items.where((item) => item.category == category).length;
  return '$count Item${count == 1 ? '' : 's'}';
}
