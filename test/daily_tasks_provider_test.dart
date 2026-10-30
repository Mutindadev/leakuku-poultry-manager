import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/progress/data/models/daily_task.dart';
import 'package:leakuku/features/progress/data/models/daily_task_config.dart';
import 'package:leakuku/features/progress/presentation/providers/daily_tasks_provider.dart';

void main() {
  test('applies built-in toggles and custom task scope per flock', () {
    final builtInTasks = [
      const DailyTask(
        id: 'feed_birds',
        title: 'Feed birds',
        icon: FontAwesomeIcons.wheatAwn,
        color: AppColors.leakukuGreen,
      ),
    ];
    final configurations = [
      DailyTaskConfig(
        id: builtInTaskConfigId('feed_birds'),
        userId: 'farmer-1',
        title: 'Feed birds',
        isCustom: false,
        isEnabled: false,
        updatedAt: DateTime(2026),
      ),
      DailyTaskConfig(
        id: 'custom-farm',
        userId: 'farmer-1',
        title: 'Collect eggs',
        isCustom: true,
        isEnabled: true,
        updatedAt: DateTime(2026),
      ),
      DailyTaskConfig(
        id: 'custom-flock-1',
        userId: 'farmer-1',
        title: 'Inspect nest boxes',
        flockId: 'flock-1',
        isCustom: true,
        isEnabled: true,
        updatedAt: DateTime(2026),
      ),
    ];

    final flockOneTasks = applyDailyTaskConfigurations(
      builtInTasks: builtInTasks,
      configurations: configurations,
      flockId: 'flock-1',
    );
    final flockTwoTasks = applyDailyTaskConfigurations(
      builtInTasks: builtInTasks,
      configurations: configurations,
      flockId: 'flock-2',
    );

    expect(flockOneTasks.map((task) => task.id), [
      'custom-farm',
      'custom-flock-1',
    ]);
    expect(flockTwoTasks.map((task) => task.id), ['custom-farm']);
  });
}
