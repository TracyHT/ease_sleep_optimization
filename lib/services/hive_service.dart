import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Box names - keeping them organized based on your database schema
  static const String sleepSessionsBox = 'sleep_sessions';
  static const String devicesBox = 'devices';
  static const String eegRawDataBox = 'eeg_raw_data';
  static const String sleepQualityMetricsBox = 'sleep_quality_metrics';
  static const String envDataBox = 'env_data';
  static const String sleepStagesScoringBox = 'sleep_stages_scoring';
  static const String eegFeaturesBox = 'eeg_features';
  static const String envLogBox = 'env_log';
  static const String userPreferencesBox = 'user_preferences';
  static const String alarmsBox = 'alarms';

  static Future<void> initialize() async {
    // Open boxes - using generic boxes for now (can be upgraded to typed boxes later)
    await Hive.openBox(sleepSessionsBox);
    await Hive.openBox(devicesBox);
    await Hive.openBox(eegRawDataBox);
    await Hive.openBox(sleepQualityMetricsBox);
    await Hive.openBox(envDataBox);
    await Hive.openBox(sleepStagesScoringBox);
    await Hive.openBox(eegFeaturesBox);
    await Hive.openBox(envLogBox);
    await Hive.openBox(userPreferencesBox);
    await Hive.openBox(alarmsBox);
    
    print('Hive initialized successfully');
  }

  // Generic method to get a box
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  // Specific getters for each box type
  static Box get sleepSessions => Hive.box(sleepSessionsBox);
  static Box get devices => Hive.box(devicesBox);
  static Box get eegRawData => Hive.box(eegRawDataBox);
  static Box get sleepQualityMetrics => Hive.box(sleepQualityMetricsBox);
  static Box get envData => Hive.box(envDataBox);
  static Box get sleepStagesScoring => Hive.box(sleepStagesScoringBox);
  static Box get eegFeatures => Hive.box(eegFeaturesBox);
  static Box get envLog => Hive.box(envLogBox);
  static Box get userPreferences => Hive.box(userPreferencesBox);
  static Box get alarms => Hive.box(alarmsBox);

  // Helper methods for common operations
  static Future<void> clearAllData() async {
    final boxesToClear = [
      sleepSessionsBox, devicesBox, eegRawDataBox, sleepQualityMetricsBox,
      envDataBox, sleepStagesScoringBox, eegFeaturesBox, envLogBox, userPreferencesBox, alarmsBox
    ];
    
    for (String boxName in boxesToClear) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
    print('All Hive data cleared');
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }

  // Utility methods for common database operations
  
  // Save sleep session
  static Future<void> saveSleepSession(Map<String, dynamic> sessionData) async {
    final key = sessionData['sessionId'] ?? (1000 + sleepSessions.length);
    await sleepSessions.put(key, sessionData);
  }

  // Get all sleep sessions for a user
  static List<Map<String, dynamic>> getSleepSessionsForUser(String firebaseUid) {
    return sleepSessions.values
        .where((session) => (session as Map)['firebaseUid'] == firebaseUid)
        .map((session) => Map<String, dynamic>.from(session as Map))
        .toList();
  }

  // Save device
  static Future<void> saveDevice(Map<String, dynamic> deviceData) async {
    final key = deviceData['deviceId'] ?? (2000 + devices.length);
    await devices.put(key, deviceData);
  }

  // Get devices for user
  static List<Map<String, dynamic>> getDevicesForUser(String firebaseUid) {
    return devices.values
        .where((device) => (device as Map)['firebaseUid'] == firebaseUid)
        .map((device) => Map<String, dynamic>.from(device as Map))
        .toList();
  }

  // Save EEG data
  static Future<void> saveEegRawData(Map<String, dynamic> eegData) async {
    final key = eegData['eegId'] ?? (3000 + eegRawData.length);
    await eegRawData.put(key, eegData);
  }

  // Get EEG data for session
  static List<Map<String, dynamic>> getEegDataForSession(int sessionId) {
    return eegRawData.values
        .where((eeg) => (eeg as Map)['sessionId'] == sessionId)
        .map((eeg) => Map<String, dynamic>.from(eeg as Map))
        .toList();
  }

  // Save sleep quality metrics
  static Future<void> saveSleepQualityMetrics(Map<String, dynamic> metricsData) async {
    final key = metricsData['metricId'] ?? (4000 + sleepQualityMetrics.length);
    await sleepQualityMetrics.put(key, metricsData);
  }

  // Save environmental data
  static Future<void> saveEnvData(Map<String, dynamic> envDataMap) async {
    final key = envData.length; // Use length as key to avoid large numbers
    await envData.put(key, envDataMap);
  }

  // Get environmental data for session
  static List<Map<String, dynamic>> getEnvDataForSession(int sessionId) {
    return envData.values
        .where((env) => (env as Map)['sessionId'] == sessionId)
        .map((env) => Map<String, dynamic>.from(env as Map))
        .toList();
  }

  // Debug method to view all records in any box
  static void debugPrintBoxContents(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      print('=== $boxName Box Contents ===');
      print('Total records: ${box.length}');
      
      if (box.isEmpty) {
        print('Box is empty');
      } else {
        box.keys.forEach((key) {
          final value = box.get(key);
          print('Key: $key');
          print('Value: $value');
          print('---');
        });
      }
      print('=== End of $boxName ===\n');
    } else {
      print('Box $boxName is not open');
    }
  }

  // Debug all boxes
  static void debugPrintAllBoxes() {
    const allBoxes = [
      sleepSessionsBox, devicesBox, eegRawDataBox, sleepQualityMetricsBox,
      envDataBox, sleepStagesScoringBox, eegFeaturesBox, envLogBox, 
      userPreferencesBox, alarmsBox
    ];
    
    for (String boxName in allBoxes) {
      debugPrintBoxContents(boxName);
    }
  }
}