import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/features/flock/data/models/vaccine_status.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

class VaccinationCard extends StatelessWidget {
  final List<VaccineModel> vaccines;
  final FlockModel flock;

  const VaccinationCard(
      {super.key, required this.vaccines, required this.flock});

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (vaccines.isEmpty) {
      // return _buildLoadingCard(
      //   context,
      //   'No vaccinations have been scheduled for this batch yet.',
      // );
    }

    final now = DateTime.now();
    final completed = <VaccineStatus>[];
    final upcoming = <VaccineStatus>[];

    for (final vaccine in vaccines) {
      final dueDate = flock.purchaseDate.add(
        Duration(days: vaccine.scheduleDayOffset),
      );
      final item = VaccineStatus(vaccine: vaccine, dueDate: dueDate);
      if (dueDate.isBefore(now)) {
        completed.add(item);
      } else {
        upcoming.add(item);
      }
    }

    completed.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    upcoming.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVaccinationGroup(
              context,
              title: 'Completed',
              emptyLabel: 'No completed vaccinations yet.',
              items: completed,
              icon: FontAwesomeIcons.circleCheck,
              color: AppColors.leakukuGreen,
            ),
            const SizedBox(height: 16),
            _buildVaccinationGroup(
              context,
              title: 'Upcoming',
              emptyLabel: 'No upcoming vaccinations yet.',
              items: upcoming,
              icon: FontAwesomeIcons.clock,
              color: AppColors.harvestGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationGroup(
    BuildContext context, {
    required String title,
    required String emptyLabel,
    required List<VaccineStatus> items,
    required FaIconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          )
        else
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vaccine.vaccineName,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.vaccine.disease,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatDate(item.dueDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
