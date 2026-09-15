import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/weekly_mortality_record.dart';

class MortalityTrendChart extends StatelessWidget {
  final List<MortalityTrendPoint> points;

  const MortalityTrendChart({super.key, required this.points});

  String _shortDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        points.length <= 6 ? points : points.sublist(points.length - 6);
    final maxLoss = visible.fold<int>(0, (max, point) {
      return point.losses > max ? point.losses : max;
    });

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: visible.map((point) {
          final factor = maxLoss == 0 ? 0.0 : point.losses / maxLoss;
          final barHeight = 16 + (74 * factor);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${point.losses}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.leakukuGreen.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _shortDate(point.periodStart),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
