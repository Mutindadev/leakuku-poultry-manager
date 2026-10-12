import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/datasources/weekly_plan_local_data_source.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';

void main() {
  late Directory hiveDirectory;
  late Box<List<WeeklyPlanModel>> weeklyPlanBox;
  late WeeklyPlanLocalDataSourceImpl dataSource;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('weekly_plan_test');
    Hive.init(hiveDirectory.path);
    Hive.registerAdapter(WeeklyPlanModelAdapter());
    weeklyPlanBox = await Hive.openBox<List<WeeklyPlanModel>>('weeklyPlanBox');
    dataSource = WeeklyPlanLocalDataSourceImpl(weeklyPlanBox: weeklyPlanBox);
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('returns restored plans in numeric week order', () async {
    await weeklyPlanBox.put('flock-1', [_plan(1), _plan(10), _plan(2)]);

    final plans = await dataSource.getWeeklyPlansForFlock('flock-1');

    expect(plans.map((plan) => plan.weekNumber), [1, 2, 10]);
  });
}

WeeklyPlanModel _plan(int week) {
  return WeeklyPlanModel(
    id: 'flock-1_week$week',
    flockId: 'flock-1',
    weekNumber: week,
    plannedFeedGramsPerBird: 10,
    plannedTotalFeedKg: 1,
    plannedWaterLiters: 2,
    plannedBodyWeightKg: 0.5,
    plannedTemperatureCelsius: 30,
    plannedMortalityPercent: 1,
    weekStartDate: DateTime(2026, 1, 1).add(Duration(days: (week - 1) * 7)),
    updatedAt: DateTime(2026, 1, 1),
  );
}
