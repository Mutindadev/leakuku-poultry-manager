import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';

abstract class FinancialTransactionLocalDataSource {
  Future<List<FinancialTransactionModel>> getAllTransactions(String userId);
  Future<List<FinancialTransactionModel>> getTransactionsByType(
    String userId,
    String transactionType,
  );
  Future<FinancialTransactionModel?> getTransactionById(String id);
  Future<void> addTransaction(FinancialTransactionModel transaction);
  Future<void> updateTransaction(FinancialTransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class FinancialTransactionLocalDataSourceImpl
    implements FinancialTransactionLocalDataSource {
  final Box<FinancialTransactionModel> _transactionBox;
  final FirestoreSyncQueue? syncQueue;

  FinancialTransactionLocalDataSourceImpl({
    required Box<FinancialTransactionModel> transactionBox,
    this.syncQueue,
  }) : _transactionBox = transactionBox;

  @override
  Future<List<FinancialTransactionModel>> getAllTransactions(
    String userId,
  ) async {
    final transactions =
        _transactionBox.values.where((item) => item.userId == userId).toList()
          ..sort((a, b) {
            final dateCompare = b.date.compareTo(a.date);
            if (dateCompare != 0) {
              return dateCompare;
            }
            return b.lastUpdated.compareTo(a.lastUpdated);
          });

    return transactions;
  }

  @override
  Future<List<FinancialTransactionModel>> getTransactionsByType(
    String userId,
    String transactionType,
  ) async {
    final transactions = await getAllTransactions(userId);
    return transactions
        .where((item) => item.transactionType == transactionType)
        .toList();
  }

  @override
  Future<FinancialTransactionModel?> getTransactionById(String id) async {
    return _transactionBox.get(id);
  }

  @override
  Future<void> addTransaction(FinancialTransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    await syncQueue?.upsert(
      uid: transaction.userId,
      collection: FirestoreCollections.financialTransactions,
      id: transaction.id,
      data: transaction.toMap(),
    );
  }

  @override
  Future<void> updateTransaction(FinancialTransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    await syncQueue?.upsert(
      uid: transaction.userId,
      collection: FirestoreCollections.financialTransactions,
      id: transaction.id,
      data: transaction.toMap(),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final transaction = _transactionBox.get(id);
    await _transactionBox.delete(id);
    if (transaction != null) {
      await syncQueue?.delete(
        uid: transaction.userId,
        collection: FirestoreCollections.financialTransactions,
        id: id,
      );
    }
  }
}
