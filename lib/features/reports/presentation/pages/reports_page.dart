import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/data/models/flock_financial_summary.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/business_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/feed_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/health_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/performance_page.dart';
import 'package:leakuku/features/reports/presentation/pages/read_only_report_page.dart';
import 'package:leakuku/features/reports/presentation/pages/sumamry_detail_page.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/report_card.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/presentation/providers/farm_finance_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final _reportService = const ReportService();

  final ReportFilter _selectedFilter = ReportFilter.thisMonth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportNavigationCard(
            title: 'Farm Summary',
            description:
                'Quick financial and production snapshot for your selected period.',
            icon: FontAwesomeIcons.seedling,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FarmSummaryDetailPage(filter: _selectedFilter),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Flock Performance',
            description:
                'Growth trends, production quality, and performance comparisons.',
            icon: FontAwesomeIcons.chartLine,
            onTap: () => _openReportPage(
              context,
              title: 'Flock Performance',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Feed Analytics',
            description:
                'Feed consumption efficiency and stock movement insights.',
            icon: FontAwesomeIcons.bowlFood,
            onTap: () => _openReportPage(
              context,
              title: 'Feed Analytics',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Health Analytics',
            description:
                'Mortality, vaccination, and flock health outcome patterns.',
            icon: FontAwesomeIcons.heartPulse,
            onTap: () => _openReportPage(
              context,
              title: 'Health Analytics',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Business Analytics',
            description:
                'Operational performance and profitability reporting tools.',
            icon: FontAwesomeIcons.sackDollar,
            onTap: () => _openReportPage(
              context,
              title: 'Business Analytics',
            ),
          ),
        ],
      ),
    );
  }

  void _openReportPage(BuildContext context, {required String title}) {
    if (title == 'Flock Performance') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PerformancePage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Feed Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FeedAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Health Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HealthAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Business Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BusinessAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadOnlyReportPage(title: title),
      ),
    );
  }
}

enum ReportFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension ReportFilterX on ReportFilter {
  String get label {
    switch (this) {
      case ReportFilter.today:
        return 'Today';
      case ReportFilter.thisWeek:
        return 'This Week';
      case ReportFilter.thisMonth:
        return 'This Month';
      case ReportFilter.thisYear:
        return 'This Year';
      case ReportFilter.custom:
        return 'Custom';
    }
  }
}

const List<ReportFilter> _visibleReportFilters = <ReportFilter>[
  ReportFilter.today,
  ReportFilter.thisWeek,
  ReportFilter.thisMonth,
  ReportFilter.thisYear,
];

// final _farmSummaryProvider =
//     FutureProvider.family<FarmSummaryData, ReportFilter>(
//   (ref, filter) async {
//     final flockState = ref.watch(flockProvider);
//     final flockStats = ref.watch(flockStatsProvider);
//     final stockItems = await ref.watch(stockItemsProvider.future);
//     final stockDataSource = ref.read(stockLocalDataSourceProvider);
//     final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
//     const reportService = ReportService();

//     final boundary = reportService.getBoundary(filter);

//     final feedItems = stockItems
//         .where((item) => item.category.toLowerCase() == 'feed')
//         .toList();

//     final feedStockByUnit = <String, double>{};
//     for (final item in feedItems) {
//       if (item.quantity <= 0) {
//         continue;
//       }
//       reportService.mergeQuantity(feedStockByUnit, item.unit, item.quantity);
//     }

//     final feedHistoryLists = await Future.wait(
//       feedItems.map((item) => stockDataSource.getItemHistory(item.id)),
//     );
//     final feedUsedByUnit = <String, double>{};
//     for (final histories in feedHistoryLists) {
//       for (final entry in histories) {
//         if (entry.action.toLowerCase() != 'used') {
//           continue;
//         }
//         if (!reportService.isWithin(entry.date, boundary)) {
//           continue;
//         }
//         reportService.mergeQuantity(feedUsedByUnit, entry.unit, entry.quantity);
//       }
//     }

