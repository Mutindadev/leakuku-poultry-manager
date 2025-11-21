import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';

class ProgressPage extends ConsumerWidget {
  final bool showAppBar;
  const ProgressPage({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(flockStatsProvider);
    
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stat(context, FontAwesomeIcons.drumstickBite, 'Total Flocks', '${stats.totalFlocks}', 'Active flocks', const Color(0xFF4CAF50)),
          const SizedBox(height: 12),
          _stat(context, FontAwesomeIcons.hashtag, 'Total Chickens', '${stats.totalChickens}', 'All breeds', Colors.teal),
          const SizedBox(height: 12),
          _stat(context, FontAwesomeIcons.calendar, 'Average Age', '${stats.avgAgeDays} days', 'Across all flocks', Colors.indigo),
          const SizedBox(height: 24),
          Text('Breed Distribution', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _breedDistribution(context, stats),
          const SizedBox(height: 24),
          Text('Recent Activities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.clock, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No activity logged yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track feeding, weighing, and health checks here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (showAppBar) {
      return Scaffold(appBar: AppBar(title: const Text('Progress Tracking')), body: content);
    }
    return content;
  }

  Widget _breedDistribution(BuildContext context, FlockStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _breedRow(context, '🥚 Layers', stats.layersCount, Colors.green),
            const Divider(height: 20),
            _breedRow(context, '🍗 Broilers', stats.broilersCount, Colors.orange),
            const Divider(height: 20),
            _breedRow(context, '🐔 Improved Kienyeji', stats.kienyejiCount, Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _breedRow(BuildContext context, String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
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

  Widget _stat(BuildContext context, IconData icon, String title, String value, String subtitle, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ]),
          )
        ]),
      ),
    );
  }
}
