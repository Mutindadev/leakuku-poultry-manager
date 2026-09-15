import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class GuidanceCard extends StatelessWidget {
  final String stage;

  const GuidanceCard({super.key, required this.stage});

  List<String> _guidanceForStage(String stage) {
    switch (stage) {
      case 'Brooding':
        return const [
          'Maintain brooder temperature.',
          'Replace wet litter.',
          'Clean drinkers.',
          'Observe bird activity.',
          'Check that feed is easy to reach.',
        ];
      case 'Growing':
        return const [
          'Clean drinkers.',
          'Observe bird activity.',
          'Weigh sample birds.',
          'Refresh feeders and remove waste feed.',
          'Walk through the house and remove wet spots.',
        ];
      default:
        return const [
          'Observe bird activity.',
          'Clean drinkers.',
          'Weigh sample birds.',
          'Check feed intake against the plan.',
          'Monitor comfort and keep litter dry.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidance = _guidanceForStage(stage);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: guidance
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            size: 10,
                            color: AppColors.leakukuGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.earthCharcoal,
                                    height: 1.4,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