//     final mortalityValues = <double>[];
//     final flockPlans = await Future.wait(
//       flockState.flocks.map(
//           (flock) => weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id)),
//     );
//     for (final plans in flockPlans) {
//       for (final plan in plans) {
//         final mortality = plan.actualMortalityPercent;
//         if (mortality == null) {
//           continue;
//         }
//         if (!reportService.weekOverlapsBoundary(plan.weekStartDate, boundary)) {
//           continue;
//         }
//         mortalityValues.add(mortality);
//       }
//     }

//     final averageMortalityPercent = mortalityValues.isEmpty
//         ? null
//         : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;

//     return FarmSummaryData(
//       activeFlocks: flockStats.totalFlocks,
//       totalBirdsAlive: flockStats.totalChickens,
//       feedStockByUnit: feedStockByUnit,
//       feedUsedByUnit: feedUsedByUnit,
//       averageMortalityPercent: averageMortalityPercent,
//     );
//   },
// );

final _businessAnalyticsProvider =
    FutureProvider.family<BusinessAnalyticsData, ReportFilter>(
  (ref, filter) async {
    const reportService = ReportService();

    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) {
      return const BusinessAnalyticsData(
        transactions: <FinancialTransactionModel>[],
        totalRevenue: 0,
        totalExpenses: 0,
        estimatedProfit: 0,
        profitMargin: null,
        revenueByCategory: <String, double>{},
        expenseByCategory: <String, double>{},
        rankedExpenseCategories: <MapEntry<String, double>>[],
        flockSummaries: <String, FlockFinancialSummary>{},
        insights: <String>[],
      );
    }

    final repository = ref.read(financialTransactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions(userId);
    final boundary = reportService.getBoundary(filter);
    final previousBoundary = reportService.getPreviousBoundary(filter);

    final transactions = allTransactions
        .where((item) => reportService.isWithin(item.date, boundary))
        .toList();

    final revenueByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};
    final flockRevenue = <String, double>{};
    final flockExpenses = <String, double>{};

    var totalRevenue = 0.0;
    var totalExpenses = 0.0;

    for (final item in transactions) {
      if (item.transactionType == 'income') {
        totalRevenue += item.amount;
        revenueByCategory[item.category] =
            (revenueByCategory[item.category] ?? 0) + item.amount;
      } else if (item.transactionType == 'expense') {
        totalExpenses += item.amount;
        expenseByCategory[item.category] =
            (expenseByCategory[item.category] ?? 0) + item.amount;
      } else {
        continue;
      }

      final flockKey = item.relatedFlock?.trim();
      if (flockKey != null && flockKey.isNotEmpty) {
        if (item.transactionType == 'income') {
          flockRevenue[flockKey] = (flockRevenue[flockKey] ?? 0) + item.amount;
        } else if (item.transactionType == 'expense') {
          flockExpenses[flockKey] =
              (flockExpenses[flockKey] ?? 0) + item.amount;
        }
      }
    }

    final estimatedProfit = totalRevenue - totalExpenses;
    final profitMargin =
        totalRevenue > 0 ? ((estimatedProfit / totalRevenue) * 100) : null;

    final rankedExpenseCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final flockSummaries = <String, FlockFinancialSummary>{};
    final flockKeys = {...flockRevenue.keys, ...flockExpenses.keys}.toList()
      ..sort((a, b) => a.compareTo(b));
    for (final key in flockKeys) {
      flockSummaries[key] = FlockFinancialSummary(
        flockLabel: key,
        revenue: flockRevenue[key] ?? 0,
        expenses: flockExpenses[key] ?? 0,
      );
    }

    final previousTransactions = allTransactions
        .where((item) => reportService.isWithin(item.date, previousBoundary))
        .toList();
    final previousRevenue = previousTransactions
        .where((item) => item.transactionType == 'income')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final previousExpenses = previousTransactions
        .where((item) => item.transactionType == 'expense')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final previousProfit = previousRevenue - previousExpenses;

    final insights = _buildBusinessInsights(
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      currentProfit: estimatedProfit,
      previousProfit: previousTransactions.isEmpty ? null : previousProfit,
      previousLabel: _previousLabelForFilter(filter),
    );

    return BusinessAnalyticsData(
      transactions: transactions,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      estimatedProfit: estimatedProfit,
      profitMargin: profitMargin,
      revenueByCategory: revenueByCategory,
      expenseByCategory: expenseByCategory,
      rankedExpenseCategories: rankedExpenseCategories,
      flockSummaries: flockSummaries,
      insights: insights,
    );
  },
);

