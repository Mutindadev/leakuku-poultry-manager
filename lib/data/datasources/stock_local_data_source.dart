import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';

abstract class StockLocalDataSource {
  Future<void> seedDefaultStock();
  Future<List<StockItemModel>> getAllItems(String userId);
  Future<List<StockItemModel>> getItemsByCategory(
    String userId,
    String category,
  );
  Future<List<StockHistoryModel>> getItemHistory(String userId, String itemId);
  Future<void> updateItem(String userId, StockItemModel item);
  Future<void> deleteItem(String userId, String itemId);
  Future<void> addStock({
    required String userId,
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
    required String userId,
    required String itemId,
    required double quantityUsed,
    required DateTime date,
    String? notes,
  });
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final Box<StockItemModel> _stockItemBox;
  final Box<List<StockHistoryModel>> _stockHistoryBox;
  final FirestoreSyncQueue? syncQueue;

  StockLocalDataSourceImpl({
    required Box<StockItemModel> stockItemBox,
    required Box<List<StockHistoryModel>> stockHistoryBox,
    this.syncQueue,
  })  : _stockItemBox = stockItemBox,
        _stockHistoryBox = stockHistoryBox;

  @override
  Future<void> seedDefaultStock() async {
    // Intentionally left empty: stock starts from user-managed inventory only.
    return;
  }

  @override
  Future<List<StockItemModel>> getAllItems(String userId) async {
    await _adoptLegacyRows(userId);
    final items =
        _stockItemBox.values.where((item) => item.userId == userId).toList();
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
  Future<List<StockItemModel>> getItemsByCategory(
    String userId,
    String category,
  ) async {
    final all = await getAllItems(userId);
    return all.where((item) => item.category == category).toList();
  }

  @override
  Future<List<StockHistoryModel>> getItemHistory(
    String userId,
    String itemId,
  ) async {
    final rawList = _stockHistoryBox.get(itemId);
    if (rawList == null) {
      return [];
    }

    final history = rawList
        .whereType<StockHistoryModel>()
        .where((entry) => entry.userId == userId)
        .toList();
    history.sort((a, b) => b.date.compareTo(a.date));
    return history;
  }

  @override
  Future<void> addStock({
    required String userId,
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
          item.userId == userId &&
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
        userId: userId,
      ),
    );

    final itemId = existing.id.isEmpty
        ? '${userId}_${_slug(category)}_${_slug(itemName)}'
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
      userId: userId,
    );

    await _stockItemBox.put(updatedItem.id, updatedItem);
    await syncQueue?.upsert(
      uid: userId,
      collection: FirestoreCollections.stockItems,
      id: updatedItem.id,
      data: updatedItem.toMap(),
    );
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
        userId: userId,
      ),
    );
  }

  @override
  Future<void> useStock({
    required String userId,
    required String itemId,
    required double quantityUsed,
    required DateTime date,
    String? notes,
  }) async {
    if (quantityUsed <= 0) {
      throw Exception('Quantity used must be greater than zero.');
    }

    final existing = _stockItemBox.get(itemId);
    if (existing == null || existing.userId != userId) {
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
      userId: userId,
    );

    await _stockItemBox.put(updatedItem.id, updatedItem);
    await syncQueue?.upsert(
      uid: userId,
      collection: FirestoreCollections.stockItems,
      id: updatedItem.id,
      data: updatedItem.toMap(),
    );
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
        userId: userId,
      ),
    );
  }

  @override
  Future<void> deleteItem(String userId, String itemId) async {
    final item = _stockItemBox.get(itemId);
    if (item == null || item.userId != userId) return;

    final history = await getItemHistory(userId, itemId);
    await _stockItemBox.delete(itemId);
    await _stockHistoryBox.delete(itemId);
    await syncQueue?.delete(
      uid: userId,
      collection: FirestoreCollections.stockItems,
      id: itemId,
    );
    for (final entry in history) {
      await syncQueue?.delete(
        uid: userId,
        collection: FirestoreCollections.stockHistory,
        id: entry.id,
      );
    }
  }

  @override
  Future<void> updateItem(String userId, StockItemModel item) async {
    final existing = _stockItemBox.get(item.id);
    if (existing == null || existing.userId != userId) {
      throw StateError('Stock item not found.');
    }

    final updatedItem = item.copyWith(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
    await _stockItemBox.put(updatedItem.id, updatedItem);
    await syncQueue?.upsert(
      uid: userId,
      collection: FirestoreCollections.stockItems,
      id: updatedItem.id,
      data: updatedItem.toMap(),
    );
  }

  Future<void> _appendHistory(StockHistoryModel historyItem) async {
    final rawList = _stockHistoryBox.get(historyItem.itemId) ?? <dynamic>[];
    final typed = rawList.whereType<StockHistoryModel>().toList();
    typed.add(historyItem);
    await _stockHistoryBox.put(historyItem.itemId, typed);
    await syncQueue?.upsert(
      uid: historyItem.userId,
      collection: FirestoreCollections.stockHistory,
      id: historyItem.id,
      data: historyItem.toMap(),
    );
  }

  Future<void> _adoptLegacyRows(String userId) async {
    if (userId.isEmpty) return;

    for (final item
        in _stockItemBox.values.where((item) => item.userId.isEmpty).toList()) {
      final newId = '${userId}_${item.id}';
      final migratedItem = item.copyWith(id: newId, userId: userId);
      final oldHistory = _stockHistoryBox.get(item.id) ?? const <dynamic>[];
      final migratedHistory = oldHistory
          .whereType<StockHistoryModel>()
          .map((entry) => entry.copyWith(
                id: '${userId}_${entry.id}',
                itemId: newId,
                userId: userId,
              ))
          .toList();

      await _stockItemBox.delete(item.id);
      await _stockItemBox.put(newId, migratedItem);
      await _stockHistoryBox.delete(item.id);
      if (migratedHistory.isNotEmpty) {
        await _stockHistoryBox.put(newId, migratedHistory);
      }
    }
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
