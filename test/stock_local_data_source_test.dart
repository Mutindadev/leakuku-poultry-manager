import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/datasources/stock_local_data_source.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';

void main() {
  late Directory hiveDirectory;
  late Box<StockItemModel> stockItemBox;
  late Box<List<StockHistoryModel>> stockHistoryBox;
  late StockLocalDataSourceImpl dataSource;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('leakuku_stock_test');
    Hive.init(hiveDirectory.path);
    Hive.registerAdapter(StockItemModelAdapter());
    Hive.registerAdapter(StockHistoryModelAdapter());
    stockItemBox = await Hive.openBox<StockItemModel>('stockItemBox');
    stockHistoryBox =
        await Hive.openBox<List<StockHistoryModel>>('stockHistoryBox');
    dataSource = StockLocalDataSourceImpl(
      stockItemBox: stockItemBox,
      stockHistoryBox: stockHistoryBox,
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('isolates stock and history by user', () async {
    await dataSource.addStock(
      userId: 'farmer-a',
      category: 'Feed',
      itemName: 'Starter Mash',
      quantity: 20,
      unit: 'kg',
      date: DateTime(2026, 10, 1),
    );
    await dataSource.addStock(
      userId: 'farmer-b',
      category: 'Feed',
      itemName: 'Starter Mash',
      quantity: 35,
      unit: 'kg',
      date: DateTime(2026, 10, 2),
    );

    final farmerAItems = await dataSource.getAllItems('farmer-a');
    final farmerBItems = await dataSource.getAllItems('farmer-b');

    expect(farmerAItems, hasLength(1));
    expect(farmerAItems.single.quantity, 20);
    expect(farmerBItems, hasLength(1));
    expect(farmerBItems.single.quantity, 35);

    final farmerAHistory = await dataSource.getItemHistory(
      'farmer-a',
      farmerAItems.single.id,
    );
    final farmerBHistory = await dataSource.getItemHistory(
      'farmer-b',
      farmerBItems.single.id,
    );

    expect(farmerAHistory, hasLength(1));
    expect(farmerBHistory, hasLength(1));
    expect(farmerAHistory.single.userId, 'farmer-a');
    expect(farmerBHistory.single.userId, 'farmer-b');
  });
}