// final _flockPerformanceProvider =
//     FutureProvider.family<List<FlockPerformanceData>, ReportFilter>(
//   (ref, filter) async {
//     const reportService = ReportService();
//     final flocks = ref.watch(flockProvider).flocks;
//     final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
//     final boundary = reportService.getBoundary(filter);
//     final items = <FlockPerformanceData>[];

//     for (final flock in flocks) {
//       final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);

//       final weightValues = plans
//           .where((plan) =>
//               plan.actualBodyWeightKg != null &&
//               reportService.weekOverlapsBoundary(plan.weekStartDate, boundary))
//           .map((plan) => plan.actualBodyWeightKg!)
//           .toList();

//       final mortalityValues = plans
//           .where((plan) =>
//               plan.actualMortalityPercent != null &&
//               reportService.weekOverlapsBoundary(plan.weekStartDate, boundary))
//           .map((plan) => plan.actualMortalityPercent!)
//           .toList();

//       final averageWeight = weightValues.isEmpty
//           ? null
//           : weightValues.reduce((a, b) => a + b) / weightValues.length;
//       final mortalityPercent = mortalityValues.isEmpty
//           ? null
//           : mortalityValues.reduce((a, b) => a + b) / mortalityValues.length;
//       final survivalRate = mortalityPercent == null
//           ? null
//           : (100 - mortalityPercent).clamp(0, 100).toDouble();

//       items.add(
//         FlockPerformanceData(
//           flockId: flock.id,
//           flockName: flock.name,
//           birdCount: flock.quantity,
//           ageDays: DateTime.now().difference(flock.purchaseDate).inDays,
//           averageWeightKg: averageWeight,
//           mortalityPercent: mortalityPercent,
//           survivalRate: survivalRate,
//           performanceStatus: reportService.performanceStatus(
//             mortalityPercent: mortalityPercent,
//             averageWeightKg: averageWeight,
//           ),
//         ),
//       );
//     }

//     items.sort((a, b) => a.flockName.compareTo(b.flockName));
//     return items;
//   },
// );

// final _feedAnalyticsProvider =
//     FutureProvider.family<FeedAnalyticsData, ReportFilter>(
//   (ref, filter) async {
//     const reportService = ReportService();
//     final flocks = ref.watch(flockProvider).flocks;
//     final stockItems = await ref.watch(stockItemsProvider.future);
//     final stockDataSource = ref.read(stockLocalDataSourceProvider);
//     final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
//     final periodBoundary = reportService.getBoundary(filter);

//     final feedItems = stockItems
//         .where((item) => item.category.toLowerCase() == 'feed')
//         .toList();

//     final remainingFeedStockByUnit = <String, double>{};
//     for (final item in feedItems) {
//       if (item.quantity <= 0) {
//         continue;
//       }
//       reportService.mergeQuantity(
//           remainingFeedStockByUnit, item.unit, item.quantity);
//     }

//     final feedHistoryLists = await Future.wait(
//       feedItems.map((item) => stockDataSource.getItemHistory(item.id)),
//     );

//     final feedUsedInSelectedPeriodByUnit = <String, double>{};
//     final trendByDate = <DateTime, Map<String, double>>{};

//     for (final histories in feedHistoryLists) {
//       for (final entry in histories) {
//         if (entry.action.toLowerCase() != 'used') {
//           continue;
//         }

//         if (reportService.isWithin(entry.date, periodBoundary)) {
//           reportService.mergeQuantity(
//             feedUsedInSelectedPeriodByUnit,
//             entry.unit,
//             entry.quantity,
//           );
//           final day =
//               DateTime(entry.date.year, entry.date.month, entry.date.day);
//           final dayMap = trendByDate.putIfAbsent(day, () => <String, double>{});
//           reportService.mergeQuantity(dayMap, entry.unit, entry.quantity);
//         }
//       }
//     }

