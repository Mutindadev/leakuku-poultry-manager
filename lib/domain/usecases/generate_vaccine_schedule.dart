import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/datasources/vaccine_local_data_source.dart';
import 'package:leakuku/core/services/notification_service.dart';

/// Use case: Auto-generate vaccine schedule and notifications when flock is created
class GenerateVaccineScheduleUseCase {
  final VaccineLocalDataSource vaccineDataSource;
  final NotificationService notificationService;

  GenerateVaccineScheduleUseCase({
    required this.vaccineDataSource,
    required this.notificationService,
  });

  /// Generate vaccine schedule and schedule notifications
  Future<List<VaccineModel>> execute({
    required String flockId,
    required String breedId,
    required DateTime flockStartDate,
  }) async {
    // 1. Get vaccine templates for the breed
    final vaccineTemplates = await vaccineDataSource.getVaccineTemplatesByBreed(breedId);

    if (vaccineTemplates.isEmpty) {
      // No vaccines defined for this breed yet
      return [];
    }

    // 2. Save vaccine schedule to Hive
    await vaccineDataSource.saveVaccineSchedule(flockId, vaccineTemplates);

    // 3. Schedule notifications for each vaccine
    for (final vaccine in vaccineTemplates) {
      final vaccineDayOffset = vaccine.scheduleDayOffset;
      final vaccineDate = flockStartDate.add(Duration(days: vaccineDayOffset));

      // Only schedule future notifications
      if (vaccineDate.isAfter(DateTime.now())) {
        await notificationService.scheduleVaccineReminders(
          flockId: flockId,
          vaccine: vaccine,
          vaccineDate: vaccineDate,
        );
      }
    }

    return vaccineTemplates;
  }
}
