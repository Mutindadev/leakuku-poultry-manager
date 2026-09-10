import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/reports/data/models/feed_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/feed_usage_by_flock.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class FeedAnalyticsState {
  final FeedAnalyticsData? data;
  final bool isLoading;
  final String? error;

  const FeedAnalyticsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  FeedAnalyticsState copyWith({
    FeedAnalyticsData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FeedAnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FeedAnalyticsNotifier
    extends StateNotifier<FeedAnalyticsState> {
  final Ref ref;
  final ReportFilter filter;

  FeedAnalyticsNotifier(this.ref, this.filter)
      : super(const FeedAnalyticsState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final data = await _loadFeedAnalytics();

      state = FeedAnalyticsState(
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

  Future<FeedAnalyticsData> _loadFeedAnalytics() async {
    const reportService = ReportService();

    final flocks = ref.read(flockProvider).flocks;
    final stockItems = await ref.read(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    final periodBoundary = reportService.getBoundary(filter);

    final feedItems = stockItems
        .where((item) => item.category.toLowerCase() == 'feed')
        .toList();

    final remainingFeedStockByUnit = <String, double>{};

    for (final item in feedItems) {
      if (item.quantity <= 0) {
        continue;
      }

      reportService.mergeQuantity(
        remainingFeedStockByUnit,
        item.unit,
        item.quantity,
      );
    }

    final feedHistoryLists = await Future.wait(
      feedItems.map(
        (item) => stockDataSource.getItemHistory(item.id),
      ),
    );

    final feedUsedInSelectedPeriodByUnit = <String, double>{};
    final trendByDate = <DateTime, Map<String, double>>{};

    for (final histories in feedHistoryLists) {
      for (final entry in histories) {
        if (entry.action.toLowerCase() != 'used' ||
            !reportService.isWithin(entry.date, periodBoundary)) {
          continue;
        }

        reportService.mergeQuantity(
          feedUsedInSelectedPeriodByUnit,
          entry.unit,
          entry.quantity,
        );

        final day = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );

        final dayMap = trendByDate.putIfAbsent(
          day,
          () => <String, double>{},
        );

        reportService.mergeQuantity(
          dayMap,
          entry.unit,
          entry.quantity,
        );
      }
    }

    final usageByFlock = <FeedUsageByFlock>[];

    for (final flock in flocks) {
      final plans =
          await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);

      final usedKg = plans
          .where(
            (plan) =>
                plan.actualTotalFeedKg != null &&
                reportService.weekOverlapsBoundary(
                  plan.weekStartDate,
                  periodBoundary,
                ),
          )
          .map((plan) => plan.actualTotalFeedKg!)
          .fold<double>(0, (sum, value) => sum + value);

      usageByFlock.add(
        FeedUsageByFlock(
          flockId: flock.id,
          flockName: flock.name,
          usedKg: usedKg > 0 ? usedKg : null,
        ),
      );
    }

    usageByFlock.sort(
      (a, b) => a.flockName.compareTo(b.flockName),
    );

    final trendDates = trendByDate.keys.toList()..sort();

    final feedUsageTrend = trendDates
        .map(
          (date) => FeedTrendPoint(
            date: date,
            usageByUnit: trendByDate[date]!,
          ),
        )
        .toList();

    return FeedAnalyticsData(
      feedUsedInSelectedPeriodByUnit:
          feedUsedInSelectedPeriodByUnit,
      remainingFeedStockByUnit: remainingFeedStockByUnit,
      feedUsageByFlock: usageByFlock,
      feedUsageTrend: feedUsageTrend,
    );
  }

  // Future CRUD methods can be added here.
  //
  // Example:
  //
  // Future<void> updateFeedUsage(...) async {
  //   await ref.read(feedRepositoryProvider).update(...);
  //   await load();
  // }
}

final feedAnalyticsProvider = StateNotifierProvider.family<
    FeedAnalyticsNotifier,
    FeedAnalyticsState,
    ReportFilter>(
  (ref, filter) {
    return FeedAnalyticsNotifier(ref, filter);
  },
);