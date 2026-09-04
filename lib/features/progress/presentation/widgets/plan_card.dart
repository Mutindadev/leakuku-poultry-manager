import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/progress/data/models/daily_task.dart';

class PlanCard extends StatelessWidget {
  final String flockId;
  final List<DailyTask> tasks;
  final Map<String, bool> taskState;
  final ValueChanged<Map<String, bool>> onTaskStateChanged;

  const PlanCard({
    super.key,
    required this.flockId,
    required this.tasks,
    required this.taskState,
    required this.onTaskStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow the checklist and mark each job as you complete it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            ...tasks.map(
              (task) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.farmCream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CheckboxListTile(
                  value: taskState[task.title] ?? false,
                  onChanged: (value) {
                    // setState(() {
                    //   final flockTasks =
                    //       _taskStateByFlock[widget.flockId] ?? <String, bool>{};
                    //   flockTasks[task.title] = value ?? false;
                    //   _taskStateByFlock[widget.flockId] = flockTasks;
                    // });

                    final updatedTaskState = Map<String, bool>.from(taskState)
                      ..[task.title] = value ?? false;

                    onTaskStateChanged(updatedTaskState);
                  },
                  activeColor: AppColors.leakukuGreen,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  title: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: (taskState[task.title] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  subtitle: task.subtitle == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(task.subtitle!),
                        ),
                  secondary: FaIcon(task.icon, color: task.color, size: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
