import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leakuku/data/models/vaccine_model.dart'; // Updated import
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<String, Set<int>> _flockNotificationIds = <String, Set<int>>{};
  static const int _syncNotificationId = 42001;
  Future<bool>? _permissionRequest;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> showSyncProgress({
    required int progressPercent,
    required String status,
  }) async {
    _permissionRequest ??= _requestNotificationPermission();
    if (!await _permissionRequest!) return;

    final progress = progressPercent.clamp(0, 100).toInt();
    await _notificationsPlugin.show(
      _syncNotificationId,
      'Backing up farm data',
      '$status ($progress%)',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'farm_data_sync',
          'Farm data sync',
          channelDescription: 'Progress of local farm data backup',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          ongoing: true,
          onlyAlertOnce: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  Future<void> cancelSyncProgress() =>
      _notificationsPlugin.cancel(_syncNotificationId);

  Future<bool> _requestNotificationPermission() async {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          ) ??
          false;
    }

    return true;
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
      _toTZDateTime(
          oneDayBefore.add(const Duration(hours: 9))), // 9 AM reminder
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
    _flockNotificationIds
        .putIfAbsent(flockId, () => <int>{})
        .add(notificationId);
  }

  // Helper: Format date (requires intl package)
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  // Helper: Convert DateTime to TZDateTime (requires timezone package)
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
