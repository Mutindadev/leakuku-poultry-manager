import 'package:flutter/material.dart';
import 'package:leakuku/features/reports/data/models/flock_performance_data.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';

class PerformanceCard extends StatelessWidget {
  final FlockPerformanceData data;
  final VoidCallback onTap;

  const PerformanceCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                  buildStatusBadge(data.performanceStatus),
                ],
              ),
              const SizedBox(height: 10),
              metricText('Bird count', '${data.birdCount}'),
              const SizedBox(height: 4),
              metricText('Age', formatAge(data.ageDays)),
              const SizedBox(height: 4),
              metricText(
                'Average weight',
                data.averageWeightKg == null
                    ? 'Not recorded yet'
                    : '${data.averageWeightKg!.toStringAsFixed(2)} kg',
                isEmpty: data.averageWeightKg == null,
              ),
              const SizedBox(height: 4),
              metricText(
                'Mortality percentage',
                data.mortalityPercent == null
                    ? 'Not recorded yet'
                    : '${data.mortalityPercent!.toStringAsFixed(1)}%',
                isEmpty: data.mortalityPercent == null,
              ),
              const SizedBox(height: 4),
              metricText(
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
}
