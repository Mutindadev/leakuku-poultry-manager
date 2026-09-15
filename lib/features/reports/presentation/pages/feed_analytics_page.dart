import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/feed_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/providers/feed_analytics.dart';
import 'package:leakuku/features/reports/presentation/widgets/feed/metric_card.dart';

class FeedAnalyticsPage extends ConsumerStatefulWidget {
  final ReportFilter initialFilter;

  const FeedAnalyticsPage({super.key, required this.initialFilter});

  @override
  ConsumerState<FeedAnalyticsPage> createState() => _FeedAnalyticsPageState();
}

class _FeedAnalyticsPageState extends ConsumerState<FeedAnalyticsPage> {
  late ReportFilter _selectedFilter;
  static const reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  bool _feedAnalyticsHasData(FeedAnalyticsData data) {
    final hasFlockUsage =
        data.feedUsageByFlock.any((item) => item.usedKg != null);
    return data.feedUsedInSelectedPeriodByUnit.isNotEmpty ||
        data.remainingFeedStockByUnit.isNotEmpty ||
        hasFlockUsage ||
        data.feedUsageTrend.isNotEmpty;
  }

  String _emptyAwareQuantities(Map<String, double> quantityByUnit) {
    if (quantityByUnit.isEmpty) {
      return 'Not recorded yet';
    }
    return reportService.formatQuantities(quantityByUnit);
  }

  ReportExportPayload _buildFeedAnalyticsExportPayload(
    FeedAnalyticsData data,
    ReportFilter filter,
  ) {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      [
        'Feed used (${filter.label})',
        data.feedUsedInSelectedPeriodByUnit.isEmpty
            ? 'Not recorded yet'
            : reportService
                .formatQuantities(data.feedUsedInSelectedPeriodByUnit),
      ],
      [
        'Remaining feed stock (Current Snapshot)',
        data.remainingFeedStockByUnit.isEmpty
            ? 'Not recorded yet'
            : reportService.formatQuantities(data.remainingFeedStockByUnit),
      ],
    ];

    if (data.feedUsageByFlock.isNotEmpty) {
      rows.add(['Feed usage by flock (${filter.label})', '']);
      for (final item in data.feedUsageByFlock) {
        rows.add([
          item.flockName,
          item.usedKg == null
              ? 'Not recorded yet'
              : '${item.usedKg!.toStringAsFixed(1)} kg',
        ]);
      }
    }

    if (data.feedUsageTrend.isNotEmpty) {
      rows.add(['Feed usage trend (${filter.label})', '']);
      for (final point in data.feedUsageTrend) {
        rows.add([
          reportService.formatDate(point.date),
          reportService.formatQuantities(point.usageByUnit),
        ]);
      }
    }

    return ReportExportPayload(
      reportTitle: 'Feed Analytics',
      periodLabel: filter.label,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(
      feedAnalyticsProvider(_selectedFilter),
    );

    final feedData = feedState.data;
    final canExport = feedData != null && _feedAnalyticsHasData(feedData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Analytics'),
        actions: [
          buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (feedData == null || !_feedAnalyticsHasData(feedData)) {
                return;
              }
              final payload =
                  _buildFeedAnalyticsExportPayload(feedData, _selectedFilter);
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
          feedState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : feedData == null
                  ? buildEmptyState(context, 'Could not load feed analytics.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FeedMetricCard(
                          title: 'Feed used in ${_selectedFilter.label}',
                          value: _emptyAwareQuantities(
                            feedData.feedUsedInSelectedPeriodByUnit,
                          ),
                          isEmpty:
                              feedData.feedUsedInSelectedPeriodByUnit.isEmpty,
                        ),
                        const SizedBox(height: 8),
                        FeedMetricCard(
                          title: 'Remaining feed stock (Current Snapshot)',
                          value: _emptyAwareQuantities(
                              feedData.remainingFeedStockByUnit),
                          isEmpty: feedData.remainingFeedStockByUnit.isEmpty,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Feed usage by flock (${_selectedFilter.label})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (feedData.feedUsageByFlock.isEmpty)
                          buildEmptyState(context, 'Not recorded yet')
                        else
                          Column(
                            children: feedData.feedUsageByFlock.map((row) {
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
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ),
                                        Text(
                                          row.usedKg == null
                                              ? 'Not recorded yet'
                                              : '${row.usedKg!.toStringAsFixed(1)} kg',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (feedData.feedUsageTrend.isEmpty)
                          buildEmptyState(context, 'Not recorded yet')
                        else
                          Column(
                            children: feedData.feedUsageTrend.map((point) {
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
                                            reportService
                                                .formatDate(point.date),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ),
                                        Text(
                                          reportService.formatQuantities(
                                              point.usageByUnit),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
        ],
      ),
    );
  }
}
