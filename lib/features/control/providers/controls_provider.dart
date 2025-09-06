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
        'brainbitStatus': 'Disconnected',
        'thermostatStatus': 'Disconnected',
        'lightStatus': 'Disconnected',
        'airQualityStatus': 'Disconnected',
        'soundStatus': 'Disconnected',
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

  // BrainBit EEG Device Methods
  void connectBrainBit() {
    state = {...state, 'brainbitStatus': 'Connected'};
    // TODO: Add actual BrainBit connection logic
  }

  void disconnectBrainBit() {
    state = {...state, 'brainbitStatus': 'Disconnected'};
    // TODO: Add actual BrainBit disconnection logic
  }

  // Smart Thermostat Methods
  void connectThermostat() {
    state = {...state, 'thermostatStatus': 'Connected'};
    // TODO: Add actual thermostat connection logic
  }

  void disconnectThermostat() {
    state = {...state, 'thermostatStatus': 'Disconnected'};
    // TODO: Add actual thermostat disconnection logic
  }

  // Smart Light Methods
  void connectSmartLight() {
    state = {...state, 'lightStatus': 'Connected'};
    // TODO: Add actual smart light connection logic
  }

  void disconnectSmartLight() {
    state = {...state, 'lightStatus': 'Disconnected'};
    // TODO: Add actual smart light disconnection logic
  }

  // Air Quality Monitor Methods
  void connectAirQuality() {
    state = {...state, 'airQualityStatus': 'Connected'};
    // TODO: Add actual air quality monitor connection logic
  }

  void disconnectAirQuality() {
    state = {...state, 'airQualityStatus': 'Disconnected'};
    // TODO: Add actual air quality monitor disconnection logic
  }

  // Sound Controller Methods
  void connectSoundController() {
    state = {...state, 'soundStatus': 'Connected'};
    // TODO: Add actual sound controller connection logic
  }

  void disconnectSoundController() {
    state = {...state, 'soundStatus': 'Disconnected'};
    // TODO: Add actual sound controller disconnection logic
  }
}
