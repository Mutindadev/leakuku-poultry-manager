import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/home/presentation/pages/dashboard_page.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class AlertCard extends ConsumerStatefulWidget {
  final int selectedIndex;
  final List<FlockModel> flocks;
  final UpcomingVaccination? nextVaccination;
  final ValueChanged<int> onIndexChanged;

  const AlertCard({
    required this.selectedIndex,
    required this.flocks,
    required this.nextVaccination,
    required this.onIndexChanged,
    super.key,
  });

  @override
  ConsumerState<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends ConsumerState<AlertCard> {
  bool _hasHighMortalityAlert(List<FlockModel> flocks) {
    for (final flock in flocks) {
      final weeklyPlansAsync = ref.watch(weeklyPlansProvider(flock.id));
      final plans = weeklyPlansAsync.maybeWhen(
        data: (value) => value,
        orElse: () => const <WeeklyPlanModel>[],
      );

      final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
      final currentWeek = ageDays < 0 ? 1 : (ageDays ~/ 7) + 1;
      for (final plan in plans) {
        if (plan.weekNumber == currentWeek &&
            plan.actualMortalityPercent != null &&
            plan.actualMortalityPercent! > plan.plannedMortalityPercent) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final stockItemsAsync = ref.watch(stockItemsProvider);
    final alerts = <_AlertItem>[];

    stockItemsAsync.whenData((items) {
      final lowStockCount = items.where((item) => item.isLowStock).length;
      if (lowStockCount > 0) {
        alerts.add(
          _AlertItem(
            icon: FontAwesomeIcons.boxOpen,
            title: 'Low Stock',
            subtitle: lowStockCount == 1
                ? '1 stock item is below minimum level.'
                : '$lowStockCount stock items are below minimum levels.',
            color: Colors.deepOrange,
            onTap: () => Navigator.pushNamed(context, '/stock'),
          ),
        );
      }
    });

    if (widget.nextVaccination != null &&
        widget.nextVaccination!.remainingDays <= 1) {
      alerts.add(
        _AlertItem(
          icon: FontAwesomeIcons.syringe,
          title: 'Vaccination Due',
          subtitle:
              '${widget.nextVaccination?.label} · ${widget.nextVaccination?.dueLabel}',
          color: AppColors.harvestGold,
          onTap: () => widget.onIndexChanged(2),
        ),
      );
    }

    final hasHighMortality = _hasHighMortalityAlert(widget.flocks);
    if (hasHighMortality) {
      alerts.add(
        _AlertItem(
          icon: FontAwesomeIcons.heartPulse,
          title: 'High Mortality',
          subtitle:
              'One or more flocks have higher than planned mortality this week.',
          color: Colors.red,
          onTap: () => widget.onIndexChanged(2),
        ),
      );
    }

    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.circleCheck,
                    size: 16,
                    color: AppColors.leakukuGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No alerts today.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                  bottom: entry.key == alerts.length - 1 ? 0 : 10),
              child: Card(
                child: InkWell(
                  onTap: entry.value.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: entry.value.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: FaIcon(
                              entry.value.icon,
                              size: 16,
                              color: entry.value.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AlertItem {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
