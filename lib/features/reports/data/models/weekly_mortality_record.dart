class WeeklyMortalityRecord {
  final String flockId;
  final DateTime weekStartDate;
  final int losses;
  final double mortalityPercent;

  const WeeklyMortalityRecord({
    required this.flockId,
    required this.weekStartDate,
    required this.losses,
    required this.mortalityPercent,
  });
}

class MortalityTrendPoint {
  final DateTime periodStart;
  final int losses;

  const MortalityTrendPoint({
    required this.periodStart,
    required this.losses,
  });
}
