import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/providers/firestore_data_providers.dart';
import 'package:leakuku/data/datasources/weekly_plan_local_data_source.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';

/// Provider for weekly plan data source
final weeklyPlanDataSourceProvider = Provider<WeeklyPlanLocalDataSource>((ref) {
  final weeklyPlanBox = Hive.box<List<WeeklyPlanModel>>('weeklyPlanBox');
  return WeeklyPlanLocalDataSourceImpl(
    weeklyPlanBox: weeklyPlanBox,
    syncQueue: ref.watch(firestoreSyncQueueProvider),
  );
});

/// Provider for weekly plans of a specific flock
final weeklyPlansProvider =
    FutureProvider.family<List<WeeklyPlanModel>, String>((ref, flockId) async {
  final dataSource = ref.read(weeklyPlanDataSourceProvider);
  return await dataSource.getWeeklyPlansForFlock(flockId);
});
