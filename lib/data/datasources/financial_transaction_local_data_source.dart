import 'package:hive/hive.dart';
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

  FinancialTransactionLocalDataSourceImpl({
    required Box<FinancialTransactionModel> transactionBox,
  }) : _transactionBox = transactionBox;

  @override
  Future<List<FinancialTransactionModel>> getAllTransactions(
    String userId,
  ) async {
    final transactions = _transactionBox.values
        .where((item) => item.userId == userId)
        .toList()
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
  }

  @override
  Future<void> updateTransaction(FinancialTransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }
}
