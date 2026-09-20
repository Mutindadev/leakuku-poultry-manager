import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/progress/domain/service/progress_service.dart';
import 'package:leakuku/features/reports/data/models/upcoming_vaccination.dart';

class FarmPlan extends ConsumerStatefulWidget {
  final int selectedIndex;
  final List<FlockModel> flocks;
  final UpcomingVaccination? nextVaccination;
  final ValueChanged<int> onIndexChanged;
  final double totalaDailyFeed;

  const FarmPlan({
    super.key,
    required this.selectedIndex,
    required this.flocks,
    required this.nextVaccination,
    required this.onIndexChanged,
    required this.totalaDailyFeed,
  });

  @override
  ConsumerState<FarmPlan> createState() => _FarmPlanState();
}

class _FarmPlanState extends ConsumerState<FarmPlan> {
  String _formatFeed(double grams) {
    if (grams >= 1000) {
      return '${(grams / 1000).toStringAsFixed(1)} kg';
    }
    return '${grams.toStringAsFixed(0)} g';
  }

  @override
  Widget build(BuildContext context) {
    final service = const ProgressService();
    final todayChecklist = widget.flocks.isEmpty
        ? const <String, bool>{}
        : service.extractDailyChecklist(
            widget.flocks.first.notes,
            DateTime.now(),
          );

    final planItems = <_PlanItem>[
      if (!(todayChecklist['Feed birds'] ?? false))
        _PlanItem(
          icon: FontAwesomeIcons.bowlFood,
          title: 'Feed birds',
          subtitle: widget.flocks.isEmpty
              ? 'No data yet'
              : 'Prepare ${_formatFeed(widget.totalaDailyFeed)} today',
          color: AppColors.leakukuGreen,
          onTap: () => widget.onIndexChanged(2),
        ),
      if (!(todayChecklist['Refresh water'] ?? false))
        _PlanItem(
          icon: FontAwesomeIcons.droplet,
          title: 'Refresh water',
          subtitle: widget.flocks.isEmpty
              ? 'No data yet'
              : 'Clean drinkers and refill fresh water',
          color: AppColors.informationBlue,
          onTap: () => widget.onIndexChanged(2),
        ),
      if (!(todayChecklist['Observe bird activity'] ?? false))
        _PlanItem(
          icon: FontAwesomeIcons.eye,
          title: 'Observe bird activity',
          subtitle: widget.flocks.isEmpty
              ? 'No data yet'
              : 'Watch appetite, movement, and comfort',
          color: AppColors.leakukuGreen,
          onTap: () => widget.onIndexChanged(2),
        ),
      if (!(todayChecklist['Check litter'] ?? false))
        _PlanItem(
          icon: FontAwesomeIcons.broom,
          title: 'Check litter',
          subtitle: widget.flocks.isEmpty
              ? 'No data yet'
              : 'Remove wet spots and keep the floor dry',
          color: AppColors.softGray,
          onTap: () => widget.onIndexChanged(2),
        ),
      if (!(todayChecklist['Record mortality'] ?? false))
        _PlanItem(
          icon: FontAwesomeIcons.heartPulse,
          title: 'Record mortality',
          subtitle: widget.flocks.isEmpty
              ? 'No data yet'
              : 'Update after morning rounds',
          color: Colors.red,
          onTap: () => widget.onIndexChanged(2),
        ),
      if (!(todayChecklist['Administer scheduled vaccine'] ?? false) &&
          widget.nextVaccination != null)
        _PlanItem(
          icon: FontAwesomeIcons.syringe,
          title: 'Administer scheduled vaccine',
          subtitle: widget.nextVaccination == null
              ? 'No data yet'
              : '${widget.nextVaccination!.vaccineName} · ${widget.nextVaccination!.dueLabel}',
          color: AppColors.harvestGold,
          onTap: () => widget.onIndexChanged(2),
        ),
    ];

    final finalPlanItems = planItems.isEmpty
        ? <_PlanItem>[
            _PlanItem(
              icon: FontAwesomeIcons.checkCircle,
              title: 'Daily checklist complete',
              subtitle: 'Everything is done for today.',
              color: AppColors.leakukuGreen,
              onTap: () => widget.onIndexChanged(2),
            ),
          ]
        : planItems;

    return Column(
      children: finalPlanItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: FaIcon(
                              item.icon,
                              size: 16,
                              color: item.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanItem {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlanItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
