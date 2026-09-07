class FeedUsageByFlock {
  final String flockId;
  final String flockName;
  final double? usedKg;

  const FeedUsageByFlock({
    required this.flockId,
    required this.flockName,
    required this.usedKg,
  });
}

class FeedTrendPoint {
  final DateTime date;
  final Map<String, double> usageByUnit;

  const FeedTrendPoint({
    required this.date,
    required this.usageByUnit,
  });
}
