import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flocks = ref.watch(flockProvider).flocks;

    // Generate notifications from flock data
    final notifications = <Map<String, dynamic>>[];
    
    for (final flock in flocks) {
      final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
      final dailyFood = FeedingCalculator.getDailyFoodGrams(flock.breed, ageDays);
      final daysToMaturity = FeedingCalculator.getDaysToMaturity(flock.breed, ageDays);
      
      // Feeding reminder
      notifications.add({
        'type': 'feeding',
        'icon': FontAwesomeIcons.bowlFood,
        'color': const Color(0xFF4CAF50),
        'title': 'Feeding Time - ${flock.name}',
        'message': 'Feed ${dailyFood.toStringAsFixed(0)}g per chicken today',
        'time': '2h ago',
        'isRead': false,
      });
      
      // Maturity alert (if close to maturity)
      if (daysToMaturity <= 7 && daysToMaturity > 0) {
        notifications.add({
          'type': 'maturity',
          'icon': FontAwesomeIcons.clockRotateLeft,
          'color': Colors.orange,
          'title': 'Approaching Maturity - ${flock.name}',
          'message': '$daysToMaturity days until maturity (${flock.breed})',
          'time': '5h ago',
          'isRead': false,
        });
      }
    }

    // Add general notifications
    notifications.add({
      'type': 'health',
      'icon': FontAwesomeIcons.heartPulse,
      'color': Colors.red,
      'title': 'Health Check Reminder',
      'message': 'Schedule routine health inspection for all flocks',
      'time': '1d ago',
      'isRead': true,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
            label: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.bell, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add flocks to receive feeding and health reminders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: notif['isRead'] ? Colors.white : const Color(0xFFF1F8E9),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (notif['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notif['icon'] as IconData,
                        color: notif['color'] as Color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif['title'] as String,
                      style: TextStyle(
                        fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif['message'] as String),
                        const SizedBox(height: 4),
                        Text(
                          notif['time'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
