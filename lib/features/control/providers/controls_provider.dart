import 'package:flutter_riverpod/flutter_riverpod.dart';

final controlsProvider =
    StateNotifierProvider<ControlsNotifier, Map<String, dynamic>>((ref) {
      return ControlsNotifier({
        'devicesConnected': 2,
        'workdayWake': '07:00',
        'weekendChill': '09:00',
        'powerfulNap': '14:00',
        'environment': {
          'temperature': '22°C',
          'humidity': '45%',
          'light': 'Low',
          'noise': 'Quiet',
        },
        'connectedDevices': [
          {'name': 'Sleep Monitor', 'status': 'Online'},
          {'name': 'Smart Light', 'status': 'Offline'},
        ],
      });
    });

class ControlsNotifier extends StateNotifier<Map<String, dynamic>> {
  ControlsNotifier(super.state);

  void updateAlarm(String alarmType, String value) {
    state = {...state, alarmType.toLowerCase(): value};
  }
}
