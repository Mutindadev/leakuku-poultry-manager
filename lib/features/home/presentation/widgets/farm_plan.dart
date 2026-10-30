import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/progress/domain/service/progress_service.dart';
import 'package:leakuku/features/progress/presentation/providers/daily_tasks_provider.dart';

class FarmPlan extends ConsumerWidget {
  const FarmPlan({
    super.key,
    required this.flocks,
    required this.onIndexChanged,
  });

  final List<FlockModel> flocks;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const service = ProgressService();
    final planItems = <_PlanItem>[];

    for (final flock in flocks) {
      final completedTasks =
          service.extractDailyChecklist(flock.notes, DateTime.now());
      for (final task in ref.watch(dailyTasksForFlockProvider(flock))) {
        if (completedTasks[task.title] ?? false) continue;
        planItems.add(
          _PlanItem(
            icon: task.icon,
            title: task.title,
            subtitle: task.subtitle == null
                ? flock.name
                : '${flock.name} · ${task.subtitle}',
            color: task.color,
          ),
        );
      }
    }

    if (planItems.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(
            Icons.check_circle_outline,
            color: AppColors.leakukuGreen,
          ),
          title: Text(
            flocks.isEmpty
                ? 'Add a flock to see daily tasks'
                : 'No active tasks for today',
          ),
          subtitle: flocks.isEmpty
              ? const Text('Your daily plan will appear here.')
              : null,
        ),
      );
    }

    return Column(
      children: [
        for (final item in planItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: InkWell(
                onTap: () => onIndexChanged(2),
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
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.softGray),
                            ),
                          ],
                        ),
                      ),
                      const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
                        color: AppColors.softGray,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanItem {
  const _PlanItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
