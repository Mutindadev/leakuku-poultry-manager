import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/presentation/providers/farm_finance_provider.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final _ReportFilter _selectedFilter = _ReportFilter.thisMonth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportNavigationCard(
            title: 'Farm Summary',
            description:
                'Quick financial and production snapshot for your selected period.',
            icon: FontAwesomeIcons.seedling,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _FarmSummaryDetailPage(filter: _selectedFilter),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ReportNavigationCard(
            title: 'Flock Performance',
            description:
                'Growth trends, production quality, and performance comparisons.',
            icon: FontAwesomeIcons.chartLine,
            onTap: () => _openReportPage(
              context,
              title: 'Flock Performance',
            ),
          ),
          const SizedBox(height: 10),
          _ReportNavigationCard(
            title: 'Feed Analytics',
            description:
                'Feed consumption efficiency and stock movement insights.',
            icon: FontAwesomeIcons.bowlFood,
            onTap: () => _openReportPage(
              context,
              title: 'Feed Analytics',
            ),
          ),
          const SizedBox(height: 10),
          _ReportNavigationCard(
            title: 'Health Analytics',
            description:
                'Mortality, vaccination, and flock health outcome patterns.',
            icon: FontAwesomeIcons.heartPulse,
            onTap: () => _openReportPage(
              context,
              title: 'Health Analytics',
            ),
          ),
          const SizedBox(height: 10),
          _ReportNavigationCard(
            title: 'Business Analytics',
            description:
                'Operational performance and profitability reporting tools.',
            icon: FontAwesomeIcons.sackDollar,
            onTap: () => _openReportPage(
              context,
              title: 'Business Analytics',
            ),
          ),
        ],
      ),
    );
  }

  void _openReportPage(BuildContext context, {required String title}) {
    if (title == 'Flock Performance') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _FlockPerformancePage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Feed Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _FeedAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Health Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _HealthAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Business Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _BusinessAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReadOnlyReportPage(title: title),
      ),
    );
  }
}

enum _ReportFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension _ReportFilterX on _ReportFilter {
  String get label {
    switch (this) {
      case _ReportFilter.today:
        return 'Today';
      case _ReportFilter.thisWeek:
        return 'This Week';
      case _ReportFilter.thisMonth:
        return 'This Month';
      case _ReportFilter.thisYear:
        return 'This Year';
      case _ReportFilter.custom:
        return 'Custom';
    }
  }

}

const List<_ReportFilter> _visibleReportFilters = <_ReportFilter>[
  _ReportFilter.today,
  _ReportFilter.thisWeek,
  _ReportFilter.thisMonth,
  _ReportFilter.thisYear,
];

class FarmSummaryData {
  final int activeFlocks;
  final int totalBirdsAlive;
  final Map<String, double> feedStockByUnit;
  final Map<String, double> feedUsedByUnit;
  final double? averageMortalityPercent;

  const FarmSummaryData({
    required this.activeFlocks,
    required this.totalBirdsAlive,
    required this.feedStockByUnit,
    required this.feedUsedByUnit,
    required this.averageMortalityPercent,
  });
}

final _farmSummaryProvider =
    FutureProvider.family<FarmSummaryData, _ReportFilter>(
  (ref, filter) async {
    final flockState = ref.watch(flockProvider);
    final flockStats = ref.watch(flockStatsProvider);
    final stockItems = await ref.watch(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final boundary = _getBoundary(filter);

    final feedItems = stockItems
        .where((item) => item.category.toLowerCase() == 'feed')
        .toList();

    final feedStockByUnit = <String, double>{};
    for (final item in feedItems) {
      if (item.quantity <= 0) {
        continue;
      }
      _mergeQuantity(feedStockByUnit, item.unit, item.quantity);
    }

    final feedHistoryLists = await Future.wait(
      feedItems.map((item) => stockDataSource.getItemHistory(item.id)),
    );
    final feedUsedByUnit = <String, double>{};
    for (final histories in feedHistoryLists) {
      for (final entry in histories) {
        if (entry.action.toLowerCase() != 'used') {
          continue;
        }
        if (!_isWithin(entry.date, boundary)) {
          continue;
        }
        _mergeQuantity(feedUsedByUnit, entry.unit, entry.quantity);
      }
    }

    final mortalityValues = <double>[];
    final flockPlans = await Future.wait(
      flockState.flocks
          .map((flock) => weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id)),
    );
    for (final plans in flockPlans) {
      for (final plan in plans) {
        final mortality = plan.actualMortalityPercent;
        if (mortality == null) {
          continue;
        }
        if (!_weekOverlapsBoundary(plan.weekStartDate, boundary)) {
          continue;
        }
        mortalityValues.add(mortality);
      }
    }

    final averageMortalityPercent = mortalityValues.isEmpty
        ? null
        : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;

    return FarmSummaryData(
      activeFlocks: flockStats.totalFlocks,
      totalBirdsAlive: flockStats.totalChickens,
      feedStockByUnit: feedStockByUnit,
      feedUsedByUnit: feedUsedByUnit,
      averageMortalityPercent: averageMortalityPercent,
    );
  },
);

