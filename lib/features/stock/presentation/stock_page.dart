import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/features/stock/presentation/widgets/stock_category_card.dart';
import 'package:leakuku/features/stock/presentation/widgets/stock_item_list_tile.dart';
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
                  builder: (_) => const _StockCategoryPage(
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
                  builder: (_) => const _StockCategoryPage(
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
                  builder: (_) => const _StockCategoryPage(
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
                  builder: (_) => const _StockCategoryPage(
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
        error: (error, _) => _StockLoadError(
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

class _StockCategoryPage extends ConsumerWidget {
  final String category;
  final String title;
  final String emptyMessage;
  final String emptyDescription;
  final String addButtonLabel;
  final FaIconData icon;

  const _StockCategoryPage({
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
                  _StockEmptyState(
                    message: emptyMessage,
                    description: emptyDescription,
                    buttonLabel: addButtonLabel,
                    onPressed: () => _openAddStockSheet(
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
                                _StockItemDetailsPage(itemId: item.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAddStockSheet(
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
        error: (error, _) => _StockLoadError(
          message: '$error',
          onRetry: () => ref.invalidate(stockItemsProvider),
        ),
      ),
    );
  }
}

class _StockItemDetailsPage extends ConsumerWidget {
  final String itemId;

  const _StockItemDetailsPage({required this.itemId});

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
                            'Updated: ${_formatDate(item.lastUpdated)}',
                          ),
                          if (item.expiryDate != null)
                            _metaChip(
                              context,
                              'Expiry: ${_formatDate(item.expiryDate!)}',
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
                      onPressed: () => _openAddStockSheet(
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
                      onPressed: () => _openUseStockSheet(
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
                                    child: _HistoryRow(entry: entry),
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
        body: _StockLoadError(
          message: '$error',
          onRetry: () => ref.invalidate(stockItemsProvider),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final StockHistoryModel entry;

  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final actionColor = entry.action == 'Used'
        ? AppColors.warningAmber
        : AppColors.leakukuGreen;

    return Container(
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
              _formatDate(entry.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              '${entry.action} ${_formatQuantity(entry.quantity)} ${entry.unit}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: actionColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            'Bal ${_formatQuantity(entry.balanceAfter)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StockEmptyState extends StatelessWidget {
  final String message;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _StockEmptyState({
    required this.message,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.softGray,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.earthCharcoal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StockLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.errorRed, size: 50),
            const SizedBox(height: 10),
            Text(
              'Could not load stock right now.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _metaChip(BuildContext context, String label, {bool isWarning = false}) {
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

Future<void> _openAddStockSheet(
  BuildContext context,
  WidgetRef ref, {
  required String initialCategory,
  String? fixedItemName,
}) async {
  final formKey = GlobalKey<FormState>();
  String category = initialCategory;
  String unit = _unitOptionsForCategory(initialCategory).first;
  DateTime selectedDate = DateTime.now();
  DateTime? expiryDate;

  final itemNameController = TextEditingController(text: fixedItemName ?? '');
  final quantityController = TextEditingController();
  final minimumStockController = TextEditingController();
  final supplierController = TextEditingController();
  final costController = TextEditingController();
  final notesController = TextEditingController();

  Future<void> pickDate(StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setModalState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickExpiry(StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setModalState(() {
        expiryDate = picked;
      });
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        final unitOptions = _unitOptionsForCategory(category);
        if (!unitOptions.contains(unit)) {
          unit = unitOptions.first;
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Stock',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _stockCategories
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: fixedItemName != null
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() {
                              category = value;
                            });
                          },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: itemNameController,
                    readOnly: fixedItemName != null,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter item name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                          validator: (value) {
                            final parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter valid quantity';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: unitOptions
                              .map(
                                (item) => DropdownMenuItem(
                                    value: item, child: Text(item)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() {
                              unit = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: minimumStockController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Minimum Stock'),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Enter minimum stock';
                      }
                      final parsed = double.tryParse(trimmed);
                      if (parsed == null || parsed < 0) {
                        return 'Enter valid minimum stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: supplierController,
                    decoration:
                        const InputDecoration(labelText: 'Supplier (Optional)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: costController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Cost (Optional)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle:
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => pickDate(setModalState),
                  ),
                  if (category == 'Vaccines')
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Expiry Date (Optional)'),
                      subtitle: Text(
                        expiryDate == null
                            ? 'Not set'
                            : DateFormat('dd MMM yyyy').format(expiryDate!),
                      ),
                      trailing: const Icon(Icons.event_available),
                      onTap: () => pickExpiry(setModalState),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        final quantity =
                            double.tryParse(quantityController.text.trim());
                        final minimumStock =
                            double.tryParse(minimumStockController.text.trim());
                        final cost = costController.text.trim().isEmpty
                            ? null
                            : double.tryParse(costController.text.trim());

                        if (quantity == null || quantity <= 0) {
                          _showMessage(context, 'Enter a valid quantity.');
                          return;
                        }

                        if (minimumStock == null || minimumStock < 0) {
                          _showMessage(context, 'Enter a valid minimum stock.');
                          return;
                        }

                        try {
                          await ref.read(stockControllerProvider).addStock(
                                category: category,
                                itemName: itemNameController.text.trim(),
                                quantity: quantity,
                                unit: unit,
                                minimumLevel: minimumStock,
                                date: selectedDate,
                                supplier: supplierController.text.trim().isEmpty
                                    ? null
                                    : supplierController.text.trim(),
                                cost: cost,
                                expiryDate: expiryDate,
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );

                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          _showMessage(context, 'Stock saved successfully.');
                        } catch (error) {
                          _showMessage(context, '$error');
                        }
                      },
                      child: const Text('Save Stock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> _openUseStockSheet(
  BuildContext context,
  WidgetRef ref, {
  required StockItemModel selectedItem,
}) async {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  final quantityUsedController = TextEditingController();
  final notesController = TextEditingController();

  Future<void> pickDate(StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setModalState(() {
        selectedDate = picked;
      });
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Stock',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: selectedItem.category,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: selectedItem.name,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Item'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: quantityUsedController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Quantity Used'),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter valid quantity';
                      }
                      if (parsed > selectedItem.quantity) {
                        return 'Cannot exceed current stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle:
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => pickDate(setModalState),
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration:
                        const InputDecoration(labelText: 'Notes (Optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        final quantity =
                            double.tryParse(quantityUsedController.text.trim());
                        if (quantity == null || quantity <= 0) {
                          _showMessage(context, 'Enter a valid quantity used.');
                          return;
                        }

                        try {
                          await ref.read(stockControllerProvider).useStock(
                                itemId: selectedItem.id,
                                quantityUsed: quantity,
                                date: selectedDate,
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );

                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          _showMessage(context, 'Stock usage saved.');
                        } catch (error) {
                          _showMessage(context, '$error');
                        }
                      },
                      child: const Text('Save Usage'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(1);
}

String _formatDate(DateTime date) {
  return DateFormat('dd MMM').format(date);
}

String _itemCountLabel(List<StockItemModel> items, String category) {
  final count = items.where((item) => item.category == category).length;
  return '$count Item${count == 1 ? '' : 's'}';
}

List<String> _unitOptionsForCategory(String category) {
  switch (category) {
    case 'Feed':
      return const ['Bags', 'Kg'];
    case 'Vaccines':
      return const ['Doses', 'Vials'];
    case 'Medicines':
      return const ['Bottles', 'Packets', 'Liters'];
    default:
      return const ['Pieces', 'Bags', 'Kg'];
  }
}

const _stockCategories = <String>[
  'Feed',
  'Vaccines',
  'Medicines',
  'Farm Supplies',
];
