import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/reports/data/models/flock_health_snapshot.dart';
import 'package:leakuku/features/reports/data/models/health_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/upcoming_vaccination.dart';
import 'package:leakuku/features/reports/data/models/weekly_mortality_record.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class HealthAnalyticsState {
  final HealthAnalyticsData? data;
  final bool isLoading;
  final String? error;

  const HealthAnalyticsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  HealthAnalyticsState copyWith({
    HealthAnalyticsData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HealthAnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class HealthAnalyticsNotifier extends StateNotifier<HealthAnalyticsState> {
  final Ref ref;
  final ReportFilter filter;

  HealthAnalyticsNotifier(this.ref, this.filter)
      : super(const HealthAnalyticsState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final data = await _loadHealthAnalytics();

      state = HealthAnalyticsState(
        data: data,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> refresh() => load();

  Future<HealthAnalyticsData> _loadHealthAnalytics() async {
    final flockState = ref.read(flockProvider);
    final flocks = flockState.flocks;
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final vaccineDataSource = ref.read(vaccineDataSourceProvider);
    final stockItems = await ref.read(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    const reportService = ReportService();

    final todayBoundary = reportService.getBoundary(ReportFilter.today);
    final periodBoundary = reportService.getBoundary(filter);

    final allWeeklyRecords = <WeeklyMortalityRecord>[];
    final flockHealth = <FlockHealthSnapshot>[];

    for (final flock in flocks) {
      final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);
      final records = reportService.reconstructMortalityRecords(
        flockId: flock.id,
        currentBirds: flock.quantity,
        plans: plans,
      );
      allWeeklyRecords.addAll(records);

      final flockLosses =
          records.fold<int>(0, (sum, item) => sum + item.losses);
      final flockBaseline = flock.quantity + flockLosses;
      final flockMortalityPercent =
          flockBaseline == 0 ? null : (flockLosses / flockBaseline) * 100;

      flockHealth.add(
        FlockHealthSnapshot(
          flockName: flock.name,
          birdCount: flock.quantity,
          recordedLosses: flockLosses,
          mortalityPercent: flockMortalityPercent,
          status:
              reportService.healthStatusFromMortality(flockMortalityPercent),
        ),
      );
    }

    flockHealth.sort((a, b) => a.flockName.compareTo(b.flockName));
    final hasMortalityRecords = allWeeklyRecords.isNotEmpty;

    final totalBirdLosses = hasMortalityRecords
        ? allWeeklyRecords.fold<int>(0, (sum, item) => sum + item.losses)
        : null;
    final birdsAlive =
        flocks.fold<int>(0, (sum, flock) => sum + flock.quantity);
    final baselineBirds =
        totalBirdLosses == null ? null : birdsAlive + totalBirdLosses;
    final mortalityPercent =
        (baselineBirds == null || baselineBirds == 0 || totalBirdLosses == null)
            ? null
            : (totalBirdLosses / baselineBirds) * 100;

    final mortalityInSelectedPeriod = hasMortalityRecords
        ? reportService.sumLossesForBoundary(allWeeklyRecords, periodBoundary)
        : null;

    final trendMap = <DateTime, int>{};
    for (final record in allWeeklyRecords) {
      if (!reportService.weekOverlapsBoundary(
          record.weekStartDate, periodBoundary)) {
        continue;
      }
      trendMap[record.weekStartDate] =
          (trendMap[record.weekStartDate] ?? 0) + record.losses;
    }

    final trendKeys = trendMap.keys.toList()..sort();
    final mortalityTrend = trendKeys
        .map(
          (key) => MortalityTrendPoint(
            periodStart: key,
            losses: trendMap[key]!,
          ),
        )
        .toList();

    var vaccinationsCompleted = 0;
    var vaccinationsDue = 0;
    var vaccinationsUpcoming = 0;
    final upcomingVaccinations = <UpcomingVaccination>[];
    var hasVaccinationRecords = false;

    for (final flock in flocks) {
      final vaccines =
          await vaccineDataSource.getVaccineScheduleForFlock(flock.id);
      if (vaccines.isEmpty) {
        continue;
      }
      hasVaccinationRecords = true;

      for (final vaccine in vaccines) {
        final dueDate =
            flock.purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));

        if (dueDate.isBefore(todayBoundary.start)) {
          vaccinationsCompleted++;
          continue;
        }

        if (reportService.isWithin(dueDate, todayBoundary)) {
          vaccinationsDue++;
          continue;
        }

        if (!dueDate.isBefore(todayBoundary.endExclusive)) {
          vaccinationsUpcoming++;
          upcomingVaccinations.add(
            UpcomingVaccination(
              flockName: flock.name,
              vaccineName: vaccine.vaccineName,
              dueDate: dueDate,
            ),
          );
        }
      }
    }

    upcomingVaccinations.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final trimmedUpcoming = upcomingVaccinations.take(5).toList();

    final medicineItems = stockItems.where((item) {
      final category = item.category.toLowerCase();
      return category == 'medicines' || category == 'medicine';
    }).toList();

    final medicineUsedEntries = <Map<String, dynamic>>[];
    final medicineUsedEntriesInSelectedPeriod = <Map<String, dynamic>>[];
    for (final item in medicineItems) {
      final history = await stockDataSource.getItemHistory(item.id);
      for (final entry in history) {
        if (entry.action.toLowerCase() != 'used') {
          continue;
        }
        final map = <String, dynamic>{
          'itemName': entry.itemName,
          'quantity': entry.quantity,
          'unit': entry.unit,
          'date': entry.date,
        };
        medicineUsedEntries.add(map);
        if (reportService.isWithin(entry.date, periodBoundary)) {
          medicineUsedEntriesInSelectedPeriod.add(map);
        }
      }
    }

    medicineUsedEntries.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    medicineUsedEntriesInSelectedPeriod.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    final treatmentsRecorded = medicineUsedEntries.length;
    final treatmentsInSelectedPeriod =
        medicineUsedEntriesInSelectedPeriod.length;
    final mostRecentTreatmentInSelectedPeriod = treatmentsInSelectedPeriod == 0
        ? null
        : '${medicineUsedEntriesInSelectedPeriod.first['itemName']} (${reportService.formatDate(medicineUsedEntriesInSelectedPeriod.first['date'] as DateTime)})';

    final medicineTotalsInSelectedPeriod = <String, Map<String, double>>{};
    for (final entry in medicineUsedEntriesInSelectedPeriod) {
      final itemName = entry['itemName'] as String;
      final unit = entry['unit'] as String;
      final quantity = entry['quantity'] as double;
      final byUnit = medicineTotalsInSelectedPeriod.putIfAbsent(
          itemName, () => <String, double>{});
      reportService.mergeQuantity(byUnit, unit, quantity);
    }

    final medicineUsageInSelectedPeriod =
        medicineTotalsInSelectedPeriod.entries.map((entry) {
      return MedicineUsageSummary(
        itemName: entry.key,
        quantityLabel: reportService.formatQuantities(entry.value),
      );
    }).toList()
          ..sort((a, b) => a.itemName.compareTo(b.itemName));

    final insights = <String>[];
    if (mortalityPercent != null && mortalityPercent <= 2) {
      insights.add('Excellent flock health.');
    }
    if (mortalityInSelectedPeriod != null && mortalityInSelectedPeriod == 0) {
      insights.add('No bird losses recorded in ${filter.label.toLowerCase()}.');
    }
    if (vaccinationsDue > 0) {
      insights.add('Vaccinations are due today.');
    }
    if (mortalityTrend.length >= 2) {
      final latest = mortalityTrend.last.losses;
      final previous = mortalityTrend[mortalityTrend.length - 2].losses;
      if (latest > previous) {
        insights.add('Mortality increased compared to last week.');
      }
    }
    if (treatmentsInSelectedPeriod > 0 &&
        mostRecentTreatmentInSelectedPeriod != null) {
      insights.add(
        'Recent treatment in ${filter.label.toLowerCase()}: '
        '$mostRecentTreatmentInSelectedPeriod.',
      );
    }

    return HealthAnalyticsData(
      overallStatus: reportService.healthStatusFromMortality(mortalityPercent),
      mortalityPercent: mortalityPercent,
      totalBirdLosses: totalBirdLosses,
      mortalityInSelectedPeriod: mortalityInSelectedPeriod,
      vaccinationsCompleted: vaccinationsCompleted,
      vaccinationsDue: vaccinationsDue,
      vaccinationsUpcoming: vaccinationsUpcoming,
      upcomingVaccinations: trimmedUpcoming,
      treatmentsRecorded: treatmentsRecorded,
      treatmentsInSelectedPeriod: treatmentsInSelectedPeriod,
      mostRecentTreatmentInSelectedPeriod: mostRecentTreatmentInSelectedPeriod,
      medicineUsageInSelectedPeriod: medicineUsageInSelectedPeriod,
      mortalityTrend: mortalityTrend,
      flockHealth: flockHealth,
      insights: insights,
      hasVaccinationRecords: hasVaccinationRecords,
      hasMortalityRecords: hasMortalityRecords,
    );
  }
}

final healthAnalyticsProvider = StateNotifierProvider.family<
    HealthAnalyticsNotifier, HealthAnalyticsState, ReportFilter>(
  (ref, filter) {
    return HealthAnalyticsNotifier(ref, filter);
  },
);
