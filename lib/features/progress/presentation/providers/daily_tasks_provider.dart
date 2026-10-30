import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/progress/data/models/daily_task.dart';
import 'package:leakuku/features/progress/data/models/daily_task_config.dart';
import 'package:leakuku/features/progress/domain/service/progress_service.dart';
import 'package:leakuku/features/progress/presentation/providers/daily_task_catalog_provider.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

final dailyTasksForFlockProvider =
    Provider.family<List<DailyTask>, FlockModel>((ref, flock) {
  const service = ProgressService();
  final today = DateTime.now();
  final ageDays = today.difference(flock.purchaseDate).inDays;
  final currentWeek = ageDays < 0 ? 1 : (ageDays ~/ 7) + 1;
  final plans = ref.watch(weeklyPlansProvider(flock.id)).maybeWhen(
        data: (value) => value,
        orElse: () => const <WeeklyPlanModel>[],
      );
  final vaccines = ref.watch(vaccineScheduleProvider(flock.id)).maybeWhen(
        data: (value) => value,
        orElse: () => const [],
      );
  final userId = ref.watch(userProvider).userModel?.uid;
  final configurations = userId == null
      ? const <DailyTaskConfig>[]
      : ref.watch(dailyTaskCatalogProvider(userId)).configurations;
  final tasks = service.buildTasks(
    stage: service.getStage(ageDays),
    currentPlan: service.findCurrentPlan(plans, currentWeek),
    dueVaccinesToday:
        service.dueVaccinesToday(flock.purchaseDate, vaccines, now: today),
  );

  return applyDailyTaskConfigurations(
    builtInTasks: tasks,
    configurations: configurations,
    flockId: flock.id,
  );
});

List<DailyTask> applyDailyTaskConfigurations({
  required List<DailyTask> builtInTasks,
  required List<DailyTaskConfig> configurations,
  required String flockId,
}) {
  final disabledTaskIds = configurations
      .where((config) => !config.isEnabled)
      .map((config) => config.id)
      .toSet();

  return [
    ...builtInTasks.where(
      (task) => !disabledTaskIds.contains(builtInTaskConfigId(task.id)),
    ),
    ...configurations
        .where(
          (config) =>
              config.isCustom && config.isEnabled && config.appliesTo(flockId),
        )
        .map(
          (config) => DailyTask(
            id: config.id,
            title: config.title,
            subtitle: config.description,
            icon: FontAwesomeIcons.listCheck,
            color: AppColors.harvestGold,
          ),
        ),
  ];
}