//     final usageByFlock = <FeedUsageByFlock>[];
//     for (final flock in flocks) {
//       final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);
//       final usedKg = plans
//           .where((plan) =>
//               plan.actualTotalFeedKg != null &&
//               reportService.weekOverlapsBoundary(
//                   plan.weekStartDate, periodBoundary))
//           .map((plan) => plan.actualTotalFeedKg!)
//           .fold<double>(0, (sum, value) => sum + value);

//       usageByFlock.add(
//         FeedUsageByFlock(
//           flockId: flock.id,
//           flockName: flock.name,
//           usedKg: usedKg > 0 ? usedKg : null,
//         ),
//       );
//     }
//     usageByFlock.sort((a, b) => a.flockName.compareTo(b.flockName));

//     final trendDates = trendByDate.keys.toList()..sort();
//     final feedUsageTrend = trendDates
//         .map(
//           (date) => FeedTrendPoint(
//             date: date,
//             usageByUnit: trendByDate[date]!,
//           ),
//         )
//         .toList();

//     return FeedAnalyticsData(
//       feedUsedInSelectedPeriodByUnit: feedUsedInSelectedPeriodByUnit,
//       remainingFeedStockByUnit: remainingFeedStockByUnit,
//       feedUsageByFlock: usageByFlock,
//       feedUsageTrend: feedUsageTrend,
//     );
//   },
// );

// final _healthAnalyticsProvider =
//     FutureProvider.family<HealthAnalyticsData, ReportFilter>(
//   (ref, filter) async {
//     final flockState = ref.watch(flockProvider);
//     final flocks = flockState.flocks;
//     final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
//     final vaccineDataSource = ref.read(vaccineDataSourceProvider);
//     final stockItems = await ref.watch(stockItemsProvider.future);
//     final stockDataSource = ref.read(stockLocalDataSourceProvider);
//     const reportService = ReportService();
//     final todayBoundary = reportService.getBoundary(ReportFilter.today);
//     final periodBoundary = reportService.getBoundary(filter);

//     final allWeeklyRecords = <WeeklyMortalityRecord>[];
//     final flockHealth = <FlockHealthSnapshot>[];

//     for (final flock in flocks) {
//       final plans = await weeklyPlanDataSource.getWeeklyPlansForFlock(flock.id);
//       final records = reportService.reconstructMortalityRecords(
//         flockId: flock.id,
//         currentBirds: flock.quantity,
//         plans: plans,
//       );
//       allWeeklyRecords.addAll(records);

//       final flockLosses =
//           records.fold<int>(0, (sum, item) => sum + item.losses);
//       final flockBaseline = flock.quantity + flockLosses;
//       final flockMortalityPercent =
//           flockBaseline == 0 ? null : (flockLosses / flockBaseline) * 100;

//       flockHealth.add(
//         FlockHealthSnapshot(
//           flockName: flock.name,
//           birdCount: flock.quantity,
//           recordedLosses: flockLosses,
//           mortalityPercent: flockMortalityPercent,
//           status:
//               reportService.healthStatusFromMortality(flockMortalityPercent),
//         ),
//       );
//     }

//     flockHealth.sort((a, b) => a.flockName.compareTo(b.flockName));
//     final hasMortalityRecords = allWeeklyRecords.isNotEmpty;

//     final totalBirdLosses = hasMortalityRecords
//         ? allWeeklyRecords.fold<int>(0, (sum, item) => sum + item.losses)
//         : null;
//     final birdsAlive =
//         flocks.fold<int>(0, (sum, flock) => sum + flock.quantity);
//     final baselineBirds =
//         totalBirdLosses == null ? null : birdsAlive + totalBirdLosses;
//     final mortalityPercent =
//         (baselineBirds == null || baselineBirds == 0 || totalBirdLosses == null)
//             ? null
//             : (totalBirdLosses / baselineBirds) * 100;

//     final mortalityInSelectedPeriod = hasMortalityRecords
//         ? reportService.sumLossesForBoundary(allWeeklyRecords, periodBoundary)
//         : null;

