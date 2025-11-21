import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flockState = ref.watch(flockProvider);
    final stats = ref.watch(flockStatsProvider);
    final flocks = flockState.flocks;

    if (flockState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Breed Distribution'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _breedDistributionRow(context, '🥚 Layers', stats.layersCount, Colors.green),
                  const Divider(height: 24),
                  _breedDistributionRow(context, '🍗 Broilers', stats.broilersCount, Colors.deepOrange),
                  const Divider(height: 24),
                  _breedDistributionRow(context, '🐔 Improved Kienyeji', stats.kienyejiCount, Colors.brown),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, 'Growth Analytics'),
          const SizedBox(height: 12),
          if (flocks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No flocks to analyze. Add flocks to see growth analytics.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            ...flocks.map((flock) {
              final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
              final dailyFood = FeedingCalculator.getDailyFoodGrams(flock.breed, ageDays);
              final weeklyFood = FeedingCalculator.getWeeklyFoodGrams(flock.breed, ageDays);
              final daysToMaturity = FeedingCalculator.getDaysToMaturity(flock.breed, ageDays);
              final progress = FeedingCalculator.getMaturityProgress(flock.breed, ageDays);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getBreedColor(flock.breed).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _getBreedIcon(flock.breed),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  flock.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${flock.breed} • ${flock.quantity} chickens',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Growth Progress Bar
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(_getBreedColor(flock.breed)),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${progress.toStringAsFixed(1)}% to maturity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const Divider(height: 24),
                      // Growth Chart Placeholder
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.chartLine, color: _getBreedColor(flock.breed), size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Growth Chart',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                'Day 1 → Day $ageDays',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _metricChip(context, 'Age', '$ageDays days', FontAwesomeIcons.calendar),
                          _metricChip(context, 'To Maturity', '$daysToMaturity days', FontAwesomeIcons.clockRotateLeft),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _metricChip(context, 'Daily Food', '${dailyFood.toStringAsFixed(0)}g', FontAwesomeIcons.bowlFood),
                          _metricChip(context, 'Weekly Food', '${(weeklyFood / 1000).toStringAsFixed(1)}kg', FontAwesomeIcons.boxOpen),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _breedDistributionRow(BuildContext context, String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                label.split(' ')[0],
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label.split(' ').skip(1).join(' '),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count chickens',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricChip(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getBreedColor(String breed) {
    if (breed.toLowerCase().contains('layer')) return Colors.green;
    if (breed.toLowerCase().contains('broiler')) return Colors.deepOrange;
    return Colors.brown;
  }

  Widget _getBreedIcon(String breed) {
    if (breed.toLowerCase().contains('layer')) {
      return const Icon(FontAwesomeIcons.egg, color: Colors.green, size: 22);
    } else if (breed.toLowerCase().contains('broiler')) {
      return const Text('🍗', style: TextStyle(fontSize: 22));
    } else {
      return const Text('🐔', style: TextStyle(fontSize: 22));
    }
  }
}
