import 'package:leakuku/data/models/breed_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/data/datasources/breed_local_data_source.dart';
import 'package:leakuku/data/datasources/weekly_plan_local_data_source.dart';

/// Use case: Auto-generate weekly activity plans when flock is created
class GenerateWeeklyPlanUseCase {
  final BreedLocalDataSource breedDataSource;
  final WeeklyPlanLocalDataSource weeklyPlanDataSource;

  GenerateWeeklyPlanUseCase({
    required this.breedDataSource,
    required this.weeklyPlanDataSource,
  });

  /// Generate and save weekly plans for a new flock
  Future<List<WeeklyPlanModel>> execute({
    required String flockId,
    required String breedId,
    required int flockQuantity,
    required DateTime flockStartDate,
  }) async {
    // 1. Fetch breed profile
    final breed = await breedDataSource.getBreedById(breedId);
    if (breed == null) {
      throw Exception('Breed not found: $breedId');
    }

    // 2. Generate weekly plans using breed defaults
    final plans = await weeklyPlanDataSource.generateWeeklyPlans(
      flockId: flockId,
      breed: breed,
      flockQuantity: flockQuantity,
      flockStartDate: flockStartDate,
    );

    return plans;
  }
}
