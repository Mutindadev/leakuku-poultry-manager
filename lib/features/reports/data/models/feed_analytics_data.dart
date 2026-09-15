import 'package:leakuku/features/reports/data/models/feed_usage_by_flock.dart';

class FeedAnalyticsData {
  final Map<String, double> feedUsedInSelectedPeriodByUnit;
  final Map<String, double> remainingFeedStockByUnit;
  final List<FeedUsageByFlock> feedUsageByFlock;
  final List<FeedTrendPoint> feedUsageTrend;

  const FeedAnalyticsData({
    required this.feedUsedInSelectedPeriodByUnit,
    required this.remainingFeedStockByUnit,
    required this.feedUsageByFlock,
    required this.feedUsageTrend,
  });
}
