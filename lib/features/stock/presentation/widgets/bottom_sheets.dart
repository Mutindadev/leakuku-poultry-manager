import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';

Future<void> openAddStockSheet(
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

Future<void> openUseStockSheet(
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
