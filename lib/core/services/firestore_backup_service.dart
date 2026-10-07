import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/core/services/notification_service.dart';
import 'package:leakuku/data/datasources/stock_local_data_source.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';

class FirestoreBackupService {
  FirestoreBackupService({
    required this.flockBox,
    required this.stockItemBox,
    required this.stockHistoryBox,
    required this.transactionBox,
    required this.vaccineBox,
    required this.weeklyPlanBox,
    required this.flocks,
    required this.stockItems,
    required this.stockHistory,
    required this.transactions,
    required this.vaccines,
    required this.weeklyPlans,
    required this.syncQueue,
    required this.notificationService,
  });

  final Box<FlockModel> flockBox;
  final Box<StockItemModel> stockItemBox;
  final Box<List<StockHistoryModel>> stockHistoryBox;
  final Box<FinancialTransactionModel> transactionBox;
  final Box<List<dynamic>> vaccineBox;
  final Box<List<WeeklyPlanModel>> weeklyPlanBox;
  final FirestoreCollectionDataSource<FlockModel> flocks;
  final FirestoreCollectionDataSource<StockItemModel> stockItems;
  final FirestoreCollectionDataSource<StockHistoryModel> stockHistory;
  final FirestoreCollectionDataSource<FinancialTransactionModel> transactions;
  final FirestoreCollectionDataSource<VaccineModel> vaccines;
  final FirestoreCollectionDataSource<WeeklyPlanModel> weeklyPlans;
  final FirestoreSyncQueue syncQueue;
  final NotificationService notificationService;
  final Map<String, Future<void>> _activeSyncs = {};

  Future<void> syncUser(String uid) {
    if (uid.trim().isEmpty) return Future<void>.value();
    final activeSync = _activeSyncs[uid];
    if (activeSync != null) return activeSync;

    final sync = _syncUser(uid);
    _activeSyncs[uid] = sync;
    return sync.whenComplete(() => _activeSyncs.remove(uid));
  }

