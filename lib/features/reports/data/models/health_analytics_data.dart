import 'package:leakuku/features/reports/data/models/flock_health_snapshot.dart';
import 'package:leakuku/features/reports/data/models/upcoming_vaccination.dart';
import 'package:leakuku/features/reports/data/models/weekly_mortality_record.dart';

class HealthAnalyticsData {
  final String overallStatus;
  final double? mortalityPercent;
  final int? totalBirdLosses;
  final int? mortalityInSelectedPeriod;
  final int vaccinationsCompleted;
  final int vaccinationsDue;
  final int vaccinationsUpcoming;
  final List<UpcomingVaccination> upcomingVaccinations;
  final int treatmentsRecorded;
  final int treatmentsInSelectedPeriod;
  final String? mostRecentTreatmentInSelectedPeriod;
  final List<MedicineUsageSummary> medicineUsageInSelectedPeriod;
  final List<MortalityTrendPoint> mortalityTrend;
  final List<FlockHealthSnapshot> flockHealth;
  final List<String> insights;
  final bool hasVaccinationRecords;
  final bool hasMortalityRecords;

  const HealthAnalyticsData({
    required this.overallStatus,
    required this.mortalityPercent,
    required this.totalBirdLosses,
    required this.mortalityInSelectedPeriod,
    required this.vaccinationsCompleted,
    required this.vaccinationsDue,
    required this.vaccinationsUpcoming,
    required this.upcomingVaccinations,
    required this.treatmentsRecorded,
    required this.treatmentsInSelectedPeriod,
    required this.mostRecentTreatmentInSelectedPeriod,
    required this.medicineUsageInSelectedPeriod,
    required this.mortalityTrend,
    required this.flockHealth,
    required this.insights,
    required this.hasVaccinationRecords,
    required this.hasMortalityRecords,
  });
}

class MedicineUsageSummary {
  final String itemName;
  final String quantityLabel;

  const MedicineUsageSummary({
    required this.itemName,
    required this.quantityLabel,
  });
}
