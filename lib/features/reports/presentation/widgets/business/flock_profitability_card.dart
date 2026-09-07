import 'package:flutter/material.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';

class FlockProfitabilityCard extends StatelessWidget {
  final BusinessAnalyticsData analytics;

  const FlockProfitabilityCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final entries = analytics.flockSummaries.values.toList()
      ..sort((a, b) => b.estimatedProfit.compareTo(a.estimatedProfit));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flock Profitability',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              Text(
                'No flock-linked financial records yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              )
            else
              ...entries.map(
                (summary) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.flockLabel,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        metricText('Revenue', formatMoney(summary.revenue)),
                        const SizedBox(height: 4),
                        metricText('Expenses', formatMoney(summary.expenses)),
                        const SizedBox(height: 4),
                        metricText(
                          'Estimated Profit',
                          formatMoney(summary.estimatedProfit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
