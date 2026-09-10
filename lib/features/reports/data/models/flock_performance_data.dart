class FlockPerformanceData {
  final String flockId;
  final String flockName;
  final int birdCount;
  final int ageDays;
  final double? averageWeightKg;
  final double? mortalityPercent;
  final double? survivalRate;
  final String performanceStatus;

  const FlockPerformanceData({
    required this.flockId,
    required this.flockName,
    required this.birdCount,
    required this.ageDays,
    required this.averageWeightKg,
    required this.mortalityPercent,
    required this.survivalRate,
    required this.performanceStatus,
  });
}
