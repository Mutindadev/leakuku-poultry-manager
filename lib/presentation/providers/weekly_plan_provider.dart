import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/data/datasources/weekly_plan_local_data_source.dart';

/// Provider for weekly plan data source
final weeklyPlanDataSourceProvider = Provider<WeeklyPlanLocalDataSource>((ref) {
  final weeklyPlanBox = Hive.box<List<dynamic>>('weeklyPlanBox');
  return WeeklyPlanLocalDataSourceImpl(weeklyPlanBox: weeklyPlanBox);
});

/// Provider for weekly plans of a specific flock
final weeklyPlansProvider = FutureProvider.family<List<WeeklyPlanModel>, String>((ref, flockId) async {
  final dataSource = ref.read(weeklyPlanDataSourceProvider);
  return await dataSource.getWeeklyPlansForFlock(flockId);
});
