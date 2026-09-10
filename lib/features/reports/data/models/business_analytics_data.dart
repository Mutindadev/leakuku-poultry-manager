import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/reports/data/models/flock_financial_summary.dart';

class BusinessAnalyticsData {
  final List<FinancialTransactionModel> transactions;
  final double totalRevenue;
  final double totalExpenses;
  final double estimatedProfit;
  final double? profitMargin;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expenseByCategory;
  final List<MapEntry<String, double>> rankedExpenseCategories;
  final Map<String, FlockFinancialSummary> flockSummaries;
  final List<String> insights;

  const BusinessAnalyticsData({
    required this.transactions,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.estimatedProfit,
    required this.profitMargin,
    required this.revenueByCategory,
    required this.expenseByCategory,
    required this.rankedExpenseCategories,
    required this.flockSummaries,
    required this.insights,
  });

  bool get hasRecords => transactions.isNotEmpty;
}