  Future<void> _syncUser(String uid) async {
    var stage = 0;
    const totalStages = 8;
    Future<void> report(String status) async {
      await notificationService.showSyncProgress(
        progressPercent: (stage * 100 / totalStages).round(),
        status: status,
      );
    }

    await report('Checking deleted records');
    try {
      final tombstones = await syncQueue.readTombstones(uid);
      stage++;

      await report('Syncing flocks');
      final localFlocks =
          flockBox.values.where((flock) => flock.userId == uid).toList();
      final remoteFlocks = await flocks.readAll(uid);
      await _reconcile<FlockModel>(
        uid: uid,
        collection: FirestoreCollections.flocks,
        local: localFlocks,
        remote: remoteFlocks,
        idOf: (item) => item.id,
        modifiedAt: (item) => item.updatedAt,
        saveLocal: (item) => flockBox.put(item.id, item),
        deleteLocal: (id) => flockBox.delete(id),
        deletedIds: tombstones[FirestoreCollections.flocks] ?? const {},
        remoteSource: flocks,
      );
      stage++;
      await report('Syncing stock');

      // Re-hydrate first so legacy unowned inventory is assigned to this account.
      final stockLocalSource = StockLocalDataSourceImpl(
        stockItemBox: stockItemBox,
        stockHistoryBox: stockHistoryBox,
        syncQueue: syncQueue,
      );
      final localStockItems = await stockLocalSource.getAllItems(uid);
      final remoteStockItems = await stockItems.readAll(uid);
      await _reconcile<StockItemModel>(
        uid: uid,
        collection: FirestoreCollections.stockItems,
        local: localStockItems,
        remote: remoteStockItems,
        idOf: (item) => item.id,
        modifiedAt: (item) => item.lastUpdated,
        saveLocal: (item) => stockItemBox.put(item.id, item),
        deleteLocal: (id) => stockItemBox.delete(id),
        deletedIds: tombstones[FirestoreCollections.stockItems] ?? const {},
        remoteSource: stockItems,
      );
      stage++;
      await report('Syncing stock history');

      final localHistory = stockHistoryBox.values
          .expand((entries) => entries.whereType<StockHistoryModel>())
          .where((entry) => entry.userId == uid)
          .toList();
      final remoteHistory = await stockHistory.readAll(uid);
      await _reconcile<StockHistoryModel>(
        uid: uid,
        collection: FirestoreCollections.stockHistory,
        local: localHistory,
        remote: remoteHistory,
        idOf: (item) => item.id,
        modifiedAt: (item) => item.date,
        saveLocal: (item) async {
          final existing = stockHistoryBox.get(item.itemId) ?? <dynamic>[];
          final entries = existing.whereType<StockHistoryModel>().toList();
          final index = entries.indexWhere((entry) => entry.id == item.id);
          if (index < 0) {
            entries.add(item);
          } else {
            entries[index] = item;
          }
          await stockHistoryBox.put(item.itemId, entries);
        },
        deleteLocal: (id) async {
          for (final key in stockHistoryBox.keys.toList()) {
            final entries = stockHistoryBox.get(key);
            if (entries == null) continue;
            final remaining = entries
                .whereType<StockHistoryModel>()
                .where((entry) => entry.id != id)
                .toList();
            if (remaining.isEmpty) {
              await stockHistoryBox.delete(key);
            } else if (remaining.length != entries.length) {
              await stockHistoryBox.put(key, remaining);
            }
          }
        },
        deletedIds: tombstones[FirestoreCollections.stockHistory] ?? const {},
        remoteSource: stockHistory,
      );
      stage++;
      await report('Syncing finances');

      final localTransactions =
          transactionBox.values.where((item) => item.userId == uid).toList();
      final remoteTransactions = await transactions.readAll(uid);
      await _reconcile<FinancialTransactionModel>(
        uid: uid,
        collection: FirestoreCollections.financialTransactions,
        local: localTransactions,
        remote: remoteTransactions,
        idOf: (item) => item.id,
        modifiedAt: (item) => item.lastUpdated,
        saveLocal: (item) => transactionBox.put(item.id, item),
        deleteLocal: (id) => transactionBox.delete(id),
        deletedIds:
            tombstones[FirestoreCollections.financialTransactions] ?? const {},
        remoteSource: transactions,
      );
      stage++;
      await report('Syncing vaccinations');

      final ownedFlockIds = flockBox.values
          .where((flock) => flock.userId == uid)
          .map((flock) => flock.id)
          .toSet();
      final localVaccines = vaccineBox.values
          .expand((items) => items.whereType<VaccineModel>())
          .where((item) =>
              item.flockId != null && ownedFlockIds.contains(item.flockId))
          .toList();

      for (final flockId in ownedFlockIds) {
        final localFlockVaccines = localVaccines
            .where((vaccine) => vaccine.flockId == flockId)
            .toList();
        final remoteFlockVaccines =
            await vaccines.readAll(uid, parentId: flockId);
        await _reconcile<VaccineModel>(
          uid: uid,
          collection: FirestoreCollections.vaccines,
          parentCollection: FirestoreCollections.flocks,
          parentId: flockId,
          local: localFlockVaccines,
          remote: remoteFlockVaccines,
          idOf: (item) => item.id,
          modifiedAt: (item) =>
              item.updatedAt ?? item.createdAt ?? DateTime(1970),
          saveLocal: (item) => _saveListRecord<VaccineModel>(
            vaccineBox,
            item.flockId!,
            item,
            (entry) => entry.id,
          ),
          deleteLocal: (id) => _deleteListRecord<VaccineModel>(
            vaccineBox,
            id,
            (entry) => entry.id,
          ),
          deletedIds: tombstones[FirestoreSyncQueue.tombstoneScope(
                FirestoreCollections.vaccines,
                parentCollection: FirestoreCollections.flocks,
                parentId: flockId,
              )] ??
              const {},
          remoteSource: vaccines,
        );
      }
      stage++;
      await report('Syncing weekly plans');

      final localPlans = weeklyPlanBox.values
          .expand((items) => items.whereType<WeeklyPlanModel>())
          .where((item) => ownedFlockIds.contains(item.flockId))
          .toList();
      for (final flockId in ownedFlockIds) {
        final localFlockPlans =
            localPlans.where((plan) => plan.flockId == flockId).toList();
        final remoteFlockPlans =
            await weeklyPlans.readAll(uid, parentId: flockId);
        await _reconcile<WeeklyPlanModel>(
          uid: uid,
          collection: FirestoreCollections.weeklyPlans,
          parentCollection: FirestoreCollections.flocks,
          parentId: flockId,
          local: localFlockPlans,
          remote: remoteFlockPlans,
          idOf: (item) => item.id,
          modifiedAt: (item) => item.updatedAt,
          saveLocal: (item) => _saveListRecord<WeeklyPlanModel>(
            weeklyPlanBox,
            item.flockId,
            item,
            (entry) => entry.id,
          ),
          deleteLocal: (id) => _deleteListRecord<WeeklyPlanModel>(
            weeklyPlanBox,
            id,
            (entry) => entry.id,
          ),
          deletedIds: tombstones[FirestoreSyncQueue.tombstoneScope(
                FirestoreCollections.weeklyPlans,
                parentCollection: FirestoreCollections.flocks,
                parentId: flockId,
              )] ??
              const {},
          remoteSource: weeklyPlans,
        );
      }

      stage++;
      await report('Uploading pending changes');
      await syncQueue.flush();
      stage = totalStages;
      await report('Backup complete');
    } finally {
      await notificationService.cancelSyncProgress();
    }
  }

