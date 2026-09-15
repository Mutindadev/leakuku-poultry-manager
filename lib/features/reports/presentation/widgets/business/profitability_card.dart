import 'package:flutter/material.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final BusinessAnalyticsData analytics;

  const SummaryCard({super.key, required this.analytics, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // 'Profitability',
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            metricText('Revenue', formatMoney(analytics.totalRevenue)),
            const SizedBox(height: 6),
            metricText('Expenses', formatMoney(analytics.totalExpenses)),
            const SizedBox(height: 6),
            metricText('Net Profit', formatMoney(analytics.estimatedProfit)),
            const SizedBox(height: 6),
            metricText('Profit Margin',
                '${analytics.profitMargin?.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
