import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/farm_summary_data.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/providers/farm_summary.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/summary_metric.dart';

class FarmSummaryDetailPage extends ConsumerWidget {
  final ReportFilter filter;

  const FarmSummaryDetailPage({super.key, required this.filter});

  static const _reportService = ReportService();

  bool _farmSummaryHasData(FarmSummaryData data) {
    return data.activeFlocks > 0 ||
        data.totalBirdsAlive > 0 ||
        data.feedStockByUnit.isNotEmpty ||
        data.feedUsedByUnit.isNotEmpty ||
        data.averageMortalityPercent != null;
  }

  ReportExportPayload _buildFarmSummaryExportPayload(
    FarmSummaryData data,
    ReportFilter filter,
  ) {
    return ReportExportPayload(
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
              : _reportService.formatQuantities(data.feedStockByUnit),
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
              : _reportService.formatQuantities(data.feedUsedByUnit),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(farmSummaryProvider(filter));
    final summaryData = summaryAsync.asData?.value;
    final canExport = summaryData != null && _farmSummaryHasData(summaryData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Summary'),
        actions: [
          buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (summaryData == null) {
                return;
              }
              final payload =
                  _buildFarmSummaryExportPayload(summaryData, filter);
              await handleExportAction(context, action, payload);
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
                    SummaryMetricRow(
                      icon: FontAwesomeIcons.kiwiBird,
                      label: 'Active flocks',
                      value: '${summary.activeFlocks}',
                    ),
                    const SizedBox(height: 10),
                    SummaryMetricRow(
                      icon: FontAwesomeIcons.drumstickBite,
                      label: 'Total birds alive',
                      value: '${summary.totalBirdsAlive}',
                    ),
                    const SizedBox(height: 10),
                    SummaryMetricRow(
                      icon: FontAwesomeIcons.boxesStacked,
                      label: 'Feed stock available',
                      value: summary.feedStockByUnit.isEmpty
                          ? 'No feed stock recorded yet.'
                          : _reportService
                              .formatQuantities(summary.feedStockByUnit),
                      isEmpty: summary.feedStockByUnit.isEmpty,
                    ),
                    const SizedBox(height: 10),
                    SummaryMetricRow(
                      icon: FontAwesomeIcons.percent,
                      label: 'Mortality percentage',
                      value: summary.averageMortalityPercent == null
                          ? 'No mortality records for this period.'
                          : '${summary.averageMortalityPercent!.toStringAsFixed(1)}%',
                      isEmpty: summary.averageMortalityPercent == null,
                    ),
                    const SizedBox(height: 10),
                    SummaryMetricRow(
                      icon: FontAwesomeIcons.wheatAwn,
                      label: filter == ReportFilter.today
                          ? 'Feed used today'
                          : 'Feed used in period',
                      value: summary.feedUsedByUnit.isEmpty
                          ? 'No feed usage recorded for this period.'
                          : _reportService
                              .formatQuantities(summary.feedUsedByUnit),
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
