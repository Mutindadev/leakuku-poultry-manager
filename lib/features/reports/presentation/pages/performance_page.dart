import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/flock_performance_data.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/presentation/pages/performance_detail_page.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/providers/flock_performance.dart';
import 'package:leakuku/features/reports/presentation/widgets/performance/performance_card.dart';

class PerformancePage extends ConsumerStatefulWidget {
  final ReportFilter initialFilter;

  const PerformancePage({super.key, required this.initialFilter});

  @override
  ConsumerState<PerformancePage> createState() => _FlockPerformancePageState();
}

class _FlockPerformancePageState extends ConsumerState<PerformancePage> {
  late ReportFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  ReportExportPayload _buildFlockPerformanceExportPayload(
    List<FlockPerformanceData> flocks,
    ReportFilter filter,
  ) {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Reporting Period', filter.label],
    ];

    for (final flock in flocks) {
      rows.add(['Flock', flock.flockName]);
      rows.add(['Bird count (Current Snapshot)', '${flock.birdCount}']);
      rows.add(['Age (Current Snapshot)', formatAge(flock.ageDays)]);
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

    return ReportExportPayload(
      reportTitle: 'Flock Performance',
      periodLabel: filter.label,
      rows: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final performanceState = ref.watch(
      flockPerformanceProvider(_selectedFilter),
    );

    final flockData = performanceState.data;
    final canExport = flockData.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flock Performance'),
        actions: [
          buildReportExportAction(
            context,
            enabled: canExport,
            onActionSelected: (action) async {
              if (flockData.isEmpty) {
                return;
              }
              final payload = _buildFlockPerformanceExportPayload(
                  flockData, _selectedFilter);
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
          if (performanceState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.leakukuGreen),
              ),
            )
          else if (performanceState.error != null)
            buildEmptyState(
              context,
              'Could not load flock performance.\n${performanceState.error}',
            )
          else if (flockData.isEmpty)
            buildEmptyState(context, 'Not recorded yet')
          else
            Column(
              children: flockData.map((flock) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PerformanceCard(
                    data: flock,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PerformanceDetailPage(
                            data: flock,
                            filter: _selectedFilter,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
