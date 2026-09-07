import 'package:leakuku/features/reports/data/models/weekly_mortality_record.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';

class ReportService {
  const ReportService();

  bool isWithin(DateTime value, Boundary boundary) {
    return !value.isBefore(boundary.start) &&
        value.isBefore(boundary.endExclusive);
  }

  bool weekOverlapsBoundary(
    DateTime weekStartDate,
    Boundary boundary,
  ) {
    final weekEndExclusive = weekStartDate.add(const Duration(days: 7));

    return weekEndExclusive.isAfter(boundary.start) &&
        weekStartDate.isBefore(boundary.endExclusive);
  }

  Boundary getBoundary(ReportFilter filter) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case ReportFilter.today:
        return Boundary(
          start: todayStart,
          endExclusive: todayStart.add(const Duration(days: 1)),
        );
      case ReportFilter.thisWeek:
        final weekdayOffset = now.weekday - DateTime.monday;
        final weekStart = todayStart.subtract(Duration(days: weekdayOffset));
        return Boundary(
          start: weekStart,
          endExclusive: weekStart.add(const Duration(days: 7)),
        );
      case ReportFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final nextMonthStart = now.month == 12
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
        return Boundary(
          start: monthStart,
          endExclusive: nextMonthStart,
        );
      case ReportFilter.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        final nextYearStart = DateTime(now.year + 1, 1, 1);
        return Boundary(
          start: yearStart,
          endExclusive: nextYearStart,
        );
      case ReportFilter.custom:
        return Boundary(
          start: todayStart,
          endExclusive: todayStart.add(const Duration(days: 1)),
        );
    }
  }

  Boundary getPreviousBoundary(ReportFilter filter) {
    final current = getBoundary(filter);
    final duration = current.endExclusive.difference(current.start);
    return Boundary(
      start: current.start.subtract(duration),
      endExclusive: current.start,
    );
  }

  List<WeeklyMortalityRecord> reconstructMortalityRecords({
    required String flockId,
    required int currentBirds,
    required List<dynamic> plans,
  }) {
    final plansWithMortality = plans
        .where(
          (plan) =>
              plan.actualMortalityPercent != null &&
              plan.actualMortalityPercent! > 0 &&
              plan.actualMortalityPercent! < 100,
        )
        .toList()
      ..sort(
        (a, b) => b.weekStartDate.compareTo(a.weekStartDate),
      );

    final records = <WeeklyMortalityRecord>[];
    var birdsAfter = currentBirds.toDouble();

    for (final plan in plansWithMortality) {
      final mortalityPercent = plan.actualMortalityPercent as double;
      final survivalRatio = 1 - mortalityPercent / 100;

      if (survivalRatio <= 0) {
        continue;
      }

      final birdsBefore = birdsAfter / survivalRatio;
      final losses = (birdsBefore - birdsAfter).round();

      if (losses <= 0) {
        birdsAfter = birdsBefore;
        continue;
      }

      records.add(
        WeeklyMortalityRecord(
          flockId: flockId,
          weekStartDate: plan.weekStartDate as DateTime,
          losses: losses,
          mortalityPercent: mortalityPercent,
        ),
      );

      birdsAfter = birdsBefore;
    }

    return records;
  }

  int sumLossesForBoundary(
    List<WeeklyMortalityRecord> records,
    Boundary boundary,
  ) {
    return records
        .where(
          (record) => weekOverlapsBoundary(
            record.weekStartDate,
            boundary,
          ),
        )
        .fold<int>(0, (sum, record) => sum + record.losses);
  }

  String healthStatusFromMortality(double? mortalityPercent) {
    if (mortalityPercent == null) {
      return 'Not recorded yet';
    }

    if (mortalityPercent <= 2) {
      return 'Excellent';
    }

    if (mortalityPercent <= 5) {
      return 'Good';
    }

    return 'Needs Attention';
  }

  String performanceStatus({
    required double? mortalityPercent,
    required double? averageWeightKg,
  }) {
    if (mortalityPercent != null) {
      return healthStatusFromMortality(mortalityPercent);
    }

    return averageWeightKg != null ? 'Good' : 'Needs Attention';
  }

  List<MapEntry<String, double>> sortedEntries(
    Map<String, double> values,
  ) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  void mergeQuantity(
    Map<String, double> store,
    String unit,
    double quantity,
  ) {
    store[unit] = (store[unit] ?? 0) + quantity;
  }

  String formatQuantities(Map<String, double> values) {
    final entries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map(
          (entry) => '${_formatDecimal(entry.value)} ${entry.key}',
        )
        .join(' • ');
  }

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String formatPercent(double? value) {
    if (value == null) {
      return 'N/A';
    }

    return '${value.toStringAsFixed(1)}%';
  }

  String previousLabelForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 'day';
      case ReportPeriod.thisWeek:
        return 'week';
      case ReportPeriod.thisMonth:
        return 'month';
      case ReportPeriod.thisYear:
        return 'year';
      case ReportPeriod.custom:
        return 'period';
    }
  }

  String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }
}

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class Boundary {
  final DateTime start;
  final DateTime endExclusive;

  const Boundary({
    required this.start,
    required this.endExclusive,
  });
}
