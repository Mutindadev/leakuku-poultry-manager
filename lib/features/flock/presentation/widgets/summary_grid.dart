import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/data/models/summary_item.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

class SummaryGrid extends StatelessWidget {
  final List<WeeklyPlanModel> plans;
  final FlockModel flock;

  const SummaryGrid({
    super.key,
    required this.plans,
    required this.flock,
  });

  String _resolveAverageWeight(List<WeeklyPlanModel> plans) {
    if (plans.isEmpty) {
      return 'Not recorded yet';
    }

    final sortedPlans = [...plans]
      ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    final latestPlan = sortedPlans.last;
    final weight =
        latestPlan.actualBodyWeightKg ?? latestPlan.plannedBodyWeightKg;

    if (weight <= 0) {
      return 'Not recorded yet';
    }

    return '${weight.toStringAsFixed(weight < 10 ? 1 : 0)} kg';
  }

  String _formatAge(int ageDays) {
    if (ageDays < 7) {
      return '$ageDays day${ageDays == 1 ? '' : 's'}';
    }
    if (ageDays < 30) {
      final weeks = (ageDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'}';
    }
    final months = (ageDays / 30).floor();
    if (months < 12) {
      return '$months month${months == 1 ? '' : 's'}';
    }
    final years = (ageDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final averageWeight = _resolveAverageWeight(plans);
    final ageLabel =
        _formatAge(DateTime.now().difference(flock.purchaseDate).inDays);

    final items = [
      SummaryItem('Batch Name', flock.name, FontAwesomeIcons.tag),
      SummaryItem('Breed', flock.breed, FontAwesomeIcons.dna),
      SummaryItem(
          'Birds Received', '${flock.quantity}', FontAwesomeIcons.download),
      const SummaryItem(
        'Death on Arrival (DOA)',
        'Not recorded yet',
        FontAwesomeIcons.triangleExclamation,
      ),
      SummaryItem(
          'Birds Alive', '${flock.quantity}', FontAwesomeIcons.heartPulse),
      SummaryItem('Current Age', ageLabel, FontAwesomeIcons.clockRotateLeft),
      SummaryItem(
          'Average Weight', averageWeight, FontAwesomeIcons.weightScale),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 165,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.leakukuGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: FaIcon(
                            item.icon,
                            size: 14,
                            color: AppColors.leakukuGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.earthCharcoal,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
