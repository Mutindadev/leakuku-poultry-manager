import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/datasources/stock_local_data_source.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';

final stockLocalDataSourceProvider = Provider<StockLocalDataSource>((ref) {
  final itemBox = Hive.box<StockItemModel>('stockItemBox');
  final historyBox = Hive.box<List<dynamic>>('stockHistoryBox');
  return StockLocalDataSourceImpl(
    stockItemBox: itemBox,
    stockHistoryBox: historyBox,
  );
});

final stockItemsProvider = FutureProvider<List<StockItemModel>>((ref) async {
  final dataSource = ref.read(stockLocalDataSourceProvider);
  return dataSource.getAllItems();
});

final stockHistoryProvider =
    FutureProvider.family<List<StockHistoryModel>, String>((ref, itemId) async {
  final dataSource = ref.read(stockLocalDataSourceProvider);
  return dataSource.getItemHistory(itemId);
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
    await ref.read(stockLocalDataSourceProvider).addStock(
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
    await ref.read(stockLocalDataSourceProvider).useStock(
          itemId: itemId,
          quantityUsed: quantityUsed,
          date: date,
          notes: notes,
        );
    ref.invalidate(stockItemsProvider);
    ref.invalidate(stockHistoryProvider(itemId));
  }
}
