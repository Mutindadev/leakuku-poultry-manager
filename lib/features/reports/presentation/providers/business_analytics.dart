import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/flock_financial_summary.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/presentation/providers/farm_finance_provider.dart';

class BusinessAnalyticsState {
  final BusinessAnalyticsData? data;
  final bool isLoading;
  final String? error;

  const BusinessAnalyticsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  BusinessAnalyticsState copyWith({
    BusinessAnalyticsData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BusinessAnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class BusinessAnalyticsNotifier extends StateNotifier<BusinessAnalyticsState> {
  final Ref ref;
  final ReportFilter filter;

  BusinessAnalyticsNotifier(this.ref, this.filter)
      : super(const BusinessAnalyticsState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final data = await _loadBusinessAnalytics();

      state = BusinessAnalyticsState(
        data: data,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> refresh() => load();

  Future<BusinessAnalyticsData> _loadBusinessAnalytics() async {
    const reportService = ReportService();

    final userId = ref.read(authProvider).user?.id;

    if (userId == null || userId.isEmpty) {
      return const BusinessAnalyticsData(
        transactions: <FinancialTransactionModel>[],
        totalRevenue: 0,
        totalExpenses: 0,
        estimatedProfit: 0,
        profitMargin: null,
        revenueByCategory: <String, double>{},
        expenseByCategory: <String, double>{},
        rankedExpenseCategories: <MapEntry<String, double>>[],
        flockSummaries: <String, FlockFinancialSummary>{},
        insights: <String>[],
      );
    }

    final repository = ref.read(financialTransactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions(userId);

    final boundary = reportService.getBoundary(filter);
    final previousBoundary = reportService.getPreviousBoundary(filter);

    final transactions = allTransactions
        .where((item) => reportService.isWithin(item.date, boundary))
        .toList();

    final revenueByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};
    final flockRevenue = <String, double>{};
    final flockExpenses = <String, double>{};

    var totalRevenue = 0.0;
    var totalExpenses = 0.0;

    for (final item in transactions) {
      if (item.transactionType == 'income') {
        totalRevenue += item.amount;
        revenueByCategory[item.category] =
            (revenueByCategory[item.category] ?? 0) + item.amount;
      } else if (item.transactionType == 'expense') {
        totalExpenses += item.amount;
        expenseByCategory[item.category] =
            (expenseByCategory[item.category] ?? 0) + item.amount;
      } else {
        continue;
      }

      final flockKey = item.relatedFlock?.trim();

      if (flockKey == null || flockKey.isEmpty) {
        continue;
      }

      if (item.transactionType == 'income') {
        flockRevenue[flockKey] = (flockRevenue[flockKey] ?? 0) + item.amount;
      } else {
        flockExpenses[flockKey] = (flockExpenses[flockKey] ?? 0) + item.amount;
      }
    }

    final estimatedProfit = totalRevenue - totalExpenses;
    final profitMargin =
        totalRevenue > 0 ? (estimatedProfit / totalRevenue) * 100 : null;

    final rankedExpenseCategories =
        reportService.sortedEntries(expenseByCategory);

    final flockSummaries = <String, FlockFinancialSummary>{};
    final flockKeys = {
      ...flockRevenue.keys,
      ...flockExpenses.keys,
    }.toList()
      ..sort();

    for (final key in flockKeys) {
      flockSummaries[key] = FlockFinancialSummary(
        flockLabel: key,
        revenue: flockRevenue[key] ?? 0,
        expenses: flockExpenses[key] ?? 0,
      );
    }

    final previousTransactions = allTransactions
        .where(
          (item) => reportService.isWithin(
            item.date,
            previousBoundary,
          ),
        )
        .toList();

    final previousRevenue = previousTransactions
        .where((item) => item.transactionType == 'income')
        .fold<double>(0, (sum, item) => sum + item.amount);

    final previousExpenses = previousTransactions
        .where((item) => item.transactionType == 'expense')
        .fold<double>(0, (sum, item) => sum + item.amount);

    final previousProfit = previousRevenue - previousExpenses;

    final insights = _buildBusinessInsights(
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      currentProfit: estimatedProfit,
      previousProfit: previousTransactions.isEmpty ? null : previousProfit,
      previousLabel: _previousLabelForFilter(filter),
    );

    return BusinessAnalyticsData(
      transactions: transactions,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      estimatedProfit: estimatedProfit,
      profitMargin: profitMargin,
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      rankedExpenseCategories: rankedExpenseCategories,
      flockSummaries: flockSummaries,
      insights: insights,
    );
  }

  List<String> _buildBusinessInsights({
    required Map<String, double> revenueByCategory,
    required Map<String, double> expenseByCategory,
    required double currentProfit,
    required double? previousProfit,
    required String previousLabel,
  }) {
    final insights = <String>[];

    final rankedRevenue =
        const ReportService().sortedEntries(revenueByCategory);

    if (rankedRevenue.isNotEmpty) {
      insights.add(
        '${rankedRevenue.first.key} generated most of your income.',
      );
    }

    final rankedExpenses =
        const ReportService().sortedEntries(expenseByCategory);

    if (rankedExpenses.isNotEmpty) {
      insights.add(
        '${rankedExpenses.first.key} is your largest expense.',
      );
    }

    final labourCurrent = expenseByCategory['Labour'];

    if (labourCurrent != null && labourCurrent > 0) {
      final totalExpense =
          expenseByCategory.values.fold<double>(0, (s, v) => s + v);

      if (totalExpense > 0 && (labourCurrent / totalExpense) * 100 <= 20) {
        insights.add('Labour costs stayed moderate in this period.');
      }
    }

    if (previousProfit != null) {
      if (currentProfit > previousProfit) {
        insights.add(
          'Profit increased compared to last $previousLabel.',
        );
      } else if (currentProfit < previousProfit) {
        insights.add(
          'Profit decreased compared to last $previousLabel.',
        );
      }
    }

    return insights;
  }

  // Add future business report CRUD methods here.
}

final businessAnalyticsProvider = StateNotifierProvider.family<
    BusinessAnalyticsNotifier, BusinessAnalyticsState, ReportFilter>(
  (ref, filter) => BusinessAnalyticsNotifier(ref, filter),
);

String _previousLabelForFilter(ReportFilter filter) {
  switch (filter) {
    case ReportFilter.today:
      return 'day';
    case ReportFilter.thisWeek:
      return 'week';
    case ReportFilter.thisMonth:
      return 'month';
    case ReportFilter.thisYear:
      return 'year';
    case ReportFilter.custom:
      return 'period';
  }
}
