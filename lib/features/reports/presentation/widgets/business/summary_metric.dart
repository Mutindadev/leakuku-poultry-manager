import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class SummaryMetricRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  const SummaryMetricRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.leakukuGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 12,
              color: AppColors.leakukuGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