//     final trendMap = <DateTime, int>{};
//     for (final record in allWeeklyRecords) {
//       if (!reportService.weekOverlapsBoundary(
//           record.weekStartDate, periodBoundary)) {
//         continue;
//       }
//       trendMap[record.weekStartDate] =
//           (trendMap[record.weekStartDate] ?? 0) + record.losses;
//     }

//     final trendKeys = trendMap.keys.toList()..sort();
//     final mortalityTrend = trendKeys
//         .map(
//           (key) => MortalityTrendPoint(
//             periodStart: key,
//             losses: trendMap[key]!,
//           ),
//         )
//         .toList();

//     var vaccinationsCompleted = 0;
//     var vaccinationsDue = 0;
//     var vaccinationsUpcoming = 0;
//     final upcomingVaccinations = <UpcomingVaccination>[];
//     var hasVaccinationRecords = false;

//     for (final flock in flocks) {
//       final vaccines =
//           await vaccineDataSource.getVaccineScheduleForFlock(flock.id);
//       if (vaccines.isEmpty) {
//         continue;
//       }
//       hasVaccinationRecords = true;

//       for (final vaccine in vaccines) {
//         final dueDate =
//             flock.purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));

//         if (dueDate.isBefore(todayBoundary.start)) {
//           vaccinationsCompleted++;
//           continue;
//         }

//         if (reportService.isWithin(dueDate, todayBoundary)) {
//           vaccinationsDue++;
//           continue;
//         }

//         if (!dueDate.isBefore(todayBoundary.endExclusive)) {
//           vaccinationsUpcoming++;
//           upcomingVaccinations.add(
//             UpcomingVaccination(
//               flockName: flock.name,
//               vaccineName: vaccine.vaccineName,
//               dueDate: dueDate,
//             ),
//           );
//         }
//       }
//     }

//     upcomingVaccinations.sort((a, b) => a.dueDate.compareTo(b.dueDate));
//     final trimmedUpcoming = upcomingVaccinations.take(5).toList();

//     final medicineItems = stockItems.where((item) {
//       final category = item.category.toLowerCase();
//       return category == 'medicines' || category == 'medicine';
//     }).toList();

//     final medicineUsedEntries = <Map<String, dynamic>>[];
//     final medicineUsedEntriesInSelectedPeriod = <Map<String, dynamic>>[];
//     for (final item in medicineItems) {
//       final history = await stockDataSource.getItemHistory(item.id);
//       for (final entry in history) {
//         if (entry.action.toLowerCase() != 'used') {
//           continue;
//         }
//         final map = <String, dynamic>{
//           'itemName': entry.itemName,
//           'quantity': entry.quantity,
//           'unit': entry.unit,
//           'date': entry.date,
//         };
//         medicineUsedEntries.add(map);
//         if (reportService.isWithin(entry.date, periodBoundary)) {
//           medicineUsedEntriesInSelectedPeriod.add(map);
//         }
//       }
//     }

//     medicineUsedEntries.sort(
//       (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
//     );
//     medicineUsedEntriesInSelectedPeriod.sort(
//       (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
//     );

//     final treatmentsRecorded = medicineUsedEntries.length;
//     final treatmentsInSelectedPeriod =
//         medicineUsedEntriesInSelectedPeriod.length;
//     final mostRecentTreatmentInSelectedPeriod = treatmentsInSelectedPeriod == 0
//         ? null
//         : '${medicineUsedEntriesInSelectedPeriod.first['itemName']} (${reportService.formatDate(medicineUsedEntriesInSelectedPeriod.first['date'] as DateTime)})';

//     final medicineTotalsInSelectedPeriod = <String, Map<String, double>>{};
//     for (final entry in medicineUsedEntriesInSelectedPeriod) {
//       final itemName = entry['itemName'] as String;
//       final unit = entry['unit'] as String;
//       final quantity = entry['quantity'] as double;
//       final byUnit = medicineTotalsInSelectedPeriod.putIfAbsent(
//           itemName, () => <String, double>{});
//       reportService.mergeQuantity(byUnit, unit, quantity);
//     }

