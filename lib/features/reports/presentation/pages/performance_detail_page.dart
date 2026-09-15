import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/flock_performance_data.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class PerformanceDetailPage extends ConsumerWidget {
  final FlockPerformanceData data;
  final ReportFilter filter;

  const PerformanceDetailPage({
    super.key,
    required this.data,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const reportService = ReportService();
    final plansAsync = ref.watch(weeklyPlansProvider(data.flockId));
    final boundary = reportService.getBoundary(filter);

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
                  metricText('Bird count', '${data.birdCount}'),
                  const SizedBox(height: 8),
                  metricText('Age', formatAge(data.ageDays)),
                  const SizedBox(height: 8),
                  metricText(
                    'Average weight',
                    data.averageWeightKg == null
                        ? 'Not recorded yet'
                        : '${data.averageWeightKg!.toStringAsFixed(2)} kg',
                    isEmpty: data.averageWeightKg == null,
                  ),
                  const SizedBox(height: 8),
                  metricText(
                    'Mortality percentage',
                    data.mortalityPercent == null
                        ? 'Not recorded yet'
                        : '${data.mortalityPercent!.toStringAsFixed(1)}%',
                    isEmpty: data.mortalityPercent == null,
                  ),
                  const SizedBox(height: 8),
                  metricText(
                    'Survival rate',
                    data.survivalRate == null
                        ? 'Not recorded yet'
                        : '${data.survivalRate!.toStringAsFixed(1)}%',
                    isEmpty: data.survivalRate == null,
                  ),
                  const SizedBox(height: 8),
                  metricText('Performance status', data.performanceStatus),
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
                  .where((plan) => reportService.weekOverlapsBoundary(
                        plan.weekStartDate,
                        boundary,
                      ))
                  .toList()
                ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

              final hasAnyActual = visiblePlans.any(
                (plan) =>
                    plan.actualTotalFeedKg != null ||
                    plan.actualBodyWeightKg != null ||
                    plan.actualMortalityPercent != null,
              );

              if (visiblePlans.isEmpty || !hasAnyActual) {
                return buildEmptyState(context, 'Not recorded yet');
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
                            metricText(
                              'Feed used',
                              plan.actualTotalFeedKg == null
                                  ? 'Not recorded yet'
                                  : '${plan.actualTotalFeedKg!.toStringAsFixed(1)} kg',
                              isEmpty: plan.actualTotalFeedKg == null,
                            ),
                            const SizedBox(height: 4),
                            metricText(
                              'Weight',
                              plan.actualBodyWeightKg == null
                                  ? 'Not recorded yet'
                                  : '${plan.actualBodyWeightKg!.toStringAsFixed(2)} kg',
                              isEmpty: plan.actualBodyWeightKg == null,
                            ),
                            const SizedBox(height: 4),
                            metricText(
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
            error: (error, _) => buildEmptyState(
              context,
              'Could not load flock details.\n$error',
            ),
          ),
        ],
      ),
    );
  }
}
