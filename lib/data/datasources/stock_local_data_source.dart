import 'package:hive/hive.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';

abstract class StockLocalDataSource {
  Future<void> seedDefaultStock();
  Future<List<StockItemModel>> getAllItems();
  Future<List<StockItemModel>> getItemsByCategory(String category);
  Future<List<StockHistoryModel>> getItemHistory(String itemId);
  Future<void> addStock({
    required String category,
    required String itemName,
    required double quantity,
    required String unit,
    double? minimumLevel,
    required DateTime date,
    String? supplier,
    double? cost,
    DateTime? expiryDate,
    String? notes,
  });
  Future<void> useStock({
    required String itemId,
    required double quantityUsed,
    required DateTime date,
    String? notes,
  });
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final Box<StockItemModel> _stockItemBox;
  final Box<List<dynamic>> _stockHistoryBox;

  StockLocalDataSourceImpl({
    required Box<StockItemModel> stockItemBox,
    required Box<List<dynamic>> stockHistoryBox,
  })  : _stockItemBox = stockItemBox,
        _stockHistoryBox = stockHistoryBox;

  @override
  Future<void> seedDefaultStock() async {
    // Intentionally left empty: stock starts from user-managed inventory only.
    return;
  }

  @override
  Future<List<StockItemModel>> getAllItems() async {
    final items = _stockItemBox.values.toList();
    items.sort((a, b) {
      final categoryCompare = a.category.compareTo(b.category);
      if (categoryCompare != 0) {
        return categoryCompare;
      }
      return a.name.compareTo(b.name);
    });
    return items;
  }

  @override
  Future<List<StockItemModel>> getItemsByCategory(String category) async {
    final all = await getAllItems();
    return all.where((item) => item.category == category).toList();
  }

  @override
  Future<List<StockHistoryModel>> getItemHistory(String itemId) async {
    final rawList = _stockHistoryBox.get(itemId);
    if (rawList == null) {
      return [];
    }

    final history = rawList.whereType<StockHistoryModel>().toList();
    history.sort((a, b) => b.date.compareTo(a.date));
    return history;
  }

  @override
  Future<void> addStock({
    required String category,
    required String itemName,
    required double quantity,
    required String unit,
    double? minimumLevel,
    required DateTime date,
    String? supplier,
    double? cost,
    DateTime? expiryDate,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final existing = _stockItemBox.values.firstWhere(
      (item) =>
          item.category.toLowerCase() == category.toLowerCase() &&
          item.name.toLowerCase() == itemName.toLowerCase(),
      orElse: () => StockItemModel(
        id: '',
        category: category,
        name: itemName,
        quantity: 0,
        unit: unit,
        minimumLevel: minimumLevel ?? _defaultMinimumLevel(category, unit),
        lastUpdated: date,
      ),
    );

    final itemId = existing.id.isEmpty
        ? '${_slug(category)}_${_slug(itemName)}'
        : existing.id;

    final currentQuantity = existing.id.isEmpty ? 0.0 : existing.quantity;
    final updatedItem = StockItemModel(
      id: itemId,
      category: category,
      name: itemName,
      quantity: currentQuantity + quantity,
      unit: unit,
      minimumLevel: minimumLevel ??
          (existing.id.isEmpty
              ? _defaultMinimumLevel(category, unit)
              : existing.minimumLevel),
      lastUpdated: date,
      expiryDate: expiryDate ?? existing.expiryDate,
      supplier: supplier ?? existing.supplier,
      cost: cost ?? existing.cost,
    );

    await _stockItemBox.put(updatedItem.id, updatedItem);
    await _appendHistory(
      StockHistoryModel(
        id: '${updatedItem.id}_${date.microsecondsSinceEpoch}_add',
        itemId: updatedItem.id,
        category: updatedItem.category,
        itemName: updatedItem.name,
        action: 'Added',
        quantity: quantity,
        unit: updatedItem.unit,
        date: date,
        balanceAfter: updatedItem.quantity,
        notes: notes,
      ),
    );
  }

  @override
  Future<void> useStock({
    required String itemId,
    required double quantityUsed,
    required DateTime date,
    String? notes,
  }) async {
    if (quantityUsed <= 0) {
      throw Exception('Quantity used must be greater than zero.');
    }

    final existing = _stockItemBox.get(itemId);
    if (existing == null) {
      throw Exception('Stock item not found.');
    }

    if (quantityUsed > existing.quantity) {
      throw Exception('Quantity used cannot exceed current stock.');
    }

    final updatedItem = StockItemModel(
      id: existing.id,
      category: existing.category,
      name: existing.name,
      quantity: existing.quantity - quantityUsed,
      unit: existing.unit,
      minimumLevel: existing.minimumLevel,
      lastUpdated: date,
      expiryDate: existing.expiryDate,
      supplier: existing.supplier,
      cost: existing.cost,
    );

    await _stockItemBox.put(updatedItem.id, updatedItem);
    await _appendHistory(
      StockHistoryModel(
        id: '${updatedItem.id}_${date.microsecondsSinceEpoch}_use',
        itemId: updatedItem.id,
        category: updatedItem.category,
        itemName: updatedItem.name,
        action: 'Used',
        quantity: quantityUsed,
        unit: updatedItem.unit,
        date: date,
        balanceAfter: updatedItem.quantity,
        notes: notes,
      ),
    );
  }

  Future<void> _appendHistory(StockHistoryModel historyItem) async {
    final rawList = _stockHistoryBox.get(historyItem.itemId) ?? <dynamic>[];
    final typed = rawList.whereType<StockHistoryModel>().toList();
    typed.add(historyItem);
    await _stockHistoryBox.put(historyItem.itemId, typed);
  }

  double _defaultMinimumLevel(String category, String unit) {
    final lowerCategory = category.toLowerCase();
    final lowerUnit = unit.toLowerCase();

    if (lowerCategory == 'feed') {
      return lowerUnit == 'kg' ? 100 : 5;
    }
    if (lowerCategory == 'vaccines') {
      return 6;
    }
    if (lowerCategory == 'medicines') {
      return 2;
    }
    return 3;
  }

  String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
