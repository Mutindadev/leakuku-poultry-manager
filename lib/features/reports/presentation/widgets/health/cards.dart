import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/health_analytics_data.dart';
import 'package:leakuku/features/reports/domain/service/report_service.dart';
import 'package:leakuku/features/reports/presentation/pages/reports_page.dart';
import 'package:leakuku/features/reports/presentation/widgets/health/mortality_trend_chart.dart';

Widget buildHealthOverviewCard(
  BuildContext context,
  HealthAnalyticsData health,
) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.shieldHeart,
                color: AppColors.leakukuGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Health overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          metricText('Overall flock health status', health.overallStatus),
          const SizedBox(height: 6),
          metricText(
            'Mortality percentage',
            health.mortalityPercent == null
                ? 'No mortality records yet.'
                : '${health.mortalityPercent!.toStringAsFixed(1)}%',
            isEmpty: health.mortalityPercent == null,
          ),
          const SizedBox(height: 6),
          metricText(
            'Total recorded bird losses',
            health.totalBirdLosses == null
                ? 'No mortality records yet.'
                : '${health.totalBirdLosses}',
            isEmpty: health.totalBirdLosses == null,
          ),
          const SizedBox(height: 6),
          metricText(
              'Vaccinations completed', '${health.vaccinationsCompleted}'),
          const SizedBox(height: 6),
          metricText('Vaccinations due', '${health.vaccinationsDue}'),
          const SizedBox(height: 6),
          metricText(
              'Treatments recorded (All Time)', '${health.treatmentsRecorded}'),
        ],
      ),
    ),
  );
}

Widget buildMortalityCard(
  BuildContext context,
  HealthAnalyticsData health,
  ReportFilter filter,
) {
  if (!health.hasMortalityRecords) {
    return buildEmptyState(context, 'No mortality records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metricText(
            'Mortality in ${filter.label}',
            health.mortalityInSelectedPeriod == null
                ? 'No mortality records yet.'
                : '${health.mortalityInSelectedPeriod}',
            isEmpty: health.mortalityInSelectedPeriod == null,
          ),
          if (health.mortalityTrend.length >= 2) ...[
            const SizedBox(height: 12),
            Text(
              'Trend (${filter.label})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            MortalityTrendChart(points: health.mortalityTrend),
          ],
        ],
      ),
    ),
  );
}

Widget buildVaccinationCard(BuildContext context, HealthAnalyticsData health) {
  if (!health.hasVaccinationRecords) {
    return buildEmptyState(context, 'No vaccination records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metricText(
              'Vaccinations completed', '${health.vaccinationsCompleted}'),
          const SizedBox(height: 6),
          metricText('Vaccinations due', '${health.vaccinationsDue}'),
          const SizedBox(height: 6),
          metricText('Upcoming vaccinations', '${health.vaccinationsUpcoming}'),
          const SizedBox(height: 10),
          if (health.upcomingVaccinations.isEmpty)
            Text(
              'No upcoming vaccinations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            Column(
              children: health.upcomingVaccinations.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.syringe,
                        size: 12,
                        color: AppColors.leakukuGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.vaccineName} (${item.flockName})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        const ReportService().formatDate(item.dueDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}

Widget buildTreatmentCard(
  BuildContext context,
  HealthAnalyticsData health,
  ReportFilter filter,
) {
  if (health.treatmentsInSelectedPeriod == 0) {
    return buildEmptyState(context, 'No treatment records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metricText(
            'Number of treatments in ${filter.label}',
            '${health.treatmentsInSelectedPeriod}',
          ),
          const SizedBox(height: 6),
          metricText(
            'Most recent treatment',
            health.mostRecentTreatmentInSelectedPeriod ??
                'No treatment records yet.',
            isEmpty: health.mostRecentTreatmentInSelectedPeriod == null,
          ),
          const SizedBox(height: 10),
          Text(
            'Medicine usage summary (${filter.label})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          if (health.medicineUsageInSelectedPeriod.isEmpty)
            Text(
              'No treatment records yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            )
          else
            Column(
              children: health.medicineUsageInSelectedPeriod.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        item.quantityLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}

Widget buildHealthInsightsCard(
  BuildContext context,
  HealthAnalyticsData health,
) {
  if (health.insights.isEmpty) {
    return buildEmptyState(context, 'Not enough health records yet.');
  }

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: health.insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: FaIcon(
                    FontAwesomeIcons.lightbulb,
                    size: 12,
                    color: AppColors.leakukuGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}
