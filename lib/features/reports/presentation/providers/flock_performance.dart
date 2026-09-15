import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/reports/data/models/flock_performance_data.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class FlockPerformanceState {
  final List<FlockPerformanceData> data;
  final bool isLoading;
  final String? error;

  const FlockPerformanceState({
    this.data = const [],
    this.isLoading = false,
    this.error,
  });

  FlockPerformanceState copyWith({
    List<FlockPerformanceData>? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FlockPerformanceState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FlockPerformanceNotifier extends StateNotifier<FlockPerformanceState> {
  final Ref ref;
  final ReportFilter filter;

  FlockPerformanceNotifier(this.ref, this.filter)
      : super(const FlockPerformanceState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final data = await _loadPerformance();

      state = FlockPerformanceState(
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

  Future<List<FlockPerformanceData>> _loadPerformance() async {
    const reportService = ReportService();

    final flocks = ref.read(flockProvider).flocks;
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final boundary = reportService.getBoundary(filter);
    final items = <FlockPerformanceData>[];

    for (final flock in flocks) {
      final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);

      final weightValues = plans
          .where(
            (plan) =>
                plan.actualBodyWeightKg != null &&
                reportService.weekOverlapsBoundary(
                  plan.weekStartDate,
                  boundary,
                ),
          )
          .map((plan) => plan.actualBodyWeightKg!)
          .toList();

      final mortalityValues = plans
          .where(
            (plan) =>
                plan.actualMortalityPercent != null &&
                reportService.weekOverlapsBoundary(
                  plan.weekStartDate,
                  boundary,
                ),
          )
          .map((plan) => plan.actualMortalityPercent!)
          .toList();

      final averageWeight = weightValues.isEmpty
          ? null
          : weightValues.reduce((a, b) => a + b) / weightValues.length;

      final mortalityPercent = mortalityValues.isEmpty
          ? null
          : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;

      final survivalRate = mortalityPercent == null
          ? null
          : (100 - mortalityPercent).clamp(0, 100).toDouble();

      items.add(
        FlockPerformanceData(
          flockId: flock.id,
          flockName: flock.name,
          birdCount: flock.quantity,
          ageDays: DateTime.now().difference(flock.purchaseDate).inDays,
          averageWeightKg: averageWeight,
          mortalityPercent: mortalityPercent,
          survivalRate: survivalRate,
          performanceStatus: reportService.performanceStatus(
            mortalityPercent: mortalityPercent,
            averageWeightKg: averageWeight,
          ),
        ),
      );
    }

    items.sort(
      (a, b) => a.flockName.compareTo(b.flockName),
    );

    return items;
  }

  // Future CRUD methods can be added here.
}

final flockPerformanceProvider = StateNotifierProvider.family<
    FlockPerformanceNotifier, FlockPerformanceState, ReportFilter>(
  (ref, filter) {
    return FlockPerformanceNotifier(ref, filter);
  },
);
