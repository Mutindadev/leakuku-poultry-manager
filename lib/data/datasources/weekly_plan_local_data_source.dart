import 'package:hive/hive.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/data/models/breed_model.dart';

/// Local data source for weekly activity plans (Hive-backed)
abstract class WeeklyPlanLocalDataSource {
  /// Get all weekly plans for a specific flock
  Future<List<WeeklyPlanModel>> getWeeklyPlansForFlock(String flockId);
  
  /// Get a specific week's plan
  Future<WeeklyPlanModel?> getWeekPlan(String flockId, int weekNumber);
  
  /// Auto-generate weekly plans for a flock based on breed defaults
  Future<List<WeeklyPlanModel>> generateWeeklyPlans({
    required String flockId,
    required BreedModel breed,
    required int flockQuantity,
    required DateTime flockStartDate,
  });
  
  /// Update actual values for a specific week (farmer input)
  Future<void> updateWeekActuals(WeeklyPlanModel updatedPlan);
  
  /// Delete all plans for a flock (when flock deleted)
  Future<void> deleteWeeklyPlans(String flockId);
}

class WeeklyPlanLocalDataSourceImpl implements WeeklyPlanLocalDataSource {
  final Box<List<dynamic>> _weeklyPlanBox; // Store List<WeeklyPlanModel> per flockId

  WeeklyPlanLocalDataSourceImpl({required Box<List<dynamic>> weeklyPlanBox})
      : _weeklyPlanBox = weeklyPlanBox;

  @override
  Future<List<WeeklyPlanModel>> getWeeklyPlansForFlock(String flockId) async {
    if (!Hive.isBoxOpen('weeklyPlanBox')) {
      throw Exception('Weekly plan box not initialized');
    }
    
    final rawList = _weeklyPlanBox.get(flockId);
    if (rawList == null) return [];
    
    return rawList.whereType<WeeklyPlanModel>().toList();
  }

  @override
  Future<WeeklyPlanModel?> getWeekPlan(String flockId, int weekNumber) async {
    final plans = await getWeeklyPlansForFlock(flockId);
    try {
      return plans.firstWhere((p) => p.weekNumber == weekNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WeeklyPlanModel>> generateWeeklyPlans({
    required String flockId,
    required BreedModel breed,
    required int flockQuantity,
    required DateTime flockStartDate,
  }) async {
    if (!Hive.isBoxOpen('weeklyPlanBox')) {
      throw Exception('Weekly plan box not initialized');
    }

    final totalWeeks = breed.cycleDurationWeeks;
    final plans = <WeeklyPlanModel>[];

    for (int week = 1; week <= totalWeeks; week++) {
      // Get feed grams per bird for this week (fallback to default if not in map)
      final feedGramsPerBird = breed.weeklyFeedGrams[week] ?? breed.defaultFeedGramsPerWeek;
      
      // Get expected body weight for this week (interpolate if missing)
      final bodyWeightKg = _getExpectedWeight(breed, week);
      
      // Calculate planned totals
      final totalFeedKg = (feedGramsPerBird * flockQuantity) / 1000; // Convert to kg
      final waterLiters = (feedGramsPerBird * flockQuantity * 2.5) / 1000; // Water = feed * 2.5, convert ml to liters
      
      // Temperature targets (decrease over weeks for broilers, stable for layers)
      final temperatureCelsius = _getTemperatureTarget(breed, week);
      
      // Baseline mortality (start low, slight increase over time)
      final mortalityPercent = _getMortalityBaseline(breed, week);
      
      // Week start date
      final weekStartDate = flockStartDate.add(Duration(days: (week - 1) * 7));

      final plan = WeeklyPlanModel(
        id: '${flockId}_week$week',
        flockId: flockId,
        weekNumber: week,
        plannedFeedGramsPerBird: feedGramsPerBird,
        plannedTotalFeedKg: totalFeedKg,
        plannedWaterLiters: waterLiters,
        plannedBodyWeightKg: bodyWeightKg,
        plannedTemperatureCelsius: temperatureCelsius,
        plannedMortalityPercent: mortalityPercent,
        weekStartDate: weekStartDate,
      );

      plans.add(plan);
    }

    // Save to Hive
    await _weeklyPlanBox.put(flockId, plans);
    
    return plans;
  }

  @override
  Future<void> updateWeekActuals(WeeklyPlanModel updatedPlan) async {
    if (!Hive.isBoxOpen('weeklyPlanBox')) {
      throw Exception('Weekly plan box not initialized');
    }

    final plans = await getWeeklyPlansForFlock(updatedPlan.flockId);
    final index = plans.indexWhere((p) => p.weekNumber == updatedPlan.weekNumber);
    
    if (index == -1) {
      throw Exception('Week plan not found');
    }

    plans[index] = updatedPlan;
    await _weeklyPlanBox.put(updatedPlan.flockId, plans);
  }

  @override
  Future<void> deleteWeeklyPlans(String flockId) async {
    if (!Hive.isBoxOpen('weeklyPlanBox')) {
      throw Exception('Weekly plan box not initialized');
    }
    
    await _weeklyPlanBox.delete(flockId);
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER METHODS (Business Logic)
  // ─────────────────────────────────────────────────────────────

  /// Get expected body weight for a week (interpolate if missing from breed data)
  double _getExpectedWeight(BreedModel breed, int week) {
    if (breed.weeklyExpectedWeight.containsKey(week)) {
      return breed.weeklyExpectedWeight[week]!;
    }

    // Interpolate between known values
    final sortedWeeks = breed.weeklyExpectedWeight.keys.toList()..sort();
    
    // Find surrounding weeks
    int? lowerWeek;
    int? upperWeek;
    
    for (int w in sortedWeeks) {
      if (w < week) lowerWeek = w;
      if (w > week && upperWeek == null) upperWeek = w;
    }

    if (lowerWeek != null && upperWeek != null) {
      final lowerWeight = breed.weeklyExpectedWeight[lowerWeek]!;
      final upperWeight = breed.weeklyExpectedWeight[upperWeek]!;
      final ratio = (week - lowerWeek) / (upperWeek - lowerWeek);
      return lowerWeight + (upperWeight - lowerWeight) * ratio;
    }

    // Fallback: use last known weight or estimate
    if (sortedWeeks.isNotEmpty) {
      return breed.weeklyExpectedWeight[sortedWeeks.last]!;
    }
    
    return 1.0; // Default fallback
  }

  /// Get temperature target based on breed and week
  double _getTemperatureTarget(BreedModel breed, int week) {
    // Broilers: Start hot (32°C), decrease weekly
    if (breed.id == 'broilers') {
      return (32 - (week - 1) * 2).clamp(21, 32).toDouble();
    }
    
    // Layers/Kenbro: Start warm (30°C), stabilize at 21°C
    if (week <= 4) {
      return (30 - (week - 1) * 2).clamp(21, 30).toDouble();
    }
    
    return 21.0; // Ambient temp for mature birds
  }

  /// Get baseline mortality percentage (increases slightly over cycle)
  double _getMortalityBaseline(BreedModel breed, int week) {
    // Start at 1%, increase by 0.2% per week (max 3%)
    final baselineMortality = 1.0 + (week * 0.2);
    return baselineMortality.clamp(1.0, 3.0);
  }
}
