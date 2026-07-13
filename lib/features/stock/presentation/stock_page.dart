import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  static const _categories = <String>[
    'Feed',
    'Vaccines',
    'Medicines',
    'Farm Supplies',
  ];

  @override
  Widget build(BuildContext context) {
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(
        title: const Text('Stock Management'),
      ),
      body: stockItemsAsync.when(
        data: (items) => RefreshIndicator(
          color: AppColors.leakukuGreen,
          onRefresh: () async {
            ref.invalidate(stockItemsProvider);
            await ref.read(stockItemsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildOverviewHeader(context),
              const SizedBox(height: 12),
              _buildActionButtons(context, items),
              const SizedBox(height: 16),
              _buildOverviewGrid(context, items),
              const SizedBox(height: 18),
              _buildCategorySection(
                context,
                title: 'Feed Stock',
                icon: FontAwesomeIcons.bowlFood,
                items: _itemsByCategory(items, 'Feed'),
              ),
              const SizedBox(height: 14),
              _buildCategorySection(
                context,
                title: 'Vaccines',
                icon: FontAwesomeIcons.syringe,
                items: _itemsByCategory(items, 'Vaccines'),
              ),
              const SizedBox(height: 14),
              _buildCategorySection(
                context,
                title: 'Medicines',
                icon: FontAwesomeIcons.briefcaseMedical,
                items: _itemsByCategory(items, 'Medicines'),
              ),
              const SizedBox(height: 14),
              _buildCategorySection(
                context,
                title: 'Farm Supplies',
                icon: FontAwesomeIcons.bucket,
                items: _itemsByCategory(items, 'Farm Supplies'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.leakukuGreen),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.errorRed, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Could not load stock right now.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(stockItemsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context) {
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
                child: FaIcon(FontAwesomeIcons.boxOpen, color: AppColors.leakukuGreen, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'What you have, what you used, and what to restock.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, List<StockItemModel> items) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openAddStockSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Stock'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: items.isEmpty ? null : () => _openUseStockSheet(context, items),
            icon: const Icon(Icons.remove),
            label: const Text('Use Stock'),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid(BuildContext context, List<StockItemModel> items) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _categoryOverviewCard(context, items, 'Feed', FontAwesomeIcons.bowlFood, AppColors.leakukuGreen),
        _categoryOverviewCard(context, items, 'Vaccines', FontAwesomeIcons.syringe, AppColors.harvestGold),
        _categoryOverviewCard(context, items, 'Medicines', FontAwesomeIcons.briefcaseMedical, AppColors.informationBlue),
        _categoryOverviewCard(context, items, 'Farm Supplies', FontAwesomeIcons.bucket, AppColors.softGray),
      ],
    );
  }

  Widget _categoryOverviewCard(
    BuildContext context,
    List<StockItemModel> items,
    String category,
    FaIconData icon,
    Color color,
  ) {
    final categoryItems = _itemsByCategory(items, category);
    final lowCount = categoryItems.where((item) => item.isLowStock).length;
    final statusLabel = categoryItems.isEmpty
        ? 'No items'
        : lowCount > 0
            ? '$lowCount low'
            : 'In stock';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(icon, color: color, size: 16),
              ),
            ),
            const Spacer(),
            Text(
              category,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${categoryItems.length} item${categoryItems.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            _stockStatusChip(statusLabel, lowCount > 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required FaIconData icon,
    required List<StockItemModel> items,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, size: 16, color: AppColors.leakukuGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                'No items recorded yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              )
            else
              ...items.map((item) => _stockItemCard(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _stockItemCard(BuildContext context, StockItemModel item) {
    final historyAsync = ref.watch(stockHistoryProvider(item.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.farmCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatQuantity(item.quantity)} ${item.unit}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.earthCharcoal),
                    ),
                  ],
                ),
              ),
              _stockStatusChip(item.isLowStock ? 'Low Stock' : 'In Stock', item.isLowStock),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _metaText('Min: ${_formatQuantity(item.minimumLevel)} ${item.unit}'),
              _metaText('Updated: ${_formatDate(item.lastUpdated)}'),
              if (item.expiryDate != null) _metaText('Expiry: ${_formatDate(item.expiryDate!)}'),
            ],
          ),
          const SizedBox(height: 8),
          _buildHistoryPanel(context, historyAsync),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(
      BuildContext context, AsyncValue<List<StockHistoryModel>> historyAsync) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return Text(
            'No stock history yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          );
        }

        final visible = history.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock History',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            ...visible.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        _formatDate(entry.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${entry.action}: ${_formatQuantity(entry.quantity)} ${entry.unit}',
                        style: Theme.of(context).textTheme.bodySmall,
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
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 20,
        child: LinearProgressIndicator(color: AppColors.leakukuGreen),
      ),
      error: (_, __) => Text(
        'Could not load history.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.errorRed),
      ),
    );
  }

  Widget _metaText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
    );
  }

  Widget _stockStatusChip(String label, bool isLow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.warningAmber.withValues(alpha: 0.18)
            : AppColors.leakukuGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isLow ? '⚠ $label' : '🟢 $label',
        style: TextStyle(
          color: isLow ? AppColors.warningAmber : AppColors.leakukuGreen,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  List<StockItemModel> _itemsByCategory(List<StockItemModel> items, String category) {
    return items.where((item) => item.category == category).toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity.toStringAsFixed(1);
  }

  Future<void> _openAddStockSheet(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String category = _categories.first;
    String unit = 'Bags';
    DateTime selectedDate = DateTime.now();
    DateTime? expiryDate;

    final itemNameController = TextEditingController();
    final quantityController = TextEditingController();
    final supplierController = TextEditingController();
    final costController = TextEditingController();

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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Quantity'),
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
                                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
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
                      controller: supplierController,
                      decoration: const InputDecoration(labelText: 'Supplier (Optional)'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cost (Optional)'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
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

                          final quantity = double.tryParse(quantityController.text.trim());
                          final cost = costController.text.trim().isEmpty
                              ? null
                              : double.tryParse(costController.text.trim());

                          if (quantity == null || quantity <= 0) {
                            _showMessage(context, 'Enter a valid quantity.');
                            return;
                          }

                          try {
                            await ref.read(stockControllerProvider).addStock(
                                  category: category,
                                  itemName: itemNameController.text.trim(),
                                  quantity: quantity,
                                  unit: unit,
                                  date: selectedDate,
                                  supplier: supplierController.text.trim().isEmpty
                                      ? null
                                      : supplierController.text.trim(),
                                  cost: cost,
                                  expiryDate: expiryDate,
                                );

                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pop();
                            _showMessage(this.context, 'Stock saved successfully.');
                          } catch (error) {
                            _showMessage(this.context, '$error');
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

  Future<void> _openUseStockSheet(BuildContext context, List<StockItemModel> items) async {
    final formKey = GlobalKey<FormState>();
    String category = _categories.first;
    DateTime selectedDate = DateTime.now();
    StockItemModel? selectedItem = _firstItemForCategory(items, category);

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
          final categoryItems = _itemsByCategory(items, category);
          if (selectedItem == null || !categoryItems.any((item) => item.id == selectedItem!.id)) {
            selectedItem = categoryItems.isEmpty ? null : categoryItems.first;
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
                      'Use Stock',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          category = value;
                          selectedItem = _firstItemForCategory(items, category);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedItem?.id,
                      decoration: const InputDecoration(labelText: 'Item'),
                      items: categoryItems
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                          .toList(),
                      onChanged: categoryItems.isEmpty
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }
                              setModalState(() {
                                selectedItem = categoryItems.firstWhere((item) => item.id == value);
                              });
                            },
                      validator: (_) {
                        if (selectedItem == null) {
                          return 'No item available for this category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: quantityUsedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Quantity Used'),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter valid quantity';
                        }
                        if (selectedItem != null && parsed > selectedItem!.quantity) {
                          return 'Cannot exceed current stock';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => pickDate(setModalState),
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate() || selectedItem == null) {
                            return;
                          }

                          final quantity = double.tryParse(quantityUsedController.text.trim());
                          if (quantity == null || quantity <= 0) {
                            _showMessage(context, 'Enter a valid quantity used.');
                            return;
                          }

                          try {
                            await ref.read(stockControllerProvider).useStock(
                                  itemId: selectedItem!.id,
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
                            _showMessage(this.context, 'Stock usage saved.');
                          } catch (error) {
                            _showMessage(this.context, '$error');
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

  StockItemModel? _firstItemForCategory(List<StockItemModel> items, String category) {
    final filtered = _itemsByCategory(items, category);
    if (filtered.isEmpty) {
      return null;
    }
    return filtered.first;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
