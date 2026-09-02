import 'package:leakuku/data/datasources/financial_transaction_local_data_source.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';

abstract class FinancialTransactionRepository {
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

class FinancialTransactionRepositoryImpl
    implements FinancialTransactionRepository {
  final FinancialTransactionLocalDataSource localDataSource;

  FinancialTransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FinancialTransactionModel>> getAllTransactions(String userId) {
    return localDataSource.getAllTransactions(userId);
  }

  @override
  Future<List<FinancialTransactionModel>> getTransactionsByType(
    String userId,
    String transactionType,
  ) {
    return localDataSource.getTransactionsByType(userId, transactionType);
  }

  @override
  Future<FinancialTransactionModel?> getTransactionById(String id) {
    return localDataSource.getTransactionById(id);
  }

  @override
  Future<void> addTransaction(FinancialTransactionModel transaction) {
    return localDataSource.addTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(FinancialTransactionModel transaction) {
    return localDataSource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return localDataSource.deleteTransaction(id);
  }
}
