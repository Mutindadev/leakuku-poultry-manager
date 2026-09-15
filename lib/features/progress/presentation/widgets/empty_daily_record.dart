import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';

class EmptyDailyRecordsState extends StatelessWidget {
  final bool showAppBar;

  const EmptyDailyRecordsState({super.key, required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: AppColors.farmCream,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.clipboardCheck,
                    size: 34,
                    color: AppColors.leakukuGreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No bird batch is ready for records yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.earthCharcoal,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a batch in Birds first, then come back here to manage the day\'s work.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.farmCream,
        appBar: AppBar(title: const Text('Daily Records')),
        body: content,
      );
    }

    return content;
  }
}
