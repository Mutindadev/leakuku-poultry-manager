import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class BatchDetailsPage extends ConsumerWidget {
  final FlockModel flock;

  const BatchDetailsPage({super.key, required this.flock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccineSchedule = ref.watch(vaccineScheduleProvider(flock.id));
    final weeklyPlans = ref.watch(weeklyPlansProvider(flock.id));
    final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
    final stage = _getStage(ageDays);

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(
        title: const Text('Batch Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, stage),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Batch Summary'),
            const SizedBox(height: 10),
            weeklyPlans.when(
              data: (plans) => _buildSummaryGrid(context, plans),
              loading: () => _buildSummaryGrid(context, const []),
              error: (_, __) => _buildSummaryGrid(context, const []),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Current Stage'),
            const SizedBox(height: 10),
            _buildStageCard(context, stage),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Today\'s Guidance'),
            const SizedBox(height: 10),
            _buildGuidanceCard(context, stage),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Vaccination Schedule'),
            const SizedBox(height: 10),
            vaccineSchedule.when(
              data: (vaccines) => _buildVaccinationCard(context, vaccines),
              loading: () => _buildLoadingCard(context, 'Loading schedule...'),
              error: (_, __) => _buildLoadingCard(
                context,
                'Vaccination schedule is not available yet.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String stage) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _breedColor(flock.breed).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: _breedIcon(flock.breed),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flock.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.earthCharcoal,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPill(
                        label: flock.breed,
                        foreground: _breedColor(flock.breed),
                        background: _breedColor(flock.breed).withValues(alpha: 0.14),
                      ),
                      _buildPill(
                        label: stage,
                        foreground: AppColors.leakukuGreen,
                        background: AppColors.leakukuGreen.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, List<WeeklyPlanModel> plans) {
    final averageWeight = _resolveAverageWeight(plans);
    final ageLabel = _formatAge(DateTime.now().difference(flock.purchaseDate).inDays);

    final items = [
      _SummaryItem('Batch Name', flock.name, FontAwesomeIcons.tag),
      _SummaryItem('Breed', flock.breed, FontAwesomeIcons.dna),
      _SummaryItem('Birds Received', '${flock.quantity}', FontAwesomeIcons.download),
      const _SummaryItem(
        'Death on Arrival (DOA)',
        'Not recorded yet',
        FontAwesomeIcons.triangleExclamation,
      ),
      _SummaryItem('Birds Alive', '${flock.quantity}', FontAwesomeIcons.heartPulse),
      _SummaryItem('Current Age', ageLabel, FontAwesomeIcons.clockRotateLeft),
      _SummaryItem('Average Weight', averageWeight, FontAwesomeIcons.weightScale),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildStageCard(BuildContext context, String stage) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.harvestGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.seedling,
                  color: AppColors.harvestGold,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stageDescription(stage),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(BuildContext context, String stage) {
    final guidance = _guidanceForStage(stage);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: guidance
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            size: 10,
                            color: AppColors.leakukuGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.earthCharcoal,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(BuildContext context, List<VaccineModel> vaccines) {
    if (vaccines.isEmpty) {
      return _buildLoadingCard(
        context,
        'No vaccinations have been scheduled for this batch yet.',
      );
    }

    final now = DateTime.now();
    final completed = <_VaccineStatus>[];
    final upcoming = <_VaccineStatus>[];

    for (final vaccine in vaccines) {
      final dueDate = flock.purchaseDate.add(
        Duration(days: vaccine.scheduleDayOffset),
      );
      final item = _VaccineStatus(vaccine: vaccine, dueDate: dueDate);
      if (dueDate.isBefore(now)) {
        completed.add(item);
      } else {
        upcoming.add(item);
      }
    }

    completed.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    upcoming.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVaccinationGroup(
              context,
              title: 'Completed',
              emptyLabel: 'No completed vaccinations yet.',
              items: completed,
              icon: FontAwesomeIcons.circleCheck,
              color: AppColors.leakukuGreen,
            ),
            const SizedBox(height: 16),
            _buildVaccinationGroup(
              context,
              title: 'Upcoming',
              emptyLabel: 'No upcoming vaccinations yet.',
              items: upcoming,
              icon: FontAwesomeIcons.clock,
              color: AppColors.harvestGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationGroup(
    BuildContext context, {
    required String title,
    required String emptyLabel,
    required List<_VaccineStatus> items,
    required FaIconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          )
        else
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vaccine.vaccineName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.vaccine.disease,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(item.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context, String label) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.earthCharcoal,
          ),
    );
  }

  Widget _buildPill({
    required String label,
    required Color foreground,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getStage(int ageDays) {
    if (ageDays <= 21) {
      return 'Brooding';
    }
    if (ageDays <= 140) {
      return 'Growing';
    }
    return 'Production';
  }

  String _stageDescription(String stage) {
    switch (stage) {
      case 'Brooding':
        return 'Keep the young birds warm, dry, and active.';
      case 'Growing':
        return 'Support steady growth with clean water and close observation.';
      default:
        return 'Maintain good routine so the batch stays productive and stable.';
    }
  }

  List<String> _guidanceForStage(String stage) {
    switch (stage) {
      case 'Brooding':
        return const [
          'Maintain brooder temperature.',
          'Replace wet litter.',
          'Clean drinkers.',
          'Observe bird activity.',
          'Check that feed is easy to reach.',
        ];
      case 'Growing':
        return const [
          'Clean drinkers.',
          'Observe bird activity.',
          'Weigh sample birds.',
          'Refresh feeders and remove waste feed.',
          'Walk through the house and remove wet spots.',
        ];
      default:
        return const [
          'Observe bird activity.',
          'Clean drinkers.',
          'Weigh sample birds.',
          'Check feed intake against the plan.',
          'Monitor comfort and keep litter dry.',
        ];
    }
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

  String _resolveAverageWeight(List<WeeklyPlanModel> plans) {
    if (plans.isEmpty) {
      return 'Not recorded yet';
    }

    final sortedPlans = [...plans]
      ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    final latestPlan = sortedPlans.last;
    final weight = latestPlan.actualBodyWeightKg ?? latestPlan.plannedBodyWeightKg;

    if (weight <= 0) {
      return 'Not recorded yet';
    }

    return '${weight.toStringAsFixed(weight < 10 ? 1 : 0)} kg';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _breedColor(String breed) {
    switch (breed) {
      case 'Layers':
        return AppColors.leakukuGreen;
      case 'Broilers':
        return Colors.orange;
      case 'Improved Kienyeji':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _breedIcon(String breed) {
    switch (breed) {
      case 'Layers':
        return const FaIcon(
          FontAwesomeIcons.egg,
          color: AppColors.leakukuGreen,
          size: 24,
        );
      case 'Broilers':
        return const Text('🍗', style: TextStyle(fontSize: 24));
      case 'Improved Kienyeji':
        return const Text('🐔', style: TextStyle(fontSize: 24));
      default:
        return const FaIcon(
          FontAwesomeIcons.question,
          color: Colors.grey,
          size: 24,
        );
    }
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final FaIconData icon;

  const _SummaryItem(this.label, this.value, this.icon);
}

class _VaccineStatus {
  final VaccineModel vaccine;
  final DateTime dueDate;

  const _VaccineStatus({required this.vaccine, required this.dueDate});
}