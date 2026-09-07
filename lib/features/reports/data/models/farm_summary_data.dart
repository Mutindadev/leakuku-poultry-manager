class FarmSummaryData {
  final int activeFlocks;
  final int totalBirdsAlive;
  final Map<String, double> feedStockByUnit;
  final Map<String, double> feedUsedByUnit;
  final double? averageMortalityPercent;

  const FarmSummaryData({
    required this.activeFlocks,
    required this.totalBirdsAlive,
    required this.feedStockByUnit,
    required this.feedUsedByUnit,
    required this.averageMortalityPercent,
  });
}
