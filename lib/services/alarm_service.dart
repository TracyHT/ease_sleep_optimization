import '../core/models/alarm.dart';
import 'hive_service.dart';

class AlarmService {
  
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
    final alarmsBox = HiveService.alarms;
    await alarmsBox.put(alarm.id, alarm.toJson());
  }
  
  // Update existing alarm
  static Future<void> updateAlarm(Alarm alarm) async {
    final alarmsBox = HiveService.alarms;
    final updatedAlarm = alarm.copyWith(updatedAt: DateTime.now());
    await alarmsBox.put(alarm.id, updatedAlarm.toJson());
  }
  
  // Delete alarm
  static Future<void> deleteAlarm(String id) async {
    final alarmsBox = HiveService.alarms;
    await alarmsBox.delete(id);
  }
  
  // Toggle alarm active status
  static Future<void> toggleAlarmStatus(String id) async {
    final alarmsBox = HiveService.alarms;
    final alarmData = alarmsBox.get(id);
    
    if (alarmData != null) {
      final alarm = Alarm.fromJson(Map<String, dynamic>.from(alarmData));
      final updatedAlarm = alarm.copyWith(
        isActive: !alarm.isActive,
        updatedAt: DateTime.now(),
      );
      await alarmsBox.put(id, updatedAlarm.toJson());
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
}