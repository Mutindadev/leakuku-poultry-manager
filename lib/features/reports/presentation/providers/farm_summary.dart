import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/reports/data/models/farm_summary_data.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

final farmSummaryProvider =
    FutureProvider.family<FarmSummaryData, ReportFilter>(
  (ref, filter) async {
    final flockState = ref.watch(flockProvider);
    final flockStats = ref.watch(flockStatsProvider);
    final stockItems = await ref.watch(stockItemsProvider.future);
    final stockDataSource = ref.read(stockLocalDataSourceProvider);
    final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
    const reportService = ReportService();

    final boundary = reportService.getBoundary(filter);

    final feedItems = stockItems
        .where((item) => item.category.toLowerCase() == 'feed')
        .toList();

    final feedStockByUnit = <String, double>{};
    for (final item in feedItems) {
      if (item.quantity <= 0) {
        continue;
      }
      reportService.mergeQuantity(feedStockByUnit, item.unit, item.quantity);
    }

    final feedHistoryLists = await Future.wait(
      feedItems.map((item) => stockDataSource.getItemHistory(item.id)),
    );
    final feedUsedByUnit = <String, double>{};
    for (final histories in feedHistoryLists) {
      for (final entry in histories) {
        if (entry.action.toLowerCase() != 'used') {
          continue;
        }
        if (!reportService.isWithin(entry.date, boundary)) {
          continue;
        }
        reportService.mergeQuantity(feedUsedByUnit, entry.unit, entry.quantity);
      }
    }

    final mortalityValues = <double>[];
    final flockPlans = await Future.wait(
      flockState.flocks.map(
          (flock) => weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id)),
    );
    for (final plans in flockPlans) {
      for (final plan in plans) {
        final mortality = plan.actualMortalityPercent;
        if (mortality == null) {
          continue;
        }
        if (!reportService.weekOverlapsBoundary(plan.weekStartDate, boundary)) {
          continue;
        }
        mortalityValues.add(mortality);
      }
    }

    final averageMortalityPercent = mortalityValues.isEmpty
        ? null
        : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;

    return FarmSummaryData(
      activeFlocks: flockStats.totalFlocks,
      totalBirdsAlive: flockStats.totalChickens,
      feedStockByUnit: feedStockByUnit,
      feedUsedByUnit: feedUsedByUnit,
      averageMortalityPercent: averageMortalityPercent,
    );
  },
);
