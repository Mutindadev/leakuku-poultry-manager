import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class StageCard extends StatelessWidget {
  final String stage;

  const StageCard({super.key, required this.stage});

  String _stageDescription(String stage) {
    switch (stage) {
      case 'Brooding':
        return 'Keep the young birds warm, dry, and active.';
      case 'Growing':
        return 'Support steady growth with clean water and close observation.';
      default:
        return 'Maintain good routine so the batch stays productive and stable.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.harvestGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.seedling,
                  color: AppColors.harvestGold,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stageDescription(stage),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
