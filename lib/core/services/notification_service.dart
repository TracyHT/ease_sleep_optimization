import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'alarm_channel';
  static const String _channelName = 'Alarm Notifications';
  static const String _channelDescription = 'Notifications for scheduled alarms';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannel();
    _isInitialized = true;
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle alarm notification actions (snooze, dismiss, etc.)
      _handleAlarmAction(payload, response.actionId);
    }
  }

  /// Handle alarm actions from notifications
  void _handleAlarmAction(String alarmId, String? actionId) {
    switch (actionId) {
      case 'snooze':
        _snoozeAlarm(alarmId);
        break;
      case 'dismiss':
        _dismissAlarm(alarmId);
        break;
      default:
        // Open app to main alarm screen
        break;
    }
  }

  /// Schedule a notification for an alarm
  Future<void> scheduleAlarmNotification(Alarm alarm) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = _calculateNextAlarmTime(alarm);
    if (scheduledDate == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      actions: const [
        AndroidNotificationAction(
          'snooze',
          'Snooze',
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.wav',
      categoryIdentifier: 'ALARM_CATEGORY',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      alarm.id.hashCode,
      'Alarm: ${alarm.label}',
      'Time to wake up!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelAlarmNotification(String alarmId) async {
    if (!_isInitialized) await initialize();
    await _notifications.cancel(alarmId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notifications.cancelAll();
  }

  /// Show immediate alarm notification (for testing)
  Future<void> showImmediateAlarm(Alarm alarm) async {
    if (!_isInitialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.wav',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      alarm.id.hashCode,
      'Alarm: ${alarm.label}',
      'Time to wake up!',
      details,
      payload: alarm.id,
    );
  }

  /// Calculate next alarm time based on alarm settings
  tz.TZDateTime? _calculateNextAlarmTime(Alarm alarm) {
    final now = tz.TZDateTime.now(tz.local);
    final timeParts = alarm.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the alarm time has passed today, schedule for next occurrence
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Handle repeat days
    if (alarm.repeatDays.isNotEmpty) {
      while (!alarm.repeatDays.contains(scheduledDate.weekday % 7)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  /// Snooze an alarm
  void _snoozeAlarm(String alarmId) {
    // Implementation for snoozing - will be handled by AlarmService
    // TODO: Integrate with AlarmService for snooze functionality
  }

  /// Dismiss an alarm
  void _dismissAlarm(String alarmId) {
    // Implementation for dismissing - will be handled by AlarmService
    // TODO: Integrate with AlarmService for dismiss functionality
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;

    if (androidImplementation != null) {
      granted = await androidImplementation.requestNotificationsPermission() ??
          false;
    }

    if (iosImplementation != null) {
      granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          ) ??
          false;
    }

    return granted;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return true; // iOS doesn't have a direct check method
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }
}