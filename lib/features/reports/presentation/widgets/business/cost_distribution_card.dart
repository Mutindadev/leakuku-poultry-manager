import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/business_analytics_data.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';

class CostDistributionCard extends StatelessWidget {
  final BusinessAnalyticsData analytics;

  const CostDistributionCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final ranked = analytics.rankedExpenseCategories;
    final maxValue = ranked.isEmpty ? 0.0 : ranked.first.value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            if (ranked.isEmpty)
              Text(
                'No expense records for this period.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              )
            else
              ...ranked.take(5).map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                formatMoney(entry.value),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: maxValue <= 0 ? 0 : entry.value / maxValue,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(999),
                            color: AppColors.warningAmber,
                            backgroundColor:
                                Colors.grey.withValues(alpha: 0.20),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
