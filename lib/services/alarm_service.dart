import 'package:alarm/alarm.dart' as alarm_plugin;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/models/alarm.dart';
import 'hive_service.dart';
import 'notification_service.dart';

class AlarmService {
  static bool _isInitialized = false;
  static final NotificationService _notificationService = NotificationService();

  /// Initialize the alarm service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize the alarm plugin
    await alarm_plugin.Alarm.init();

    // Initialize notification service
    await _notificationService.initialize();

    // Set up alarm stream listener
    alarm_plugin.Alarm.ringStream.stream.listen(_onAlarmRinging);

    _isInitialized = true;
  }

  /// Handle alarm ringing
  static void _onAlarmRinging(alarm_plugin.AlarmSettings alarmSettings) {
    // This will be called when an alarm starts ringing
    // Find the alarm in our database
    _showAlarmRingingScreen(alarmSettings.id.toString());
  }

  /// Show alarm ringing screen
  static void _showAlarmRingingScreen(String alarmId) async {
    // This method will be called from the main app's navigator
    // We'll create a callback system for this
    if (_onAlarmRingingCallback != null) {
      _onAlarmRingingCallback!(alarmId);
    }
  }

  // Callback for showing alarm screen
  static Function(String)? _onAlarmRingingCallback;

  /// Set callback for alarm ringing
  static void setAlarmRingingCallback(Function(String) callback) {
    _onAlarmRingingCallback = callback;
  }

  // Get all alarms
  static Future<List<Alarm>> getAlarms() async {
    final alarmsBox = HiveService.alarms;
    final List<Alarm> alarms = [];
    
    for (var key in alarmsBox.keys) {
      final alarmData = alarmsBox.get(key);
      if (alarmData != null) {
        alarms.add(Alarm.fromJson(Map<String, dynamic>.from(alarmData)));
      }
    }
    
    // Sort by creation date
    alarms.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return alarms;
  }
  
  // Get active alarms only
  static Future<List<Alarm>> getActiveAlarms() async {
    final alarms = await getAlarms();
    return alarms.where((alarm) => alarm.isActive).toList();
  }
  
  // Get alarm by id
  static Future<Alarm?> getAlarmById(String id) async {
    final alarms = await getAlarms();
    try {
      return alarms.firstWhere((alarm) => alarm.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Add new alarm
  static Future<void> addAlarm(Alarm alarm) async {
    if (!_isInitialized) await initialize();

    final alarmsBox = HiveService.alarms;
    await alarmsBox.put(alarm.id, alarm.toJson());

    // Schedule the actual alarm if it's active
    if (alarm.isActive) {
      await _scheduleSystemAlarm(alarm);
      await _notificationService.scheduleAlarmNotification(alarm);
    }
  }
  
  // Update existing alarm
  static Future<void> updateAlarm(Alarm alarm) async {
    if (!_isInitialized) await initialize();

    final alarmsBox = HiveService.alarms;
    final updatedAlarm = alarm.copyWith(updatedAt: DateTime.now());
    await alarmsBox.put(alarm.id, updatedAlarm.toJson());

    // Cancel existing alarm and reschedule if active
    await _cancelSystemAlarm(alarm.id);
    await _notificationService.cancelAlarmNotification(alarm.id);

    if (updatedAlarm.isActive) {
      await _scheduleSystemAlarm(updatedAlarm);
      await _notificationService.scheduleAlarmNotification(updatedAlarm);
    }
  }
  
  // Delete alarm
  static Future<void> deleteAlarm(String id) async {
    if (!_isInitialized) await initialize();

    final alarmsBox = HiveService.alarms;

    // Cancel system alarm and notification
    await _cancelSystemAlarm(id);
    await _notificationService.cancelAlarmNotification(id);

    await alarmsBox.delete(id);
  }
  
  // Toggle alarm active status
  static Future<void> toggleAlarmStatus(String id) async {
    if (!_isInitialized) await initialize();

    final alarmsBox = HiveService.alarms;
    final alarmData = alarmsBox.get(id);

    if (alarmData != null) {
      final alarm = Alarm.fromJson(Map<String, dynamic>.from(alarmData));
      final updatedAlarm = alarm.copyWith(
        isActive: !alarm.isActive,
        updatedAt: DateTime.now(),
      );
      await alarmsBox.put(id, updatedAlarm.toJson());

      // Handle system alarm scheduling
      if (updatedAlarm.isActive) {
        await _scheduleSystemAlarm(updatedAlarm);
        await _notificationService.scheduleAlarmNotification(updatedAlarm);
      } else {
        await _cancelSystemAlarm(id);
        await _notificationService.cancelAlarmNotification(id);
      }
    }
  }
  
  // Get next alarm time
  static Future<Alarm?> getNextAlarm() async {
    final activeAlarms = await getActiveAlarms();
    if (activeAlarms.isEmpty) return null;
    
    final now = DateTime.now();
    Alarm? nextAlarm;
    Duration? shortestDuration;
    
    for (final alarm in activeAlarms) {
      final alarmTime = _parseTimeString(alarm.time);
      DateTime nextAlarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarmTime.hour,
        alarmTime.minute,
      );
      
      // If alarm time has passed today, set it for tomorrow
      if (nextAlarmDateTime.isBefore(now)) {
        nextAlarmDateTime = nextAlarmDateTime.add(const Duration(days: 1));
      }
      
      // Check repeat days
      if (alarm.repeatDays.isNotEmpty) {
        // Find the next valid day
        while (!alarm.repeatDays.contains(nextAlarmDateTime.weekday % 7)) {
          nextAlarmDateTime = nextAlarmDateTime.add(const Duration(days: 1));
        }
      }
      
      final duration = nextAlarmDateTime.difference(now);
      if (shortestDuration == null || duration < shortestDuration) {
        shortestDuration = duration;
        nextAlarm = alarm;
      }
    }
    
    return nextAlarm;
  }
  
  // Private helper methods
  
  static DateTime _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2024, 1, 1, hour, minute);
  }
  
  // Create default alarms for first time users
  static Future<void> createDefaultAlarms() async {
    final alarms = await getAlarms();
    if (alarms.isEmpty) {
      final defaultAlarms = [
        Alarm(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          time: '07:00',
          label: 'Workday Wake',
          sound: 'Gentle Rise',
          snoozeEnabled: true,
          snoozeDuration: 5,
          alarmType: 'workday',
          isActive: true,
          repeatDays: [1, 2, 3, 4, 5], // Monday to Friday
          createdAt: DateTime.now(),
        ),
        Alarm(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          time: '09:00',
          label: 'Weekend Chill',
          sound: 'Soft Bells',
          snoozeEnabled: true,
          snoozeDuration: 10,
          alarmType: 'weekend',
          isActive: true,
          repeatDays: [0, 6], // Sunday and Saturday
          createdAt: DateTime.now(),
        ),
      ];
      
      for (final alarm in defaultAlarms) {
        await addAlarm(alarm);
      }
    }
  }

  /// Schedule system alarm using alarm plugin
  static Future<void> _scheduleSystemAlarm(Alarm alarm) async {
    final nextAlarmDateTime = _calculateNextAlarmDateTime(alarm);
    if (nextAlarmDateTime == null) return;

    final alarmSettings = alarm_plugin.AlarmSettings(
      id: alarm.id.hashCode,
      dateTime: nextAlarmDateTime,
      assetAudioPath: _getAlarmSoundPath(alarm.sound),
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'Alarm: ${alarm.label}',
      notificationBody: 'Time to wake up!',
      enableNotificationOnKill: true,
    );

    await alarm_plugin.Alarm.set(alarmSettings: alarmSettings);
  }

  /// Cancel system alarm
  static Future<void> _cancelSystemAlarm(String alarmId) async {
    await alarm_plugin.Alarm.stop(alarmId.hashCode);
  }

  /// Calculate next alarm date time
  static DateTime? _calculateNextAlarmDateTime(Alarm alarm) {
    final now = DateTime.now();
    final timeParts = alarm.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    var scheduledDate = DateTime(
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

  /// Get alarm sound path
  static String _getAlarmSoundPath(String soundName) {
    // Map sound names to asset paths
    const soundMap = {
      'Gentle Rise': 'assets/audio/alarms/gentle_rise.mp3',
      'Soft Bells': 'assets/audio/alarms/soft_bells.mp3',
      'Morning Birds': 'assets/audio/alarms/morning_birds.mp3',
      'Ocean Waves': 'assets/audio/alarms/ocean_waves.mp3',
      'Classic Alarm': 'assets/audio/alarms/classic_alarm.mp3',
      'Digital Beep': 'assets/audio/alarms/digital_beep.mp3',
    };

    return soundMap[soundName] ?? 'assets/audio/alarms/gentle_rise.mp3';
  }

  /// Snooze alarm
  static Future<void> snoozeAlarm(String alarmId, int snoozeDuration) async {
    // Stop current alarm
    await _cancelSystemAlarm(alarmId);

    // Get alarm details
    final alarm = await getAlarmById(alarmId);
    if (alarm == null) return;

    // Schedule snooze alarm
    final snoozeDateTime = DateTime.now().add(Duration(minutes: snoozeDuration));

    final alarmSettings = alarm_plugin.AlarmSettings(
      id: '${alarmId}_snooze'.hashCode,
      dateTime: snoozeDateTime,
      assetAudioPath: _getAlarmSoundPath(alarm.sound),
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'Snooze: ${alarm.label}',
      notificationBody: 'Snooze time is up!',
      enableNotificationOnKill: true,
    );

    await alarm_plugin.Alarm.set(alarmSettings: alarmSettings);
  }

  /// Dismiss alarm
  static Future<void> dismissAlarm(String alarmId) async {
    await _cancelSystemAlarm(alarmId);
    // Also cancel any snooze alarms
    await alarm_plugin.Alarm.stop('${alarmId}_snooze'.hashCode);
  }

  /// Check if alarm is currently ringing
  static bool isAlarmRinging(String alarmId) {
    return alarm_plugin.Alarm.getAlarms().any((alarm) => alarm.id == alarmId.hashCode);
  }

  /// Get all currently set system alarms
  static List<alarm_plugin.AlarmSettings> getSystemAlarms() {
    return alarm_plugin.Alarm.getAlarms();
  }

  /// Show immediate test alarm (for testing purposes)
  static Future<void> showImmediateTestAlarm(String alarmId) async {
    // Get alarm details
    final alarm = await getAlarmById(alarmId);
    if (alarm == null) return;

    // Schedule an alarm for 3 seconds from now
    final immediateDateTime = DateTime.now().add(const Duration(seconds: 3));

    final alarmSettings = alarm_plugin.AlarmSettings(
      id: '${alarmId}_immediate'.hashCode,
      dateTime: immediateDateTime,
      assetAudioPath: _getAlarmSoundPath(alarm.sound),
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationTitle: 'Test Alarm: ${alarm.label}',
      notificationBody: 'This is a test alarm!',
      enableNotificationOnKill: true,
    );

    await alarm_plugin.Alarm.set(alarmSettings: alarmSettings);
  }
}