class _SummaryMetricRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  const _SummaryMetricRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.leakukuGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 12,
              color: AppColors.leakukuGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportNavigationCard extends StatelessWidget {
  final String title;
  final String description;
  final FaIconData icon;
  final VoidCallback onTap;

  const _ReportNavigationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.leakukuGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 16,
                      color: AppColors.leakukuGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmSummaryDetailPage extends ConsumerWidget {
  final _ReportFilter filter;

  const _FarmSummaryDetailPage({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(_farmSummaryProvider(filter));
    final summaryData = summaryAsync.asData?.value;
    final canExport = summaryData != null && _farmSummaryHasData(summaryData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Summary'),
        actions: [
          _buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (summaryData == null) {
                return;
              }
              final payload = _buildFarmSummaryExportPayload(summaryData, filter);
              await _handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Period: ${filter.label}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: summaryAsync.when(
                data: (summary) => Column(
                  children: [
                    _SummaryMetricRow(
                      icon: FontAwesomeIcons.kiwiBird,
                      label: 'Active flocks',
                      value: '${summary.activeFlocks}',
                    ),
                    const SizedBox(height: 10),
                    _SummaryMetricRow(
                      icon: FontAwesomeIcons.drumstickBite,
                      label: 'Total birds alive',
                      value: '${summary.totalBirdsAlive}',
                    ),
                    const SizedBox(height: 10),
                    _SummaryMetricRow(
                      icon: FontAwesomeIcons.boxesStacked,
                      label: 'Feed stock available',
                      value: summary.feedStockByUnit.isEmpty
                          ? 'No feed stock recorded yet.'
                          : _formatQuantities(summary.feedStockByUnit),
                      isEmpty: summary.feedStockByUnit.isEmpty,
                    ),
                    const SizedBox(height: 10),
                    _SummaryMetricRow(
                      icon: FontAwesomeIcons.percent,
                      label: 'Mortality percentage',
                      value: summary.averageMortalityPercent == null
                          ? 'No mortality records for this period.'
                          : '${summary.averageMortalityPercent!.toStringAsFixed(1)}%',
                      isEmpty: summary.averageMortalityPercent == null,
                    ),
                    const SizedBox(height: 10),
                    _SummaryMetricRow(
                      icon: FontAwesomeIcons.wheatAwn,
                      label: filter == _ReportFilter.today
                          ? 'Feed used today'
                          : 'Feed used in period',
                      value: summary.feedUsedByUnit.isEmpty
                          ? 'No feed usage recorded for this period.'
                          : _formatQuantities(summary.feedUsedByUnit),
                      isEmpty: summary.feedUsedByUnit.isEmpty,
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.leakukuGreen,
                  ),
                ),
                error: (error, _) => Text(
                  'Could not load farm summary right now.\n$error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.errorRed,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyReportPage extends StatelessWidget {
  final String title;

  const _ReadOnlyReportPage({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.chartSimple,
                size: 40,
                color: AppColors.softGray,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Not recorded yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessAnalyticsData {
  final List<FinancialTransactionModel> transactions;
  final double totalRevenue;
  final double totalExpenses;
  final double estimatedProfit;
  final double? profitMargin;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expenseByCategory;
  final List<MapEntry<String, double>> rankedExpenseCategories;
  final Map<String, _FlockFinancialSummary> flockSummaries;
  final List<String> insights;

  const _BusinessAnalyticsData({
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

class _FlockFinancialSummary {
  final String flockLabel;
  final double revenue;
  final double expenses;

  const _FlockFinancialSummary({
    required this.flockLabel,
    required this.revenue,
    required this.expenses,
  });

  double get estimatedProfit => revenue - expenses;
}

final _businessAnalyticsProvider =
    FutureProvider.family<_BusinessAnalyticsData, _ReportFilter>(
  (ref, filter) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) {
      return const _BusinessAnalyticsData(
        transactions: <FinancialTransactionModel>[],
        totalRevenue: 0,
        totalExpenses: 0,
        estimatedProfit: 0,
        profitMargin: null,
        revenueByCategory: <String, double>{},
        expenseByCategory: <String, double>{},
        rankedExpenseCategories: <MapEntry<String, double>>[],
        flockSummaries: <String, _FlockFinancialSummary>{},
        insights: <String>[],
      );
    }

    final repository = ref.read(financialTransactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions(userId);
    final boundary = _getBoundary(filter);
    final previousBoundary = _getPreviousBoundary(filter);

    final transactions = allTransactions
        .where((item) => _isWithin(item.date, boundary))
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
      if (flockKey != null && flockKey.isNotEmpty) {
        if (item.transactionType == 'income') {
          flockRevenue[flockKey] = (flockRevenue[flockKey] ?? 0) + item.amount;
        } else if (item.transactionType == 'expense') {
          flockExpenses[flockKey] = (flockExpenses[flockKey] ?? 0) + item.amount;
        }
      }
    }

    final estimatedProfit = totalRevenue - totalExpenses;
    final profitMargin = totalRevenue > 0
        ? ((estimatedProfit / totalRevenue) * 100)
        : null;

    final rankedExpenseCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final flockSummaries = <String, _FlockFinancialSummary>{};
    final flockKeys = {...flockRevenue.keys, ...flockExpenses.keys}.toList()
      ..sort((a, b) => a.compareTo(b));
    for (final key in flockKeys) {
      flockSummaries[key] = _FlockFinancialSummary(
        flockLabel: key,
        revenue: flockRevenue[key] ?? 0,
        expenses: flockExpenses[key] ?? 0,
      );
    }

    final previousTransactions = allTransactions
        .where((item) => _isWithin(item.date, previousBoundary))
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

    return _BusinessAnalyticsData(
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
  },
);

class _BusinessAnalyticsPage extends ConsumerStatefulWidget {
  final _ReportFilter initialFilter;

  const _BusinessAnalyticsPage({required this.initialFilter});

  @override
  ConsumerState<_BusinessAnalyticsPage> createState() =>
      _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends ConsumerState<_BusinessAnalyticsPage> {
  late _ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(_businessAnalyticsProvider(_selectedFilter));
    final analyticsData = analyticsAsync.asData?.value;
    final canExport = analyticsData != null && analyticsData.hasRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics'),
        actions: [
          _buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (analyticsData == null || !analyticsData.hasRecords) {
                return;
              }
              final payload =
                  _buildBusinessAnalyticsExportPayload(analyticsData, _selectedFilter);
              await _handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodFilter(
            context,
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          analyticsAsync.when(
            data: (analytics) {
              if (!analytics.hasRecords) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No financial records available yet.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Record income and expenses in Farm Finances to view Business Analytics.',
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBusinessSummaryCard(context, analytics),
                  const SizedBox(height: 12),
                  _buildBreakdownCard(
                    context,
                    title: 'Revenue Breakdown',
                    icon: FontAwesomeIcons.arrowTrendUp,
                    color: AppColors.successGreen,
                    values: analytics.revenueByCategory,
                  ),
                  const SizedBox(height: 12),
                  _buildBreakdownCard(
                    context,
                    title: 'Expense Breakdown',
                    icon: FontAwesomeIcons.arrowTrendDown,
                    color: AppColors.errorRed,
                    values: analytics.expenseByCategory,
                  ),
                  const SizedBox(height: 12),
                  _buildCostDistributionCard(context, analytics),
                  const SizedBox(height: 12),
                  _buildProfitabilityCard(context, analytics),
                  const SizedBox(height: 12),
                  _buildFlockProfitabilityCard(context, analytics),
                  const SizedBox(height: 12),
                  _buildBusinessInsightsCard(context, analytics),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            ),
            error: (error, _) => _buildEmptyState(
              context,
              'Could not load Business Analytics.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBusinessSummaryCard(
  BuildContext context,
  _BusinessAnalyticsData analytics,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.coins,
                color: AppColors.leakukuGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricText('Total Revenue', _formatMoney(analytics.totalRevenue)),
          const SizedBox(height: 6),
          _metricText('Total Expenses', _formatMoney(analytics.totalExpenses)),
          const SizedBox(height: 6),
          _metricText('Estimated Profit', _formatMoney(analytics.estimatedProfit)),
          const SizedBox(height: 6),
          _metricText('Profit Margin (%)', _formatPercent(analytics.profitMargin)),
        ],
      ),
    ),
  );
}

Widget _buildBreakdownCard(
  BuildContext context, {
  required String title,
  required FaIconData icon,
  required Color color,
  required Map<String, double> values,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (values.isEmpty)
            Text(
              'No records for this period.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            ..._sortedEntries(values).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      _formatMoney(entry.value),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildCostDistributionCard(
  BuildContext context,
  _BusinessAnalyticsData analytics,
) {
  final ranked = analytics.rankedExpenseCategories;
  final maxValue = ranked.isEmpty ? 0.0 : ranked.first.value;

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (ranked.isEmpty)
            Text(
              'No expense records for this period.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            ...ranked.take(5).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _formatMoney(entry.value),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: maxValue <= 0 ? 0 : entry.value / maxValue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.warningAmber,
                      backgroundColor: Colors.grey.withValues(alpha: 0.20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildProfitabilityCard(
  BuildContext context,
  _BusinessAnalyticsData analytics,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profitability',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _metricText('Revenue', _formatMoney(analytics.totalRevenue)),
          const SizedBox(height: 6),
          _metricText('Expenses', _formatMoney(analytics.totalExpenses)),
          const SizedBox(height: 6),
          _metricText('Net Profit', _formatMoney(analytics.estimatedProfit)),
          const SizedBox(height: 6),
          _metricText('Profit Margin', _formatPercent(analytics.profitMargin)),
        ],
      ),
    ),
  );
}

Widget _buildFlockProfitabilityCard(
  BuildContext context,
  _BusinessAnalyticsData analytics,
) {
  final entries = analytics.flockSummaries.values.toList()
    ..sort((a, b) => b.estimatedProfit.compareTo(a.estimatedProfit));

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flock Profitability',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(
              'No flock-linked financial records yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            ...entries.map(
              (summary) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.flockLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      _metricText('Revenue', _formatMoney(summary.revenue)),
                      const SizedBox(height: 4),
                      _metricText('Expenses', _formatMoney(summary.expenses)),
                      const SizedBox(height: 4),
                      _metricText(
                        'Estimated Profit',
                        _formatMoney(summary.estimatedProfit),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildBusinessInsightsCard(
  BuildContext context,
  _BusinessAnalyticsData analytics,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (analytics.insights.isEmpty)
            Text(
              'Not enough financial records to generate insights for this period.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            ...analytics.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: FaIcon(
                        FontAwesomeIcons.lightbulb,
                        size: 12,
                        color: AppColors.leakukuGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _FlockPerformanceData {
  final String flockId;
  final String flockName;
  final int birdCount;
  final int ageDays;
  final double? averageWeightKg;
  final double? mortalityPercent;
  final double? survivalRate;
  final String performanceStatus;

  const _FlockPerformanceData({
    required this.flockId,
    required this.flockName,
    required this.birdCount,
    required this.ageDays,
    required this.averageWeightKg,
    required this.mortalityPercent,
    required this.survivalRate,
    required this.performanceStatus,
  });
}

class _FeedUsageByFlock {
  final String flockId;
  final String flockName;
  final double? usedKg;

  const _FeedUsageByFlock({
    required this.flockId,
    required this.flockName,
    required this.usedKg,
  });
}

class _FeedTrendPoint {
  final DateTime date;
  final Map<String, double> usageByUnit;

  const _FeedTrendPoint({
    required this.date,
    required this.usageByUnit,
  });
}

class _FeedAnalyticsData {
  final Map<String, double> feedUsedInSelectedPeriodByUnit;
  final Map<String, double> remainingFeedStockByUnit;
  final List<_FeedUsageByFlock> feedUsageByFlock;
  final List<_FeedTrendPoint> feedUsageTrend;

  const _FeedAnalyticsData({
    required this.feedUsedInSelectedPeriodByUnit,
    required this.remainingFeedStockByUnit,
    required this.feedUsageByFlock,
    required this.feedUsageTrend,
  });
}

class _WeeklyMortalityRecord {
  final String flockId;
  final DateTime weekStartDate;
  final int losses;
  final double mortalityPercent;

  const _WeeklyMortalityRecord({
    required this.flockId,
    required this.weekStartDate,
    required this.losses,
    required this.mortalityPercent,
  });
}

class _MortalityTrendPoint {
  final DateTime periodStart;
  final int losses;

  const _MortalityTrendPoint({
    required this.periodStart,
    required this.losses,
  });
}

class _UpcomingVaccination {
  final String flockName;
  final String vaccineName;
  final DateTime dueDate;

  const _UpcomingVaccination({
    required this.flockName,
    required this.vaccineName,
    required this.dueDate,
  });
}

class _FlockHealthSnapshot {
  final String flockName;
  final int birdCount;
  final int recordedLosses;
  final double? mortalityPercent;
  final String status;

  const _FlockHealthSnapshot({
    required this.flockName,
    required this.birdCount,
    required this.recordedLosses,
    required this.mortalityPercent,
    required this.status,
  });
}

class _MedicineUsageSummary {
  final String itemName;
  final String quantityLabel;

  const _MedicineUsageSummary({
    required this.itemName,
    required this.quantityLabel,
  });
}

class _HealthAnalyticsData {
  final String overallStatus;
  final double? mortalityPercent;
  final int? totalBirdLosses;
  final int? mortalityInSelectedPeriod;
  final int vaccinationsCompleted;
  final int vaccinationsDue;
  final int vaccinationsUpcoming;
  final List<_UpcomingVaccination> upcomingVaccinations;
  final int treatmentsRecorded;
  final int treatmentsInSelectedPeriod;
  final String? mostRecentTreatmentInSelectedPeriod;
  final List<_MedicineUsageSummary> medicineUsageInSelectedPeriod;
  final List<_MortalityTrendPoint> mortalityTrend;
  final List<_FlockHealthSnapshot> flockHealth;
  final List<String> insights;
  final bool hasVaccinationRecords;
  final bool hasMortalityRecords;

  const _HealthAnalyticsData({
    required this.overallStatus,
    required this.mortalityPercent,
    required this.totalBirdLosses,
    required this.mortalityInSelectedPeriod,
    required this.vaccinationsCompleted,
    required this.vaccinationsDue,
    required this.vaccinationsUpcoming,
    required this.upcomingVaccinations,
    required this.treatmentsRecorded,
    required this.treatmentsInSelectedPeriod,
    required this.mostRecentTreatmentInSelectedPeriod,
    required this.medicineUsageInSelectedPeriod,
    required this.mortalityTrend,
    required this.flockHealth,
    required this.insights,
    required this.hasVaccinationRecords,
    required this.hasMortalityRecords,
  });
}

final _flockPerformanceProvider =
  FutureProvider.family<List<_FlockPerformanceData>, _ReportFilter>(
  (ref, filter) async {
    final flocks = ref.watch(flockProvider).flocks;
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final boundary = _getBoundary(filter);
    final items = <_FlockPerformanceData>[];

    for (final flock in flocks) {
      final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);

      final weightValues = plans
          .where((plan) =>
              plan.actualBodyWeightKg != null &&
              _weekOverlapsBoundary(plan.weekStartDate, boundary))
          .map((plan) => plan.actualBodyWeightKg!)
          .toList();

      final mortalityValues = plans
          .where((plan) =>
              plan.actualMortalityPercent != null &&
              _weekOverlapsBoundary(plan.weekStartDate, boundary))
          .map((plan) => plan.actualMortalityPercent!)
          .toList();

      final averageWeight = weightValues.isEmpty
          ? null
          : weightValues.reduce((a, b) => a + b) / weightValues.length;
      final mortalityPercent = mortalityValues.isEmpty
          ? null
          : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;
      final survivalRate = mortalityPercent == null
          ? null
          : (100 - mortalityPercent).clamp(0, 100).toDouble();

      items.add(
        _FlockPerformanceData(
          flockId: flock.id,
          flockName: flock.name,
          birdCount: flock.quantity,
          ageDays: DateTime.now().difference(flock.purchaseDate).inDays,
          averageWeightKg: averageWeight,
          mortalityPercent: mortalityPercent,
          survivalRate: survivalRate,
          performanceStatus: _performanceStatus(
            mortalityPercent: mortalityPercent,
            averageWeightKg: averageWeight,
          ),
        ),
      );
    }

    items.sort((a, b) => a.flockName.compareTo(b.flockName));
    return items;
  },
);

final _feedAnalyticsProvider =
  FutureProvider.family<_FeedAnalyticsData, _ReportFilter>(
  (ref, filter) async {
    final flocks = ref.watch(flockProvider).flocks;
    final stockItems = await ref.watch(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final periodBoundary = _getBoundary(filter);

    final feedItems = stockItems
        .where((item) => item.category.toLowerCase() == 'feed')
        .toList();

    final remainingFeedStockByUnit = <String, double>{};
    for (final item in feedItems) {
      if (item.quantity <= 0) {
        continue;
      }
      _mergeQuantity(remainingFeedStockByUnit, item.unit, item.quantity);
    }

    final feedHistoryLists = await Future.wait(
      feedItems.map((item) => stockDataSource.getItemHistory(item.id)),
    );

    final feedUsedInSelectedPeriodByUnit = <String, double>{};
    final trendByDate = <DateTime, Map<String, double>>{};

    for (final histories in feedHistoryLists) {
      for (final entry in histories) {
        if (entry.action.toLowerCase() != 'used') {
          continue;
        }

        if (_isWithin(entry.date, periodBoundary)) {
          _mergeQuantity(
            feedUsedInSelectedPeriodByUnit,
            entry.unit,
            entry.quantity,
          );
          final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
          final dayMap = trendByDate.putIfAbsent(day, () => <String, double>{});
          _mergeQuantity(dayMap, entry.unit, entry.quantity);
        }
      }
    }

    final usageByFlock = <_FeedUsageByFlock>[];
    for (final flock in flocks) {
      final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);
      final usedKg = plans
          .where((plan) =>
              plan.actualTotalFeedKg != null &&
              _weekOverlapsBoundary(plan.weekStartDate, periodBoundary))
          .map((plan) => plan.actualTotalFeedKg!)
          .fold<double>(0, (sum, value) => sum + value);

      usageByFlock.add(
        _FeedUsageByFlock(
          flockId: flock.id,
          flockName: flock.name,
          usedKg: usedKg > 0 ? usedKg : null,
        ),
      );
    }
    usageByFlock.sort((a, b) => a.flockName.compareTo(b.flockName));

    final trendDates = trendByDate.keys.toList()..sort();
    final feedUsageTrend = trendDates
        .map(
          (date) => _FeedTrendPoint(
            date: date,
            usageByUnit: trendByDate[date]!,
          ),
        )
        .toList();

    return _FeedAnalyticsData(
      feedUsedInSelectedPeriodByUnit: feedUsedInSelectedPeriodByUnit,
      remainingFeedStockByUnit: remainingFeedStockByUnit,
      feedUsageByFlock: usageByFlock,
      feedUsageTrend: feedUsageTrend,
    );
  },
);

final _healthAnalyticsProvider =
    FutureProvider.family<_HealthAnalyticsData, _ReportFilter>(
  (ref, filter) async {
    final flockState = ref.watch(flockProvider);
    final flocks = flockState.flocks;
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final vaccineDataSource = ref.read(vaccineDataSourceProvider);
    final stockItems = await ref.watch(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    final todayBoundary = _getBoundary(_ReportFilter.today);
    final periodBoundary = _getBoundary(filter);

    final allWeeklyRecords = <_WeeklyMortalityRecord>[];
    final flockHealth = <_FlockHealthSnapshot>[];

    for (final flock in flocks) {
      final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);
      final records = _reconstructMortalityRecords(
        flockId: flock.id,
        currentBirds: flock.quantity,
        plans: plans,
      );
      allWeeklyRecords.addAll(records);

      final flockLosses = records.fold<int>(0, (sum, item) => sum + item.losses);
      final flockBaseline = flock.quantity + flockLosses;
      final flockMortalityPercent = flockBaseline == 0
          ? null
          : (flockLosses / flockBaseline) * 100;

      flockHealth.add(
        _FlockHealthSnapshot(
          flockName: flock.name,
          birdCount: flock.quantity,
          recordedLosses: flockLosses,
          mortalityPercent: flockMortalityPercent,
          status: _healthStatusFromMortality(flockMortalityPercent),
        ),
      );
    }

    flockHealth.sort((a, b) => a.flockName.compareTo(b.flockName));
    final hasMortalityRecords = allWeeklyRecords.isNotEmpty;

    final totalBirdLosses = hasMortalityRecords
        ? allWeeklyRecords.fold<int>(0, (sum, item) => sum + item.losses)
        : null;
    final birdsAlive = flocks.fold<int>(0, (sum, flock) => sum + flock.quantity);
    final baselineBirds = totalBirdLosses == null ? null : birdsAlive + totalBirdLosses;
    final mortalityPercent =
        (baselineBirds == null || baselineBirds == 0 || totalBirdLosses == null)
            ? null
            : (totalBirdLosses / baselineBirds) * 100;

    final mortalityInSelectedPeriod = hasMortalityRecords
        ? _sumLossesForBoundary(allWeeklyRecords, periodBoundary)
        : null;

    final trendMap = <DateTime, int>{};
    for (final record in allWeeklyRecords) {
      if (!_weekOverlapsBoundary(record.weekStartDate, periodBoundary)) {
        continue;
      }
      trendMap[record.weekStartDate] =
          (trendMap[record.weekStartDate] ?? 0) + record.losses;
    }

    final trendKeys = trendMap.keys.toList()..sort();
    final mortalityTrend = trendKeys
        .map(
          (key) => _MortalityTrendPoint(
            periodStart: key,
            losses: trendMap[key]!,
          ),
        )
        .toList();

    var vaccinationsCompleted = 0;
    var vaccinationsDue = 0;
    var vaccinationsUpcoming = 0;
    final upcomingVaccinations = <_UpcomingVaccination>[];
    var hasVaccinationRecords = false;

    for (final flock in flocks) {
      final vaccines = await vaccineDataSource.getVaccineScheduleForFlock(flock.id);
      if (vaccines.isEmpty) {
        continue;
      }
      hasVaccinationRecords = true;

      for (final vaccine in vaccines) {
        final dueDate =
            flock.purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));

        if (dueDate.isBefore(todayBoundary.start)) {
          vaccinationsCompleted++;
          continue;
        }

        if (_isWithin(dueDate, todayBoundary)) {
          vaccinationsDue++;
          continue;
        }

        if (!dueDate.isBefore(todayBoundary.endExclusive)) {
          vaccinationsUpcoming++;
          upcomingVaccinations.add(
            _UpcomingVaccination(
              flockName: flock.name,
              vaccineName: vaccine.vaccineName,
              dueDate: dueDate,
            ),
          );
        }
      }
    }

    upcomingVaccinations.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final trimmedUpcoming = upcomingVaccinations.take(5).toList();

    final medicineItems = stockItems.where((item) {
      final category = item.category.toLowerCase();
      return category == 'medicines' || category == 'medicine';
    }).toList();

    final medicineUsedEntries = <Map<String, dynamic>>[];
    final medicineUsedEntriesInSelectedPeriod = <Map<String, dynamic>>[];
    for (final item in medicineItems) {
      final history = await stockDataSource.getItemHistory(item.id);
      for (final entry in history) {
        if (entry.action.toLowerCase() != 'used') {
          continue;
        }
        final map = <String, dynamic>{
          'itemName': entry.itemName,
          'quantity': entry.quantity,
          'unit': entry.unit,
          'date': entry.date,
        };
        medicineUsedEntries.add(map);
        if (_isWithin(entry.date, periodBoundary)) {
          medicineUsedEntriesInSelectedPeriod.add(map);
        }
      }
    }

    medicineUsedEntries.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    medicineUsedEntriesInSelectedPeriod.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    final treatmentsRecorded = medicineUsedEntries.length;
    final treatmentsInSelectedPeriod = medicineUsedEntriesInSelectedPeriod.length;
    final mostRecentTreatmentInSelectedPeriod = treatmentsInSelectedPeriod == 0
        ? null
        : '${medicineUsedEntriesInSelectedPeriod.first['itemName']} (${_formatDate(medicineUsedEntriesInSelectedPeriod.first['date'] as DateTime)})';

    final medicineTotalsInSelectedPeriod = <String, Map<String, double>>{};
    for (final entry in medicineUsedEntriesInSelectedPeriod) {
      final itemName = entry['itemName'] as String;
      final unit = entry['unit'] as String;
      final quantity = entry['quantity'] as double;
      final byUnit =
          medicineTotalsInSelectedPeriod.putIfAbsent(itemName, () => <String, double>{});
      _mergeQuantity(byUnit, unit, quantity);
    }

    final medicineUsageInSelectedPeriod =
        medicineTotalsInSelectedPeriod.entries.map((entry) {
      return _MedicineUsageSummary(
        itemName: entry.key,
        quantityLabel: _formatQuantities(entry.value),
      );
    }).toList()
      ..sort((a, b) => a.itemName.compareTo(b.itemName));

    final insights = <String>[];
    if (mortalityPercent != null && mortalityPercent <= 2) {
      insights.add('Excellent flock health.');
    }
    if (mortalityInSelectedPeriod != null && mortalityInSelectedPeriod == 0) {
      insights.add('No bird losses recorded in ${filter.label.toLowerCase()}.');
    }
    if (vaccinationsDue > 0) {
      insights.add('Vaccinations are due today.');
    }
    if (mortalityTrend.length >= 2) {
      final latest = mortalityTrend.last.losses;
      final previous = mortalityTrend[mortalityTrend.length - 2].losses;
      if (latest > previous) {
        insights.add('Mortality increased compared to last week.');
      }
    }
    if (treatmentsInSelectedPeriod > 0 &&
        mostRecentTreatmentInSelectedPeriod != null) {
      insights.add(
        'Recent treatment in ${filter.label.toLowerCase()}: '
        '$mostRecentTreatmentInSelectedPeriod.',
      );
    }

    return _HealthAnalyticsData(
      overallStatus: _healthStatusFromMortality(mortalityPercent),
      mortalityPercent: mortalityPercent,
      totalBirdLosses: totalBirdLosses,
      mortalityInSelectedPeriod: mortalityInSelectedPeriod,
      vaccinationsCompleted: vaccinationsCompleted,
      vaccinationsDue: vaccinationsDue,
      vaccinationsUpcoming: vaccinationsUpcoming,
      upcomingVaccinations: trimmedUpcoming,
      treatmentsRecorded: treatmentsRecorded,
      treatmentsInSelectedPeriod: treatmentsInSelectedPeriod,
      mostRecentTreatmentInSelectedPeriod: mostRecentTreatmentInSelectedPeriod,
      medicineUsageInSelectedPeriod: medicineUsageInSelectedPeriod,
      mortalityTrend: mortalityTrend,
      flockHealth: flockHealth,
      insights: insights,
      hasVaccinationRecords: hasVaccinationRecords,
      hasMortalityRecords: hasMortalityRecords,
    );
  },
);

class _FlockPerformancePage extends ConsumerStatefulWidget {
  final _ReportFilter initialFilter;

  const _FlockPerformancePage({required this.initialFilter});

  @override
  ConsumerState<_FlockPerformancePage> createState() =>
      _FlockPerformancePageState();
}

class _FlockPerformancePageState extends ConsumerState<_FlockPerformancePage> {
  late _ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final flockPerformanceAsync = ref.watch(
      _flockPerformanceProvider(_selectedFilter),
    );
    final flockData = flockPerformanceAsync.asData?.value;
    final canExport = flockData != null && flockData.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flock Performance'),
        actions: [
          _buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (flockData == null || flockData.isEmpty) {
                return;
              }
              final payload =
                  _buildFlockPerformanceExportPayload(flockData, _selectedFilter);
              await _handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodFilter(
            context,
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          flockPerformanceAsync.when(
            data: (flocks) {
              if (flocks.isEmpty) {
                return _buildEmptyState(context, 'Not recorded yet');
              }

              return Column(
                children: flocks.map((flock) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildFlockPerformanceCard(
                      context,
                      data: flock,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _FlockPerformanceDetailPage(
                              data: flock,
                              filter: _selectedFilter,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            ),
            error: (error, _) => _buildEmptyState(
              context,
              'Could not load flock performance.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}

class _FlockPerformanceDetailPage extends ConsumerWidget {
  final _FlockPerformanceData data;
  final _ReportFilter filter;

  const _FlockPerformanceDetailPage({
    required this.data,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(weeklyPlansProvider(data.flockId));
    final boundary = _getBoundary(filter);

    return Scaffold(
      appBar: AppBar(title: Text(data.flockName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricText('Bird count', '${data.birdCount}'),
                  const SizedBox(height: 8),
                  _metricText('Age', _formatAge(data.ageDays)),
                  const SizedBox(height: 8),
                  _metricText(
                    'Average weight',
                    data.averageWeightKg == null
                        ? 'Not recorded yet'
                        : '${data.averageWeightKg!.toStringAsFixed(2)} kg',
                    isEmpty: data.averageWeightKg == null,
                  ),
                  const SizedBox(height: 8),
                  _metricText(
                    'Mortality percentage',
                    data.mortalityPercent == null
                        ? 'Not recorded yet'
                        : '${data.mortalityPercent!.toStringAsFixed(1)}%',
                    isEmpty: data.mortalityPercent == null,
                  ),
                  const SizedBox(height: 8),
                  _metricText(
                    'Survival rate',
                    data.survivalRate == null
                        ? 'Not recorded yet'
                        : '${data.survivalRate!.toStringAsFixed(1)}%',
                    isEmpty: data.survivalRate == null,
                  ),
                  const SizedBox(height: 8),
                  _metricText('Performance status', data.performanceStatus),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Weekly analytics (${filter.label})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          plansAsync.when(
            data: (plans) {
              final visiblePlans = plans
                  .where((plan) => _weekOverlapsBoundary(plan.weekStartDate, boundary))
                  .toList()
                ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

              final hasAnyActual = visiblePlans.any(
                (plan) =>
                    plan.actualTotalFeedKg != null ||
                    plan.actualBodyWeightKg != null ||
                    plan.actualMortalityPercent != null,
              );

              if (visiblePlans.isEmpty || !hasAnyActual) {
                return _buildEmptyState(context, 'Not recorded yet');
              }

              return Column(
                children: visiblePlans.map((plan) {
                  final hasData = plan.actualTotalFeedKg != null ||
                      plan.actualBodyWeightKg != null ||
                      plan.actualMortalityPercent != null;
                  if (!hasData) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week ${plan.weekNumber}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            _metricText(
                              'Feed used',
                              plan.actualTotalFeedKg == null
                                  ? 'Not recorded yet'
                                  : '${plan.actualTotalFeedKg!.toStringAsFixed(1)} kg',
                              isEmpty: plan.actualTotalFeedKg == null,
                            ),
                            const SizedBox(height: 4),
                            _metricText(
                              'Weight',
                              plan.actualBodyWeightKg == null
                                  ? 'Not recorded yet'
                                  : '${plan.actualBodyWeightKg!.toStringAsFixed(2)} kg',
                              isEmpty: plan.actualBodyWeightKg == null,
                            ),
                            const SizedBox(height: 4),
                            _metricText(
                              'Mortality',
                              plan.actualMortalityPercent == null
                                  ? 'Not recorded yet'
                                  : '${plan.actualMortalityPercent!.toStringAsFixed(1)}%',
                              isEmpty: plan.actualMortalityPercent == null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            ),
            error: (error, _) => _buildEmptyState(
              context,
              'Could not load flock details.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedAnalyticsPage extends ConsumerStatefulWidget {
  final _ReportFilter initialFilter;

  const _FeedAnalyticsPage({required this.initialFilter});

  @override
  ConsumerState<_FeedAnalyticsPage> createState() => _FeedAnalyticsPageState();
}

class _FeedAnalyticsPageState extends ConsumerState<_FeedAnalyticsPage> {
  late _ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final feedAnalyticsAsync = ref.watch(_feedAnalyticsProvider(_selectedFilter));
    final feedData = feedAnalyticsAsync.asData?.value;
    final canExport = feedData != null && _feedAnalyticsHasData(feedData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Analytics'),
        actions: [
          _buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (feedData == null || !_feedAnalyticsHasData(feedData)) {
                return;
              }
              final payload = _buildFeedAnalyticsExportPayload(feedData, _selectedFilter);
              await _handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodFilter(
            context,
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          feedAnalyticsAsync.when(
            data: (feed) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeedMetricCard(
                    context,
                    title: 'Feed used in ${_selectedFilter.label}',
                    value: _emptyAwareQuantities(
                      feed.feedUsedInSelectedPeriodByUnit,
                    ),
                    isEmpty: feed.feedUsedInSelectedPeriodByUnit.isEmpty,
                  ),
                  const SizedBox(height: 8),
                  _buildFeedMetricCard(
                    context,
                    title: 'Remaining feed stock (Current Snapshot)',
                    value: _emptyAwareQuantities(feed.remainingFeedStockByUnit),
                    isEmpty: feed.remainingFeedStockByUnit.isEmpty,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Feed usage by flock (${_selectedFilter.label})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (feed.feedUsageByFlock.isEmpty)
                    _buildEmptyState(context, 'Not recorded yet')
                  else
                    Column(
                      children: feed.feedUsageByFlock.map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row.flockName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    row.usedKg == null
                                        ? 'Not recorded yet'
                                        : '${row.usedKg!.toStringAsFixed(1)} kg',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                      color: row.usedKg == null
                                          ? Colors.grey[600]
                                          : AppColors.earthCharcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Feed usage trend (${_selectedFilter.label})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (feed.feedUsageTrend.isEmpty)
                    _buildEmptyState(context, 'Not recorded yet')
                  else
                    Column(
                      children: feed.feedUsageTrend.map((point) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _formatDate(point.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    _formatQuantities(point.usageByUnit),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            ),
            error: (error, _) => _buildEmptyState(
              context,
              'Could not load feed analytics.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthAnalyticsPage extends ConsumerStatefulWidget {
  final _ReportFilter initialFilter;

  const _HealthAnalyticsPage({required this.initialFilter});

  @override
  ConsumerState<_HealthAnalyticsPage> createState() =>
      _HealthAnalyticsPageState();
}

class _HealthAnalyticsPageState extends ConsumerState<_HealthAnalyticsPage> {
  late _ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(_healthAnalyticsProvider(_selectedFilter));
    final healthData = healthAsync.asData?.value;
    final canExport = healthData != null && _healthAnalyticsHasData(healthData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analytics'),
        actions: [
          _buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (healthData == null || !_healthAnalyticsHasData(healthData)) {
                return;
              }
              final payload = _buildHealthAnalyticsExportPayload(
                healthData,
                _selectedFilter,
              );
              await _handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodFilter(
            context,
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          healthAsync.when(
            data: (health) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthOverviewCard(context, health),
                  const SizedBox(height: 12),
                  Text(
                    'Flock health snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (health.flockHealth.isEmpty)
                    _buildEmptyState(context, 'Not recorded yet')
                  else
                    Column(
                      children: health.flockHealth.map((flock) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          flock.flockName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      _buildStatusBadge(flock.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _metricText('Bird count', '${flock.birdCount}'),
                                  const SizedBox(height: 4),
                                  _metricText(
                                    'Recorded losses',
                                    '${flock.recordedLosses}',
                                  ),
                                  const SizedBox(height: 4),
                                  _metricText(
                                    'Mortality percentage',
                                    flock.mortalityPercent == null
                                        ? 'No mortality records yet.'
                                        : '${flock.mortalityPercent!.toStringAsFixed(1)}%',
                                    isEmpty: flock.mortalityPercent == null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Mortality analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildMortalityCard(context, health, _selectedFilter),
                  const SizedBox(height: 12),
                  Text(
                    'Vaccination analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildVaccinationCard(context, health),
                  const SizedBox(height: 12),
                  Text(
                    'Treatment analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildTreatmentCard(context, health, _selectedFilter),
                  const SizedBox(height: 12),
                  Text(
                    'Health insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildHealthInsightsCard(context, health),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            ),
            error: (error, _) => _buildEmptyState(
              context,
              'Could not load health analytics.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHealthOverviewCard(BuildContext context, _HealthAnalyticsData health) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.shieldHeart,
                color: AppColors.leakukuGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Health overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricText('Overall flock health status', health.overallStatus),
          const SizedBox(height: 6),
          _metricText(
            'Mortality percentage',
            health.mortalityPercent == null
                ? 'No mortality records yet.'
                : '${health.mortalityPercent!.toStringAsFixed(1)}%',
            isEmpty: health.mortalityPercent == null,
          ),
          const SizedBox(height: 6),
          _metricText(
            'Total recorded bird losses',
            health.totalBirdLosses == null
                ? 'No mortality records yet.'
                : '${health.totalBirdLosses}',
            isEmpty: health.totalBirdLosses == null,
          ),
          const SizedBox(height: 6),
          _metricText('Vaccinations completed', '${health.vaccinationsCompleted}'),
          const SizedBox(height: 6),
          _metricText('Vaccinations due', '${health.vaccinationsDue}'),
          const SizedBox(height: 6),
          _metricText('Treatments recorded (All Time)', '${health.treatmentsRecorded}'),
        ],
      ),
    ),
  );
}

Widget _buildMortalityCard(
  BuildContext context,
  _HealthAnalyticsData health,
  _ReportFilter filter,
) {
  if (!health.hasMortalityRecords) {
    return _buildEmptyState(context, 'No mortality records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricText(
            'Mortality in ${filter.label}',
            health.mortalityInSelectedPeriod == null
                ? 'No mortality records yet.'
                : '${health.mortalityInSelectedPeriod}',
            isEmpty: health.mortalityInSelectedPeriod == null,
          ),
          if (health.mortalityTrend.length >= 2) ...[
            const SizedBox(height: 12),
            Text(
              'Trend (${filter.label})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            _SimpleMortalityTrendChart(points: health.mortalityTrend),
          ],
        ],
      ),
    ),
  );
}

Widget _buildVaccinationCard(BuildContext context, _HealthAnalyticsData health) {
  if (!health.hasVaccinationRecords) {
    return _buildEmptyState(context, 'No vaccination records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricText('Vaccinations completed', '${health.vaccinationsCompleted}'),
          const SizedBox(height: 6),
          _metricText('Vaccinations due', '${health.vaccinationsDue}'),
          const SizedBox(height: 6),
          _metricText('Upcoming vaccinations', '${health.vaccinationsUpcoming}'),
          const SizedBox(height: 10),
          if (health.upcomingVaccinations.isEmpty)
            Text(
              'No upcoming vaccinations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            Column(
              children: health.upcomingVaccinations.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.syringe,
                        size: 12,
                        color: AppColors.leakukuGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.vaccineName} (${item.flockName})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        _formatDate(item.dueDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}

Widget _buildTreatmentCard(
  BuildContext context,
  _HealthAnalyticsData health,
  _ReportFilter filter,
) {
  if (health.treatmentsInSelectedPeriod == 0) {
    return _buildEmptyState(context, 'No treatment records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricText(
            'Number of treatments in ${filter.label}',
            '${health.treatmentsInSelectedPeriod}',
          ),
          const SizedBox(height: 6),
          _metricText(
            'Most recent treatment',
            health.mostRecentTreatmentInSelectedPeriod ??
                'No treatment records yet.',
            isEmpty: health.mostRecentTreatmentInSelectedPeriod == null,
          ),
          const SizedBox(height: 10),
          Text(
            'Medicine usage summary (${filter.label})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          if (health.medicineUsageInSelectedPeriod.isEmpty)
            Text(
              'No treatment records yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            Column(
              children: health.medicineUsageInSelectedPeriod.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        item.quantityLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}

Widget _buildHealthInsightsCard(BuildContext context, _HealthAnalyticsData health) {
  if (health.insights.isEmpty) {
    return _buildEmptyState(context, 'Not enough health records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: health.insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: FaIcon(
                    FontAwesomeIcons.lightbulb,
                    size: 12,
                    color: AppColors.leakukuGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}

class _SimpleMortalityTrendChart extends StatelessWidget {
  final List<_MortalityTrendPoint> points;

  const _SimpleMortalityTrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final visible = points.length <= 6 ? points : points.sublist(points.length - 6);
    final maxLoss = visible.fold<int>(0, (max, point) {
      return point.losses > max ? point.losses : max;
    });

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: visible.map((point) {
          final factor = maxLoss == 0 ? 0.0 : point.losses / maxLoss;
          final barHeight = 16 + (74 * factor);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${point.losses}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.leakukuGreen.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _shortDate(point.periodStart),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget _buildPeriodFilter(
  BuildContext context, {
  required _ReportFilter selectedFilter,
  required ValueChanged<_ReportFilter> onChanged,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _visibleReportFilters.map((filter) {
          return ChoiceChip(
            label: Text(filter.label),
            selected: selectedFilter == filter,
            onSelected: (_) => onChanged(filter),
          );
        }).toList(),
      ),
    ),
  );
}

Widget _buildFlockPerformanceCard(
  BuildContext context, {
  required _FlockPerformanceData data,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.flockName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _buildStatusBadge(data.performanceStatus),
              ],
            ),
            const SizedBox(height: 10),
            _metricText('Bird count', '${data.birdCount}'),
            const SizedBox(height: 4),
            _metricText('Age', _formatAge(data.ageDays)),
            const SizedBox(height: 4),
            _metricText(
              'Average weight',
              data.averageWeightKg == null
                  ? 'Not recorded yet'
                  : '${data.averageWeightKg!.toStringAsFixed(2)} kg',
              isEmpty: data.averageWeightKg == null,
            ),
            const SizedBox(height: 4),
            _metricText(
              'Mortality percentage',
              data.mortalityPercent == null
                  ? 'Not recorded yet'
                  : '${data.mortalityPercent!.toStringAsFixed(1)}%',
              isEmpty: data.mortalityPercent == null,
            ),
            const SizedBox(height: 4),
            _metricText(
              'Survival rate',
              data.survivalRate == null
                  ? 'Not recorded yet'
                  : '${data.survivalRate!.toStringAsFixed(1)}%',
              isEmpty: data.survivalRate == null,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFeedMetricCard(
  BuildContext context, {
  required String title,
  required String value,
  required bool isEmpty,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusBadge(String status) {
  final color = _statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget _buildEmptyState(BuildContext context, String message) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
      ),
    ),
  );
}

Widget _metricText(String label, String value, {bool isEmpty = false}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.softGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        value,
        style: TextStyle(
          color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

String _emptyAwareQuantities(Map<String, double> quantityByUnit) {
  if (quantityByUnit.isEmpty) {
    return 'Not recorded yet';
  }
  return _formatQuantities(quantityByUnit);
}

String _formatAge(int ageDays) {
  if (ageDays < 0) {
    return 'Not recorded yet';
  }
  final weeks = ageDays ~/ 7;
  final days = ageDays % 7;
  return '${weeks}w ${days}d';
}

List<_WeeklyMortalityRecord> _reconstructMortalityRecords({
  required String flockId,
  required int currentBirds,
  required List<dynamic> plans,
}) {
  final withMortality = plans
      .where(
        (plan) =>
            plan.actualMortalityPercent != null &&
            plan.actualMortalityPercent! > 0 &&
            plan.actualMortalityPercent! < 100,
      )
      .toList()
    ..sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));

  final records = <_WeeklyMortalityRecord>[];
  var birdsAfter = currentBirds.toDouble();

  for (final plan in withMortality) {
    final percent = (plan.actualMortalityPercent as double);
    final ratio = 1 - (percent / 100);
    if (ratio <= 0) {
      continue;
    }

    final birdsBefore = birdsAfter / ratio;
    final losses = (birdsBefore - birdsAfter).round();
    if (losses <= 0) {
      birdsAfter = birdsBefore;
      continue;
    }

    records.add(
      _WeeklyMortalityRecord(
        flockId: flockId,
        weekStartDate: plan.weekStartDate as DateTime,
        losses: losses,
        mortalityPercent: percent,
      ),
    );

    birdsAfter = birdsBefore;
  }

  return records;
}

int _sumLossesForBoundary(
  List<_WeeklyMortalityRecord> records,
  _Boundary boundary,
) {
  return records
      .where((item) => _weekOverlapsBoundary(item.weekStartDate, boundary))
      .fold<int>(0, (sum, item) => sum + item.losses);
}

String _healthStatusFromMortality(double? mortalityPercent) {
  if (mortalityPercent == null) {
    return 'Not recorded yet';
  }
  if (mortalityPercent <= 2) {
    return 'Excellent';
  }
  if (mortalityPercent <= 5) {
    return 'Good';
  }
  return 'Needs Attention';
}

String _shortDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day';
}

String _performanceStatus({
  required double? mortalityPercent,
  required double? averageWeightKg,
}) {
  if (mortalityPercent != null) {
    if (mortalityPercent <= 2) {
      return 'Excellent';
    }
    if (mortalityPercent <= 5) {
      return 'Good';
    }
    return 'Needs Attention';
  }

  if (averageWeightKg != null) {
    return 'Good';
  }

  return 'Needs Attention';
}

Color _statusColor(String status) {
  switch (status) {
    case 'Excellent':
      return AppColors.leakukuGreen;
    case 'Good':
      return const Color(0xFF1E88E5);
    case 'Needs Attention':
      return AppColors.errorRed;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class _Boundary {
  final DateTime start;
  final DateTime endExclusive;

  const _Boundary({
    required this.start,
    required this.endExclusive,
  });
}

_Boundary _getBoundary(_ReportFilter filter) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  switch (filter) {
    case _ReportFilter.today:
      return _Boundary(
        start: todayStart,
        endExclusive: todayStart.add(const Duration(days: 1)),
      );
    case _ReportFilter.thisWeek:
      final weekdayOffset = now.weekday - DateTime.monday;
      final weekStart = todayStart.subtract(Duration(days: weekdayOffset));
      return _Boundary(
        start: weekStart,
        endExclusive: weekStart.add(const Duration(days: 7)),
      );
    case _ReportFilter.thisMonth:
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonthStart = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      return _Boundary(
        start: monthStart,
        endExclusive: nextMonthStart,
      );
    case _ReportFilter.thisYear:
      final yearStart = DateTime(now.year, 1, 1);
      final nextYearStart = DateTime(now.year + 1, 1, 1);
      return _Boundary(
        start: yearStart,
        endExclusive: nextYearStart,
      );
    case _ReportFilter.custom:
      return _Boundary(
        start: todayStart,
        endExclusive: todayStart.add(const Duration(days: 1)),
      );
  }
}

bool _isWithin(DateTime value, _Boundary boundary) {
  return !value.isBefore(boundary.start) && value.isBefore(boundary.endExclusive);
}

bool _weekOverlapsBoundary(DateTime weekStartDate, _Boundary boundary) {
  final weekEndExclusive = weekStartDate.add(const Duration(days: 7));
  return weekEndExclusive.isAfter(boundary.start) &&
      weekStartDate.isBefore(boundary.endExclusive);
}

void _mergeQuantity(Map<String, double> store, String unit, double quantity) {
  store[unit] = (store[unit] ?? 0) + quantity;
}

String _formatQuantities(Map<String, double> quantityByUnit) {
  final units = quantityByUnit.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return units
      .map((entry) => '${_formatDecimal(entry.value)} ${entry.key}')
      .join(' • ');
}

String _formatDecimal(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

_Boundary _getPreviousBoundary(_ReportFilter filter) {
  final current = _getBoundary(filter);
  final duration = current.endExclusive.difference(current.start);
  return _Boundary(
    start: current.start.subtract(duration),
    endExclusive: current.start,
  );
}

String _previousLabelForFilter(_ReportFilter filter) {
  switch (filter) {
    case _ReportFilter.today:
      return 'day';
    case _ReportFilter.thisWeek:
      return 'week';
    case _ReportFilter.thisMonth:
      return 'month';
    case _ReportFilter.thisYear:
      return 'year';
    case _ReportFilter.custom:
      return 'period';
  }
}

List<MapEntry<String, double>> _sortedEntries(Map<String, double> values) {
  final entries = values.entries.toList();
  entries.sort((a, b) => b.value.compareTo(a.value));
  return entries;
}

String _formatMoney(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'KES ',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

String _formatPercent(double? value) {
  if (value == null) {
    return 'N/A';
  }
  return '${value.toStringAsFixed(1)}%';
}

enum _ReportExportAction { pdf, excel, share }

class _ReportExportPayload {
  final String reportTitle;
  final String periodLabel;
  final List<List<String>> rows;

  const _ReportExportPayload({
    required this.reportTitle,
    required this.periodLabel,
    required this.rows,
  });
}

Widget _buildReportExportAction(
  BuildContext context, {
  required bool enabled,
  required Future<void> Function(_ReportExportAction action) onActionSelected,
}) {
  if (!enabled) {
    return const IconButton(
      onPressed: null,
      icon: Icon(Icons.download_outlined),
      tooltip: 'There is no data available for the selected period.',
    );
  }

  return PopupMenuButton<_ReportExportAction>(
    tooltip: 'Export',
    icon: const Icon(Icons.download_outlined),
    onSelected: (action) async {
      await onActionSelected(action);
    },
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: _ReportExportAction.pdf,
        child: Text('Export PDF'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.excel,
        child: Text('Export Excel'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.share,
        child: Text('Share'),
      ),
    ],
  );
}

Future<void> _handleExportAction(
  BuildContext context,
  _ReportExportAction action,
  _ReportExportPayload payload,
) async {
  if (payload.rows.length <= 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('There is no data available for the selected period.'),
      ),
    );
    return;
  }

  try {
    if (action == _ReportExportAction.pdf) {
      final file = await _generatePdfFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported: ${file.path}')),
      );
      return;
    }

    if (action == _ReportExportAction.excel) {
      final file = await _generateExcelFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel exported: ${file.path}')),
      );
      return;
    }

    final file = await _generatePdfFile(payload);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${payload.reportTitle} (${payload.periodLabel})',
      text: 'Leakuku Report: ${payload.reportTitle} (${payload.periodLabel})',
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $error')),
    );
  }
}

Future<File> _generatePdfFile(_ReportExportPayload payload) async {
  final doc = pw.Document();
  final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  final headers = payload.rows.first;
  final dataRows = payload.rows.skip(1).toList();

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          payload.reportTitle,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Reporting Period: ${payload.periodLabel}'),
        pw.Text('Generated: $generatedAt'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: dataRows,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(
            color: pdf_core.PdfColor.fromInt(0xFFEFEFEF),
          ),
        ),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final fileName = _exportFileName(payload.reportTitle, payload.periodLabel, 'pdf');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(await doc.save(), flush: true);
  return file;
}

Future<File> _generateExcelFile(_ReportExportPayload payload) async {
  final workbook = Excel.createExcel();
  final sheet = workbook['Report'];

  for (final row in payload.rows) {
    sheet.appendRow(row);
  }

  final bytes = workbook.encode();
  if (bytes == null) {
    throw Exception('Unable to encode Excel file.');
  }

  final dir = await getTemporaryDirectory();
  final fileName = _exportFileName(payload.reportTitle, payload.periodLabel, 'xlsx');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

String _exportFileName(String reportTitle, String periodLabel, String extension) {
  final slugTitle = reportTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final slugPeriod = periodLabel.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${slugTitle}_${slugPeriod}_$timestamp.$extension';
}

bool _farmSummaryHasData(FarmSummaryData data) {
  return data.activeFlocks > 0 ||
      data.totalBirdsAlive > 0 ||
      data.feedStockByUnit.isNotEmpty ||
      data.feedUsedByUnit.isNotEmpty ||
      data.averageMortalityPercent != null;
}

bool _feedAnalyticsHasData(_FeedAnalyticsData data) {
  final hasFlockUsage = data.feedUsageByFlock.any((item) => item.usedKg != null);
  return data.feedUsedInSelectedPeriodByUnit.isNotEmpty ||
      data.remainingFeedStockByUnit.isNotEmpty ||
      hasFlockUsage ||
      data.feedUsageTrend.isNotEmpty;
}

bool _healthAnalyticsHasData(_HealthAnalyticsData data) {
  return data.hasMortalityRecords ||
      data.hasVaccinationRecords ||
      data.treatmentsRecorded > 0 ||
      data.flockHealth.isNotEmpty;
}

_ReportExportPayload _buildFarmSummaryExportPayload(
  FarmSummaryData data,
  _ReportFilter filter,
) {
  return _ReportExportPayload(
    reportTitle: 'Farm Summary',
    periodLabel: filter.label,
    rows: [
      ['Metric', 'Value'],
      ['Active flocks (Current Snapshot)', '${data.activeFlocks}'],
      ['Total birds alive (Current Snapshot)', '${data.totalBirdsAlive}'],
      [
        'Feed stock available (Current Snapshot)',
        data.feedStockByUnit.isEmpty
            ? 'No feed stock recorded yet.'
            : _formatQuantities(data.feedStockByUnit),
      ],
      [
        'Mortality percentage (${filter.label})',
        data.averageMortalityPercent == null
            ? 'No mortality records for this period.'
            : '${data.averageMortalityPercent!.toStringAsFixed(1)}%',
      ],
      [
        'Feed used (${filter.label})',
        data.feedUsedByUnit.isEmpty
            ? 'No feed usage recorded for this period.'
            : _formatQuantities(data.feedUsedByUnit),
      ],
    ],
  );
}

_ReportExportPayload _buildFlockPerformanceExportPayload(
  List<_FlockPerformanceData> flocks,
  _ReportFilter filter,
) {
  final rows = <List<String>>[
    ['Metric', 'Value'],
    ['Reporting Period', filter.label],
  ];

  for (final flock in flocks) {
    rows.add(['Flock', flock.flockName]);
    rows.add(['Bird count (Current Snapshot)', '${flock.birdCount}']);
    rows.add(['Age (Current Snapshot)', _formatAge(flock.ageDays)]);
    rows.add([
      'Average weight (${filter.label})',
      flock.averageWeightKg == null
          ? 'Not recorded yet'
          : '${flock.averageWeightKg!.toStringAsFixed(2)} kg',
    ]);
    rows.add([
      'Mortality percentage (${filter.label})',
      flock.mortalityPercent == null
          ? 'Not recorded yet'
          : '${flock.mortalityPercent!.toStringAsFixed(1)}%',
    ]);
    rows.add([
      'Survival rate (${filter.label})',
      flock.survivalRate == null
          ? 'Not recorded yet'
          : '${flock.survivalRate!.toStringAsFixed(1)}%',
    ]);
  }

  return _ReportExportPayload(
    reportTitle: 'Flock Performance',
    periodLabel: filter.label,
    rows: rows,
  );
}

_ReportExportPayload _buildFeedAnalyticsExportPayload(
  _FeedAnalyticsData data,
  _ReportFilter filter,
) {
  final rows = <List<String>>[
    ['Metric', 'Value'],
    [
      'Feed used (${filter.label})',
      data.feedUsedInSelectedPeriodByUnit.isEmpty
          ? 'Not recorded yet'
          : _formatQuantities(data.feedUsedInSelectedPeriodByUnit),
    ],
    [
      'Remaining feed stock (Current Snapshot)',
      data.remainingFeedStockByUnit.isEmpty
          ? 'Not recorded yet'
          : _formatQuantities(data.remainingFeedStockByUnit),
    ],
  ];

  if (data.feedUsageByFlock.isNotEmpty) {
    rows.add(['Feed usage by flock (${filter.label})', '']);
    for (final item in data.feedUsageByFlock) {
      rows.add([
        item.flockName,
        item.usedKg == null ? 'Not recorded yet' : '${item.usedKg!.toStringAsFixed(1)} kg',
      ]);
    }
  }

  if (data.feedUsageTrend.isNotEmpty) {
    rows.add(['Feed usage trend (${filter.label})', '']);
    for (final point in data.feedUsageTrend) {
      rows.add([
        _formatDate(point.date),
        _formatQuantities(point.usageByUnit),
      ]);
    }
  }

  return _ReportExportPayload(
    reportTitle: 'Feed Analytics',
    periodLabel: filter.label,
    rows: rows,
  );
}

_ReportExportPayload _buildHealthAnalyticsExportPayload(
  _HealthAnalyticsData data,
  _ReportFilter filter,
) {
  final rows = <List<String>>[
    ['Metric', 'Value'],
    ['Overall flock health status (Current Snapshot)', data.overallStatus],
    [
      'Mortality percentage (Current Snapshot)',
      data.mortalityPercent == null
          ? 'No mortality records yet.'
          : '${data.mortalityPercent!.toStringAsFixed(1)}%',
    ],
    [
      'Total recorded bird losses (Current Snapshot)',
      data.totalBirdLosses == null ? 'No mortality records yet.' : '${data.totalBirdLosses}',
    ],
    ['Vaccinations completed (Current Snapshot)', '${data.vaccinationsCompleted}'],
    ['Vaccinations due (Current Snapshot)', '${data.vaccinationsDue}'],
    ['Upcoming vaccinations (Current Snapshot)', '${data.vaccinationsUpcoming}'],
    ['Treatments recorded (All Time Snapshot)', '${data.treatmentsRecorded}'],
    [
      'Mortality in ${filter.label}',
      data.mortalityInSelectedPeriod == null
          ? 'No mortality records yet.'
          : '${data.mortalityInSelectedPeriod}',
    ],
    ['Treatments in ${filter.label}', '${data.treatmentsInSelectedPeriod}'],
    [
      'Most recent treatment in ${filter.label}',
      data.mostRecentTreatmentInSelectedPeriod ?? 'No treatment records yet.',
    ],
  ];

  if (data.medicineUsageInSelectedPeriod.isNotEmpty) {
    rows.add(['Medicine usage summary (${filter.label})', '']);
    for (final item in data.medicineUsageInSelectedPeriod) {
      rows.add([item.itemName, item.quantityLabel]);
    }
  }

  if (data.insights.isNotEmpty) {
    rows.add(['Health insights (${filter.label})', '']);
    for (final insight in data.insights) {
      rows.add(['Insight', insight]);
    }
  }

  return _ReportExportPayload(
    reportTitle: 'Health Analytics',
    periodLabel: filter.label,
    rows: rows,
  );
}

_ReportExportPayload _buildBusinessAnalyticsExportPayload(
  _BusinessAnalyticsData data,
  _ReportFilter filter,
) {
  final rows = <List<String>>[
    ['Metric', 'Value'],
    ['Total Revenue', _formatMoney(data.totalRevenue)],
    ['Total Expenses', _formatMoney(data.totalExpenses)],
    ['Estimated Profit', _formatMoney(data.estimatedProfit)],
    ['Profit Margin', _formatPercent(data.profitMargin)],
  ];

  if (data.revenueByCategory.isNotEmpty) {
    rows.add(['Revenue Breakdown', '']);
    for (final entry in _sortedEntries(data.revenueByCategory)) {
      rows.add([entry.key, _formatMoney(entry.value)]);
    }
  }

  if (data.expenseByCategory.isNotEmpty) {
    rows.add(['Expense Breakdown', '']);
    for (final entry in _sortedEntries(data.expenseByCategory)) {
      rows.add([entry.key, _formatMoney(entry.value)]);
    }
  }

  if (data.flockSummaries.isNotEmpty) {
    rows.add(['Flock Profitability', '']);
    final flockEntries = data.flockSummaries.values.toList()
      ..sort((a, b) => b.estimatedProfit.compareTo(a.estimatedProfit));
    for (final item in flockEntries) {
      rows.add([
        item.flockLabel,
        'Revenue ${_formatMoney(item.revenue)} | '
            'Expenses ${_formatMoney(item.expenses)} | '
            'Profit ${_formatMoney(item.estimatedProfit)}',
      ]);
    }
  }

  if (data.insights.isNotEmpty) {
    rows.add(['Business Insights', '']);
    for (final insight in data.insights) {
      rows.add(['Insight', insight]);
    }
  }

  return _ReportExportPayload(
    reportTitle: 'Business Analytics',
    periodLabel: filter.label,
    rows: rows,
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

  final rankedRevenue = _sortedEntries(revenueByCategory);
  if (rankedRevenue.isNotEmpty) {
    insights.add('${rankedRevenue.first.key} generated most of your income.');
  }

  final rankedExpenses = _sortedEntries(expenseByCategory);
  if (rankedExpenses.isNotEmpty) {
    insights.add('${rankedExpenses.first.key} is your largest expense.');
  }

  final labourCurrent = expenseByCategory['Labour'];
  if (labourCurrent != null && labourCurrent > 0) {
    final totalExpense = expenseByCategory.values.fold<double>(0, (s, v) => s + v);
    if (totalExpense > 0) {
      final labourShare = (labourCurrent / totalExpense) * 100;
      if (labourShare <= 20) {
        insights.add('Labour costs stayed moderate in this period.');
      }
    }
  }

  if (previousProfit != null) {
    if (currentProfit > previousProfit) {
      insights.add('Profit increased compared to last $previousLabel.');
    } else if (currentProfit < previousProfit) {
      insights.add('Profit decreased compared to last $previousLabel.');
    }
  }

  return insights;
}