  Future<void> _reconcile<T>({
    required String uid,
    required String collection,
    String? parentCollection,
    String? parentId,
    required List<T> local,
    required List<T> remote,
    required String Function(T) idOf,
    required DateTime Function(T) modifiedAt,
    required Future<void> Function(T) saveLocal,
    required Future<void> Function(String id) deleteLocal,
    required Set<String> deletedIds,
    required FirestoreCollectionDataSource<T> remoteSource,
  }) async {
    final localById = {for (final item in local) idOf(item): item};
    final remoteById = {for (final item in remote) idOf(item): item};
    final ids = {...localById.keys, ...remoteById.keys};

    for (final id in ids) {
      if (syncQueue.hasPendingOperation(
        uid,
        collection,
        id,
        parentCollection: parentCollection,
        parentId: parentId,
      )) {
        continue;
      }
      if (deletedIds.contains(id)) {
        await deleteLocal(id);
        continue;
      }

      final localItem = localById[id];
      final remoteItem = remoteById[id];
      if (localItem == null && remoteItem != null) {
        await saveLocal(remoteItem);
      } else if (localItem != null && remoteItem == null) {
        await syncQueue.upsert(
          uid: uid,
          collection: collection,
          id: id,
          data: _encode(remoteSource, localItem),
          parentCollection: parentCollection,
          parentId: parentId,
        );
      } else if (localItem != null && remoteItem != null) {
        final localDate = modifiedAt(localItem);
        final remoteDate = modifiedAt(remoteItem);
        if (localDate.isAfter(remoteDate)) {
          await syncQueue.upsert(
            uid: uid,
            collection: collection,
            id: id,
            data: _encode(remoteSource, localItem),
            parentCollection: parentCollection,
            parentId: parentId,
          );
        } else if (remoteDate.isAfter(localDate)) {
          await saveLocal(remoteItem);
        }
      }
    }
  }

  Map<String, dynamic> _encode<T>(
    FirestoreCollectionDataSource<T> source,
    T value,
  ) =>
      source.encode(value);

  Future<void> _saveListRecord<T>(
    Box<List<dynamic>> box,
    String key,
    T value,
    String Function(T) idOf,
  ) async {
    final entries = box.get(key)?.whereType<T>().toList() ?? <T>[];
    final index = entries.indexWhere((entry) => idOf(entry) == idOf(value));
    if (index < 0) {
      entries.add(value);
    } else {
      entries[index] = value;
    }
    await box.put(key, entries);
  }

  Future<void> _deleteListRecord<T>(
    Box<List<dynamic>> box,
    String id,
    String Function(T) idOf,
  ) async {
    for (final key in box.keys.toList()) {
      final entries = box.get(key);
      if (entries == null) continue;
      final remaining =
          entries.whereType<T>().where((entry) => idOf(entry) != id).toList();
      if (remaining.isEmpty) {
        await box.delete(key);
      } else if (remaining.length != entries.length) {
        await box.put(key, remaining);
      }
    }
  }
}