//     final medicineUsageInSelectedPeriod =
//         medicineTotalsInSelectedPeriod.entries.map((entry) {
//       return MedicineUsageSummary(
//         itemName: entry.key,
//         quantityLabel: reportService.formatQuantities(entry.value),
//       );
//     }).toList()
//           ..sort((a, b) => a.itemName.compareTo(b.itemName));

//     final insights = <String>[];
//     if (mortalityPercent != null && mortalityPercent <= 2) {
//       insights.add('Excellent flock health.');
//     }
//     if (mortalityInSelectedPeriod != null && mortalityInSelectedPeriod == 0) {
//       insights.add('No bird losses recorded in ${filter.label.toLowerCase()}.');
//     }
//     if (vaccinationsDue > 0) {
//       insights.add('Vaccinations are due today.');
//     }
//     if (mortalityTrend.length >= 2) {
//       final latest = mortalityTrend.last.losses;
//       final previous = mortalityTrend[mortalityTrend.length - 2].losses;
//       if (latest > previous) {
//         insights.add('Mortality increased compared to last week.');
//       }
//     }
//     if (treatmentsInSelectedPeriod > 0 &&
//         mostRecentTreatmentInSelectedPeriod != null) {
//       insights.add(
//         'Recent treatment in ${filter.label.toLowerCase()}: '
//         '$mostRecentTreatmentInSelectedPeriod.',
//       );
//     }

//     return HealthAnalyticsData(
//       overallStatus: reportService.healthStatusFromMortality(mortalityPercent),
//       mortalityPercent: mortalityPercent,
//       totalBirdLosses: totalBirdLosses,
//       mortalityInSelectedPeriod: mortalityInSelectedPeriod,
//       vaccinationsCompleted: vaccinationsCompleted,
//       vaccinationsDue: vaccinationsDue,
//       vaccinationsUpcoming: vaccinationsUpcoming,
//       upcomingVaccinations: trimmedUpcoming,
//       treatmentsRecorded: treatmentsRecorded,
//       treatmentsInSelectedPeriod: treatmentsInSelectedPeriod,
//       mostRecentTreatmentInSelectedPeriod: mostRecentTreatmentInSelectedPeriod,
//       medicineUsageInSelectedPeriod: medicineUsageInSelectedPeriod,
//       mortalityTrend: mortalityTrend,
//       flockHealth: flockHealth,
//       insights: insights,
//       hasVaccinationRecords: hasVaccinationRecords,
//       hasMortalityRecords: hasMortalityRecords,
//     );
//   },
// );

Widget buildPeriodFilter(
  BuildContext context, {
  required ReportFilter selectedFilter,
  required ValueChanged<ReportFilter> onChanged,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _visibleReportFilters.map((filter) {
          return ChoiceChip(
            label: Text(filter.label),
            selected: selectedFilter == filter,
            onSelected: (_) => onChanged(filter),
          );
        }).toList(),
      ),
    ),
  );
}

Widget buildStatusBadge(String status) {
  final color = _statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget buildEmptyState(BuildContext context, String message) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
      ),
    ),
  );
}

