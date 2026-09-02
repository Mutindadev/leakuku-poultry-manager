import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/datasources/financial_transaction_local_data_source.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/finances/data/financial_transaction_repository.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';

const List<String> incomeCategories = [
  'Bird Sales',
  'Egg Sales',
  'Manure Sales',
  'Other Income',
];

const List<String> expenseCategories = [
  'Chick Purchases',
  'Feed',
  'Vaccines',
  'Medicines',
  'Water',
  'Electricity',
  'Labour',
  'Transport',
  'Equipment',
  'Repairs',
  'Other Expenses',
];

final financialTransactionLocalDataSourceProvider =
    Provider<FinancialTransactionLocalDataSource>((ref) {
  final box = Hive.box<FinancialTransactionModel>('farmFinanceTransactionBox');
  return FinancialTransactionLocalDataSourceImpl(transactionBox: box);
});

final financialTransactionRepositoryProvider =
    Provider<FinancialTransactionRepository>((ref) {
  final localDataSource = ref.watch(financialTransactionLocalDataSourceProvider);
  return FinancialTransactionRepositoryImpl(localDataSource: localDataSource);
});

class FarmFinanceState {
  final List<FinancialTransactionModel> transactions;
  final bool isLoading;
  final String? error;

  const FarmFinanceState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  List<FinancialTransactionModel> get incomeTransactions =>
      transactions.where((item) => item.isIncome).toList();

  List<FinancialTransactionModel> get expenseTransactions =>
      transactions.where((item) => item.isExpense).toList();

  FarmFinanceState copyWith({
    List<FinancialTransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return FarmFinanceState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FarmFinanceNotifier extends StateNotifier<FarmFinanceState> {
  final Ref ref;

  FarmFinanceNotifier(this.ref) : super(const FarmFinanceState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null || userId.isEmpty) {
        state = state.copyWith(transactions: const [], isLoading: false);
        return;
      }

      final repository = ref.read(financialTransactionRepositoryProvider);
      final transactions = await repository.getAllTransactions(userId);
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTransaction({
    required String transactionType,
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
    String? relatedFlock,
    String? paymentMethod,
  }) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(error: 'User not found. Please log in again.');
      return;
    }

    final now = DateTime.now();
    final model = FinancialTransactionModel(
      id: 'txn_${now.microsecondsSinceEpoch}',
      userId: userId,
      transactionType: transactionType,
      category: category,
      amount: amount,
      date: date,
      notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      lastUpdated: now,
      relatedFlock: (relatedFlock == null || relatedFlock.trim().isEmpty)
          ? null
          : relatedFlock.trim(),
      paymentMethod: (paymentMethod == null || paymentMethod.trim().isEmpty)
          ? null
          : paymentMethod.trim(),
    );

    try {
      await ref.read(financialTransactionRepositoryProvider).addTransaction(model);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTransaction(FinancialTransactionModel updated) async {
    try {
      await ref
          .read(financialTransactionRepositoryProvider)
          .updateTransaction(updated.copyWith(lastUpdated: DateTime.now()));
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await ref.read(financialTransactionRepositoryProvider).deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final farmFinanceProvider =
    StateNotifierProvider<FarmFinanceNotifier, FarmFinanceState>((ref) {
  return FarmFinanceNotifier(ref);
});
