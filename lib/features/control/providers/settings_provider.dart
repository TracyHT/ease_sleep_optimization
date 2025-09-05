import 'package:flutter_riverpod/flutter_riverpod.dart';

final userSettingsProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {
    'sleepTrackingEnabled': true,
    'soundVolume': 50.0,
    'lightIntensity': 30.0,
  },
);
