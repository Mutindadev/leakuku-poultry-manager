import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/providers/business_analytics.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/breakdown_card.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/business_insight_card.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/cost_distribution_card.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/flock_profitability_card.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/profitability_card.dart';

class BusinessAnalyticsPage extends ConsumerStatefulWidget {
  final ReportFilter initialFilter;

  const BusinessAnalyticsPage({super.key, required this.initialFilter});

  @override
  ConsumerState<BusinessAnalyticsPage> createState() =>
      _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends ConsumerState<BusinessAnalyticsPage> {
  late ReportFilter _selectedFilter;
  static const reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  ReportExportPayload _buildBusinessAnalyticsExportPayload(
    BusinessAnalyticsData data,
    ReportFilter filter,
  ) {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Total Revenue', formatMoney(data.totalRevenue)],
      ['Total Expenses', formatMoney(data.totalExpenses)],
      ['Estimated Profit', formatMoney(data.estimatedProfit)],
      ['Profit Margin', reportService.formatPercent(data.profitMargin)],
    ];

    if (data.revenueByCategory.isNotEmpty) {
      rows.add(['Revenue Breakdown', '']);
      for (final entry in reportService.sortedEntries(data.revenueByCategory)) {
        rows.add([entry.key, formatMoney(entry.value)]);
      }
    }

    if (data.expenseByCategory.isNotEmpty) {
      rows.add(['Expense Breakdown', '']);
      for (final entry in reportService.sortedEntries(data.expenseByCategory)) {
        rows.add([entry.key, formatMoney(entry.value)]);
      }
    }

    if (data.flockSummaries.isNotEmpty) {
      rows.add(['Flock Profitability', '']);
      final flockEntries = data.flockSummaries.values.toList()
        ..sort((a, b) => b.estimatedProfit.compareTo(a.estimatedProfit));
      for (final item in flockEntries) {
        rows.add([
          item.flockLabel,
          'Revenue ${formatMoney(item.revenue)} | '
              'Expenses ${formatMoney(item.expenses)} | '
              'Profit ${formatMoney(item.estimatedProfit)}',
        ]);
      }
    }

    if (data.insights.isNotEmpty) {
      rows.add(['Business Insights', '']);
      for (final insight in data.insights) {
        rows.add(['Insight', insight]);
      }
    }

    return ReportExportPayload(
      reportTitle: 'Business Analytics',
      periodLabel: filter.label,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(
      businessAnalyticsProvider(_selectedFilter),
    );

    final analyticsData = analyticsState.data;
    final canExport = analyticsData != null && analyticsData.hasRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics'),
        actions: [
          buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (analyticsData == null || !analyticsData.hasRecords) {
                return;
              }
              final payload = _buildBusinessAnalyticsExportPayload(
                  analyticsData, _selectedFilter);
              await handleExportAction(context, action, payload);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildPeriodFilter(
            context,
            selectedFilter: _selectedFilter,
            onChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const SizedBox(height: 12),
          analyticsData == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.leakukuGreen,
                    ),
                  ),
                )
              : (() {
                  final analytics = analyticsData;
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
                  SummaryCard(title: 'Financial Summary', analytics: analytics),
                  const SizedBox(height: 12),
                  BreakdownCard(
                    title: 'Revenue Breakdown',
                    icon: FontAwesomeIcons.arrowTrendUp,
                    color: AppColors.successGreen,
                    values: analytics.revenueByCategory,
                  ),
                  const SizedBox(height: 12),
                  BreakdownCard(
                    title: 'Expense Breakdown',
                    icon: FontAwesomeIcons.arrowTrendDown,
                    color: AppColors.errorRed,
                    values: analytics.expenseByCategory,
                  ),
                  const SizedBox(height: 12),
                  CostDistributionCard(analytics: analytics),
                  const SizedBox(height: 12),
                  SummaryCard(title: 'Profitability', analytics: analytics),
                  const SizedBox(height: 12),
                  FlockProfitabilityCard(analytics: analytics),
                  const SizedBox(height: 12),
                  BusinessInsightCard(analytics: analytics),
                ],
              );
            })(),
        ],
      ),
    );
  }
}