Widget metricText(String label, String value, {bool isEmpty = false}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.softGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        value,
        style: TextStyle(
          color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

String formatAge(int ageDays) {
  if (ageDays < 0) {
    return 'Not recorded yet';
  }
  final weeks = ageDays ~/ 7;
  final days = ageDays % 7;
  return '${weeks}w ${days}d';
}

Color _statusColor(String status) {
  switch (status) {
    case 'Excellent':
      return AppColors.leakukuGreen;
    case 'Good':
      return const Color(0xFF1E88E5);
    case 'Needs Attention':
      return AppColors.errorRed;
    default:
      return Colors.grey;
  }
}

String _previousLabelForFilter(ReportFilter filter) {
  switch (filter) {
    case ReportFilter.today:
      return 'day';
    case ReportFilter.thisWeek:
      return 'week';
    case ReportFilter.thisMonth:
      return 'month';
    case ReportFilter.thisYear:
      return 'year';
    case ReportFilter.custom:
      return 'period';
  }
}

String formatMoney(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'KES ',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

enum _ReportExportAction { pdf, excel, share }

Widget buildReportExportAction(
  BuildContext context, {
  required bool enabled,
  required Future<void> Function(_ReportExportAction action) onActionSelected,
}) {
  if (!enabled) {
    return const IconButton(
      onPressed: null,
      icon: Icon(Icons.download_outlined),
      tooltip: 'There is no data available for the selected period.',
    );
  }

  return PopupMenuButton<_ReportExportAction>(
    tooltip: 'Export',
    icon: const Icon(Icons.download_outlined),
    onSelected: (action) async {
      await onActionSelected(action);
    },
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: _ReportExportAction.pdf,
        child: Text('Export PDF'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.excel,
        child: Text('Export Excel'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.share,
        child: Text('Share'),
      ),
    ],
  );
}

Future<void> handleExportAction(
  BuildContext context,
  _ReportExportAction action,
  ReportExportPayload payload,
) async {
  if (payload.rows.length <= 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('There is no data available for the selected period.'),
      ),
    );
    return;
  }

  try {
    if (action == _ReportExportAction.pdf) {
      final file = await _generatePdfFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported: ${file.path}')),
      );
      return;
    }

    if (action == _ReportExportAction.excel) {
      final file = await _generateExcelFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel exported: ${file.path}')),
      );
      return;
    }

    final file = await _generatePdfFile(payload);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${payload.reportTitle} (${payload.periodLabel})',
      text: 'Leakuku Report: ${payload.reportTitle} (${payload.periodLabel})',
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $error')),
    );
  }
}

Future<File> _generatePdfFile(ReportExportPayload payload) async {
  final doc = pw.Document();
  final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  final headers = payload.rows.first;
  final dataRows = payload.rows.skip(1).toList();

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          payload.reportTitle,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Reporting Period: ${payload.periodLabel}'),
        pw.Text('Generated: $generatedAt'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: dataRows,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(
            color: pdf_core.PdfColor.fromInt(0xFFEFEFEF),
          ),
        ),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final fileName =
      _exportFileName(payload.reportTitle, payload.periodLabel, 'pdf');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(await doc.save(), flush: true);
  return file;
}

Future<File> _generateExcelFile(ReportExportPayload payload) async {
  final workbook = Excel.createExcel();
  final sheet = workbook['Report'];

  for (final row in payload.rows) {
    sheet.appendRow(row);
  }

  final bytes = workbook.encode();
  if (bytes == null) {
    throw Exception('Unable to encode Excel file.');
  }

  final dir = await getTemporaryDirectory();
  final fileName =
      _exportFileName(payload.reportTitle, payload.periodLabel, 'xlsx');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

String _exportFileName(
    String reportTitle, String periodLabel, String extension) {
  final slugTitle =
      reportTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final slugPeriod =
      periodLabel.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${slugTitle}_${slugPeriod}_$timestamp.$extension';
}

List<String> _buildBusinessInsights({
  required Map<String, double> revenueByCategory,
  required Map<String, double> expenseByCategory,
  required double currentProfit,
  required double? previousProfit,
  required String previousLabel,
}) {
  final insights = <String>[];
  const reportService = ReportService();

  final rankedRevenue = reportService.sortedEntries(revenueByCategory);
  if (rankedRevenue.isNotEmpty) {
    insights.add('${rankedRevenue.first.key} generated most of your income.');
  }

  final rankedExpenses = reportService.sortedEntries(expenseByCategory);
  if (rankedExpenses.isNotEmpty) {
    insights.add('${rankedExpenses.first.key} is your largest expense.');
  }

  final labourCurrent = expenseByCategory['Labour'];
  if (labourCurrent != null && labourCurrent > 0) {
    final totalExpense =
        expenseByCategory.values.fold<double>(0, (s, v) => s + v);
    if (totalExpense > 0) {
      final labourShare = (labourCurrent / totalExpense) * 100;
      if (labourShare <= 20) {
        insights.add('Labour costs stayed moderate in this period.');
      }
    }
  }

  if (previousProfit != null) {
    if (currentProfit > previousProfit) {
      insights.add('Profit increased compared to last $previousLabel.');
    } else if (currentProfit < previousProfit) {
      insights.add('Profit decreased compared to last $previousLabel.');
    }
  }

  return insights;
}
