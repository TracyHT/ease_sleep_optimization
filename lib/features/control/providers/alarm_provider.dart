import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/alarm.dart';
import '../../../services/alarm_service.dart';

// Provider for all alarms
final alarmsProvider = StateNotifierProvider<AlarmsNotifier, List<Alarm>>((ref) {
  return AlarmsNotifier();
});

// Provider for next alarm
final nextAlarmProvider = FutureProvider<Alarm?>((ref) async {
  // Refresh when alarms change
  ref.watch(alarmsProvider);
  return await AlarmService.getNextAlarm();
});

// Provider for active alarms
final activeAlarmsProvider = Provider<List<Alarm>>((ref) {
  final alarms = ref.watch(alarmsProvider);
  return alarms.where((alarm) => alarm.isActive).toList();
});

class AlarmsNotifier extends StateNotifier<List<Alarm>> {
  AlarmsNotifier() : super([]) {
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    state = await AlarmService.getAlarms();
  }

  Future<void> addAlarm(Alarm alarm) async {
    await AlarmService.addAlarm(alarm);
    await loadAlarms();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await AlarmService.updateAlarm(alarm);
    await loadAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    await AlarmService.deleteAlarm(id);
    await loadAlarms();
  }

  Future<void> toggleAlarmStatus(String id) async {
    await AlarmService.toggleAlarmStatus(id);
    await loadAlarms();
  }

  Future<void> initializeDefaultAlarms() async {
    await AlarmService.createDefaultAlarms();
    await loadAlarms();
  }
}