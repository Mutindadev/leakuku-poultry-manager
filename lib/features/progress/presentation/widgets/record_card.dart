import 'package:flutter/material.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/core/widgets/input_widgets.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

class RecordCard extends StatelessWidget {
  final FlockModel flock;
  final WeeklyPlanModel? currentPlan;
  final int ageDays;
  final bool weeklyPlansLoading;
  final TextEditingController feedController;
  final TextEditingController waterRefillsController;
  final TextEditingController healthNotesController;
  final TextEditingController mortalityController;
  final TextEditingController mortalityNotesController;
  final TextEditingController weightController;
  final TextEditingController generalNotesController;
  final String healthStatus;
  final ValueChanged<String> onHealthStatusChanged;

  const RecordCard({
    super.key,
    required this.flock,
    this.currentPlan,
    required this.ageDays,
    required this.weeklyPlansLoading,
    required this.feedController,
    required this.waterRefillsController,
    required this.healthNotesController,
    required this.mortalityController,
    required this.mortalityNotesController,
    required this.weightController,
    required this.generalNotesController,
    required this.healthStatus,
    required this.onHealthStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final recommendedFeedKg = flock.quantity == 0
        ? 0.0
        : (FeedingCalculator.getDailyFoodGrams(flock.breed, ageDays) *
                flock.quantity) /
            1000;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Record',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Record only what changed today so the batch stays accurate.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            if (weeklyPlansLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(color: AppColors.leakukuGreen),
            ],
            const SizedBox(height: 18),
            _buildRecordSection(
              context,
              title: 'Feed',
              helper: currentPlan != null
                  ? 'Recommended today: ${currentPlan?.plannedTotalFeedKg.toStringAsFixed(1)} kg total'
                  : 'Recommended today: ${recommendedFeedKg.toStringAsFixed(1)} kg total',
              child: numberField(
                controller: feedController,
                label: 'Actual feed given (kg)',
                hint: 'Enter total feed given today',
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Water',
              helper: currentPlan != null
                  ? 'Planned water use this week: ${currentPlan?.plannedWaterLiters.toStringAsFixed(1)} L'
                  : 'Record how many times drinkers were refilled today.',
              child: numberField(
                controller: waterRefillsController,
                label: 'Number of water refills',
                hint: 'Enter refills completed today',
                decimals: false,
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Health Check',
              helper: 'Choose the status that best matches the flock today.',
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Healthy', 'Slight concern', 'Needs attention']
                        .map(
                          (status) => ChoiceChip(
                            label: Text(status),
                            selected: healthStatus == status,
                            selectedColor:
                                AppColors.leakukuGreen.withValues(alpha: 0.18),
                            onSelected: (_) {
                              onHealthStatusChanged(status);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  if (healthStatus == 'Needs attention') ...[
                    const SizedBox(height: 12),
                    textField(
                      controller: healthNotesController,
                      label: 'Health notes (optional)',
                      hint: 'Describe what needs attention',
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Mortality',
              helper: 'Saving mortality updates birds alive for this batch.',
              child: Column(
                children: [
                  numberField(
                    controller: mortalityController,
                    label: 'Number of birds lost today',
                    hint: 'Enter birds lost today',
                    decimals: false,
                  ),
                  const SizedBox(height: 12),
                  textField(
                    controller: mortalityNotesController,
                    label: 'Notes (optional)',
                    hint: 'Anything unusual about today\'s losses',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Weight',
              helper: currentPlan != null
                  ? 'Expected weight: ${currentPlan?.plannedBodyWeightKg.toStringAsFixed(2)} kg'
                  : 'Expected weight will appear when the growth plan is available.',
              child: numberField(
                controller: weightController,
                label: 'Actual recorded weight (kg)',
                hint: 'Enter sample or average recorded weight',
              ),
            ),
            _buildRecordSection(
              context,
              title: 'General Notes',
              helper: 'Use this for anything different that happened today.',
              child: textField(
                controller: generalNotesController,
                label: 'Notes (optional)',
                hint:
                    'Cold weather, leftovers, curtain changes, or any unusual event',
                maxLines: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSection(
    BuildContext context, {
    required String title,
    required String helper,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
