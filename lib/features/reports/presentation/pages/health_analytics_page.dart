import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/features/reports/data/models/health_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/providers/health_analytics.dart';
import 'package:leakuku/features/reports/presentation/widgets/health/cards.dart';

class HealthAnalyticsPage extends ConsumerStatefulWidget {
  final ReportFilter initialFilter;

  const HealthAnalyticsPage({super.key, required this.initialFilter});

  @override
  ConsumerState<HealthAnalyticsPage> createState() =>
      _HealthAnalyticsPageState();
}

class _HealthAnalyticsPageState extends ConsumerState<HealthAnalyticsPage> {
  late ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  bool _healthAnalyticsHasData(HealthAnalyticsData data) {
    return data.hasMortalityRecords ||
        data.hasVaccinationRecords ||
        data.treatmentsRecorded > 0 ||
        data.flockHealth.isNotEmpty;
  }

  ReportExportPayload _buildHealthAnalyticsExportPayload(
    HealthAnalyticsData data,
    ReportFilter filter,
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
        data.totalBirdLosses == null
            ? 'No mortality records yet.'
            : '${data.totalBirdLosses}',
      ],
      [
        'Vaccinations completed (Current Snapshot)',
        '${data.vaccinationsCompleted}'
      ],
      ['Vaccinations due (Current Snapshot)', '${data.vaccinationsDue}'],
      [
        'Upcoming vaccinations (Current Snapshot)',
        '${data.vaccinationsUpcoming}'
      ],
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

    return ReportExportPayload(
      reportTitle: 'Health Analytics',
      periodLabel: filter.label,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthAnalyticsProvider(_selectedFilter));
    final healthData = healthState.data;
    final canExport = healthData != null && _healthAnalyticsHasData(healthData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analytics'),
        actions: [
          buildReportExportAction(
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
          healthState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : healthData == null
                  ? buildEmptyState(
                      context,
                      'Could not load health analytics.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHealthOverviewCard(context, healthData),
                        const SizedBox(height: 12),
                        Text(
                          'Flock health snapshot',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (healthData.flockHealth.isEmpty)
                          buildEmptyState(context, 'Not recorded yet')
                        else
                          Column(
                            children: healthData.flockHealth.map((flock) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                            ),
                                            buildStatusBadge(flock.status),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        metricText(
                                            'Bird count', '${flock.birdCount}'),
                                        const SizedBox(height: 4),
                                        metricText(
                                          'Recorded losses',
                                          '${flock.recordedLosses}',
                                        ),
                                        const SizedBox(height: 4),
                                        metricText(
                                          'Mortality percentage',
                                          flock.mortalityPercent == null
                                              ? 'No mortality records yet.'
                                              : '${flock.mortalityPercent!.toStringAsFixed(1)}%',
                                          isEmpty:
                                              flock.mortalityPercent == null,
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        buildMortalityCard(
                            context, healthData, _selectedFilter),
                        const SizedBox(height: 12),
                        Text(
                          'Vaccination analytics',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        buildVaccinationCard(context, healthData),
                        const SizedBox(height: 12),
                        Text(
                          'Treatment analytics',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        buildTreatmentCard(
                            context, healthData, _selectedFilter),
                        const SizedBox(height: 12),
                        Text(
                          'Health insights',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        buildHealthInsightsCard(context, healthData),
                      ],
                    ),
        ],
      ),
    );
  }
}
