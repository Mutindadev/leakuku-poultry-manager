import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:leakuku/data/models/vaccine_model.dart'; // Updated import

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Map<String, Set<int>> _flockNotificationIds = <String, Set<int>>{};

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notificationsPlugin.initialize(settings);
  }

  /// Schedule vaccine reminders: 1 day before + on the day
  Future<void> scheduleVaccineReminders({
    required String flockId,
    required VaccineModel vaccine,
    required DateTime vaccineDate,
  }) async {
    final oneDayBefore = vaccineDate.subtract(const Duration(days: 1));
    
    // Notification ID = hash of flockId + vaccine.id + offset
    final reminderIdBefore = '${flockId}_${vaccine.id}_before'.hashCode;
    final reminderIdDay = '${flockId}_${vaccine.id}_day'.hashCode;
    _trackNotificationId(flockId, reminderIdBefore);
    _trackNotificationId(flockId, reminderIdDay);

    // Schedule 1 day before
    await _notificationsPlugin.zonedSchedule(
      reminderIdBefore,
      '🩺 Vaccination Tomorrow: ${vaccine.vaccineName}',
      'Prepare for ${vaccine.disease} vaccination on ${_formatDate(vaccineDate)}',
      _toTZDateTime(oneDayBefore.add(const Duration(hours: 9))), // 9 AM reminder
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_reminders',
          'Vaccine Reminders',
          channelDescription: 'Reminders for upcoming vaccinations',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Schedule on the day
    await _notificationsPlugin.zonedSchedule(
      reminderIdDay,
      '💉 Vaccination Day: ${vaccine.vaccineName}',
      'Today: Administer ${vaccine.vaccineName} via ${vaccine.application}',
      _toTZDateTime(vaccineDate.add(const Duration(hours: 7))), // 7 AM reminder
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_reminders',
          'Vaccine Reminders',
          channelDescription: 'Reminders for upcoming vaccinations',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all reminders for a flock (when flock deleted or date changed)
  Future<void> cancelFlockReminders(String flockId) async {
    final ids = _flockNotificationIds[flockId];
    if (ids == null || ids.isEmpty) {
      return;
    }

    for (final id in ids) {
      await _notificationsPlugin.cancel(id);
    }

    _flockNotificationIds.remove(flockId);
  }

  void _trackNotificationId(String flockId, int notificationId) {
    _flockNotificationIds.putIfAbsent(flockId, () => <int>{}).add(notificationId);
  }

  // Helper: Format date (requires intl package)
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  // Helper: Convert DateTime to TZDateTime (requires timezone package)
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
