import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class FeedMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isEmpty;

  const FeedMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
