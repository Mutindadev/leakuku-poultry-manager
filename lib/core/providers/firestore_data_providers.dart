import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_backup_service.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/core/services/notification_service.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';

final firestoreSyncQueueProvider = Provider<FirestoreSyncQueue>((ref) {
  return FirestoreSyncQueue(
    queueBox: Hive.box<Map<dynamic, dynamic>>('firestoreSyncQueue'),
  );
});

final firestoreFlockDataSourceProvider =
    Provider<FirestoreCollectionDataSource<FlockModel>>((ref) {
  return FirestoreCollectionDataSource<FlockModel>(
    collectionName: FirestoreCollections.flocks,
    decode: FlockModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firestoreStockItemDataSourceProvider =
    Provider<FirestoreCollectionDataSource<StockItemModel>>((ref) {
  return FirestoreCollectionDataSource<StockItemModel>(
    collectionName: FirestoreCollections.stockItems,
    decode: StockItemModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firestoreStockHistoryDataSourceProvider =
    Provider<FirestoreCollectionDataSource<StockHistoryModel>>((ref) {
  return FirestoreCollectionDataSource<StockHistoryModel>(
    collectionName: FirestoreCollections.stockHistory,
    decode: StockHistoryModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firestoreFinancialTransactionDataSourceProvider =
    Provider<FirestoreCollectionDataSource<FinancialTransactionModel>>((ref) {
  return FirestoreCollectionDataSource<FinancialTransactionModel>(
    collectionName: FirestoreCollections.financialTransactions,
    decode: FinancialTransactionModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firestoreVaccineDataSourceProvider =
    Provider<FirestoreCollectionDataSource<VaccineModel>>((ref) {
  return FirestoreCollectionDataSource<VaccineModel>(
    collectionName: FirestoreCollections.vaccines,
    parentCollection: FirestoreCollections.flocks,
    decode: VaccineModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firestoreWeeklyPlanDataSourceProvider =
    Provider<FirestoreCollectionDataSource<WeeklyPlanModel>>((ref) {
  return FirestoreCollectionDataSource<WeeklyPlanModel>(
    collectionName: FirestoreCollections.weeklyPlans,
    parentCollection: FirestoreCollections.flocks,
    decode: WeeklyPlanModel.fromMap,
    encode: (model) => model.toMap(),
  );
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreBackupServiceProvider = Provider<FirestoreBackupService>((ref) {
  return FirestoreBackupService(
    flockBox: Hive.box<FlockModel>('flockBox'),
    stockItemBox: Hive.box<StockItemModel>('stockItemBox'),
    stockHistoryBox: Hive.box<List<StockHistoryModel>>('stockHistoryBox'),
    transactionBox: Hive.box<FinancialTransactionModel>(
      'farmFinanceTransactionBox',
    ),
    vaccineBox: Hive.box<List<dynamic>>('vaccineBox'),
    weeklyPlanBox: Hive.box<List<WeeklyPlanModel>>('weeklyPlanBox'),
    flocks: ref.watch(firestoreFlockDataSourceProvider),
    stockItems: ref.watch(firestoreStockItemDataSourceProvider),
    stockHistory: ref.watch(firestoreStockHistoryDataSourceProvider),
    transactions: ref.watch(firestoreFinancialTransactionDataSourceProvider),
    vaccines: ref.watch(firestoreVaccineDataSourceProvider),
    weeklyPlans: ref.watch(firestoreWeeklyPlanDataSourceProvider),
    syncQueue: ref.watch(firestoreSyncQueueProvider),
    notificationService: NotificationService(),
  );
});
