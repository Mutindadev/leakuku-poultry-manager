import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/providers/firestore_data_providers.dart';
import 'package:leakuku/data/datasources/stock_local_data_source.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';

final stockLocalDataSourceProvider = Provider<StockLocalDataSource>((ref) {
  final itemBox = Hive.box<StockItemModel>('stockItemBox');
  final historyBox = Hive.box<List<StockHistoryModel>>('stockHistoryBox');
  return StockLocalDataSourceImpl(
    stockItemBox: itemBox,
    stockHistoryBox: historyBox,
    syncQueue: ref.watch(firestoreSyncQueueProvider),
  );
});

final stockItemsProvider = FutureProvider<List<StockItemModel>>((ref) async {
  final userId = ref.watch(userProvider).userModel?.uid;
  if (userId == null || userId.isEmpty) return const [];
  final dataSource = ref.read(stockLocalDataSourceProvider);
  return dataSource.getAllItems(userId);
});

final stockHistoryProvider =
    FutureProvider.family<List<StockHistoryModel>, String>((ref, itemId) async {
  final userId = ref.watch(userProvider).userModel?.uid;
  if (userId == null || userId.isEmpty) return const [];
  final dataSource = ref.read(stockLocalDataSourceProvider);
  return dataSource.getItemHistory(userId, itemId);
});

final stockControllerProvider = Provider<StockController>((ref) {
  return StockController(ref);
});

class StockController {
  final Ref ref;

  StockController(this.ref);

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
    final userId = ref.read(userProvider).userModel?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('A signed-in user is required to manage stock.');
    }
    await ref.read(stockLocalDataSourceProvider).addStock(
          userId: userId,
          category: category,
          itemName: itemName,
          quantity: quantity,
          unit: unit,
          minimumLevel: minimumLevel,
          date: date,
          supplier: supplier,
          cost: cost,
          expiryDate: expiryDate,
          notes: notes,
        );
    ref.invalidate(stockItemsProvider);
  }

  Future<void> useStock({
    required String itemId,
    required double quantityUsed,
    required DateTime date,
    String? notes,
  }) async {
    final userId = ref.read(userProvider).userModel?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('A signed-in user is required to manage stock.');
    }
    await ref.read(stockLocalDataSourceProvider).useStock(
          userId: userId,
          itemId: itemId,
          quantityUsed: quantityUsed,
          date: date,
          notes: notes,
        );
    ref.invalidate(stockItemsProvider);
    ref.invalidate(stockHistoryProvider(itemId));
  }

  Future<void> updateItem(StockItemModel item) async {
    final userId = ref.read(userProvider).userModel?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('A signed-in user is required to manage stock.');
    }
    await ref.read(stockLocalDataSourceProvider).updateItem(userId, item);
    ref.invalidate(stockItemsProvider);
  }

  Future<void> deleteItem(String itemId) async {
    final userId = ref.read(userProvider).userModel?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('A signed-in user is required to manage stock.');
    }
    await ref.read(stockLocalDataSourceProvider).deleteItem(userId, itemId);
    ref.invalidate(stockItemsProvider);
    ref.invalidate(stockHistoryProvider(itemId));
  }
}
