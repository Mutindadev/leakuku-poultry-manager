import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/core/widgets/loading_card.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/widgets/guidance_card.dart';
import 'package:leakuku/features/flock/presentation/widgets/stage_card.dart';
import 'package:leakuku/features/flock/presentation/widgets/summary_grid.dart';
import 'package:leakuku/features/flock/presentation/widgets/vaccination_card.dart';
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
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/stock'),
            icon: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              'View Stock',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
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
              data: (plans) => SummaryGrid(plans: plans, flock: flock),
              loading: () => SummaryGrid(plans: const [], flock: flock),
              error: (_, __) => SummaryGrid(plans: const [], flock: flock),
              // loading: () => _buildSummaryGrid(context, const []),
              // error: (_, __) => _buildSummaryGrid(context, const []),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Current Stage'),
            const SizedBox(height: 10),
            // _buildStageCard(context, stage),
            StageCard(stage: stage),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Today\'s Guidance'),
            const SizedBox(height: 10),
            // _buildGuidanceCard(context, stage),
            GuidanceCard(stage: stage),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Vaccination Schedule'),
            const SizedBox(height: 10),
            vaccineSchedule.when(
              data: (vaccines) =>
                  VaccinationCard(vaccines: vaccines, flock: flock),
              loading: () => const LoadingCard(label: 'Loading schedule...'),
              error: (_, __) => const LoadingCard(
                  label: 'Vaccination schedule is not available yet.'),
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
                        background:
                            _breedColor(flock.breed).withValues(alpha: 0.14),
                      ),
                      _buildPill(
                        label: stage,
                        foreground: AppColors.leakukuGreen,
                        background:
                            AppColors.leakukuGreen.withValues(alpha: 0.12),
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
