class FlockHealthSnapshot {
  final String flockName;
  final int birdCount;
  final int recordedLosses;
  final double? mortalityPercent;
  final String status;

  const FlockHealthSnapshot({
    required this.flockName,
    required this.birdCount,
    required this.recordedLosses,
    required this.mortalityPercent,
    required this.status,
  });
}
