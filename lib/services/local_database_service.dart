import 'hive_service.dart';

/// Service layer for local database operations using Hive
/// This handles all sleep tracking data locally while user data goes to MongoDB
class LocalDatabaseService {
  
  // ===== SLEEP SESSIONS =====
  
  /// Save a new sleep session
  static Future<void> saveSleepSession({
    required String firebaseUid,
    required DateTime startTime,
    DateTime? endTime,
    int? sessionId,
  }) async {
    final sessionData = {
      'sessionId': sessionId ?? (1000 + HiveService.sleepSessions.length),
      'firebaseUid': firebaseUid,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await HiveService.saveSleepSession(sessionData);
  }

  /// Get all sleep sessions for the current user
  static List<Map<String, dynamic>> getUserSleepSessions(String firebaseUid) {
    return HiveService.getSleepSessionsForUser(firebaseUid);
  }

  /// Get the latest sleep session for a user
  static Map<String, dynamic>? getLatestSleepSession(String firebaseUid) {
    final sessions = getUserSleepSessions(firebaseUid);
    if (sessions.isEmpty) return null;
    
    sessions.sort((a, b) {
      final aTime = DateTime.parse(a['startTime'] ?? '1970-01-01');
      final bTime = DateTime.parse(b['startTime'] ?? '1970-01-01');
      return bTime.compareTo(aTime); // Most recent first
    });
    
    return sessions.first;
  }

  // ===== DEVICES =====
  
  /// Register a new device for the user
  static Future<void> registerDevice({
    required String firebaseUid,
    required String deviceType,
    required String deviceName,
    String status = 'active',
    int? deviceId,
  }) async {
    final deviceData = {
      'deviceId': deviceId ?? (2000 + HiveService.devices.length),
      'firebaseUid': firebaseUid,
      'deviceType': deviceType,
      'deviceName': deviceName,
      'status': status,
      'registeredAt': DateTime.now().toIso8601String(),
    };
    
    await HiveService.saveDevice(deviceData);
  }

  /// Get all devices for the current user
  static List<Map<String, dynamic>> getUserDevices(String firebaseUid) {
    return HiveService.getDevicesForUser(firebaseUid);
  }

  /// Get active devices for a user
  static List<Map<String, dynamic>> getActiveDevices(String firebaseUid) {
    return getUserDevices(firebaseUid)
        .where((device) => device['status'] == 'active')
        .toList();
  }

  // ===== EEG DATA =====
  
  /// Save EEG raw data
  static Future<void> saveEegData({
    required int sessionId,
    required int deviceId,
    required DateTime startTime,
    DateTime? endTime,
    String? dataFilePath,
    int? eegId,
  }) async {
    final eegData = {
      'eegId': eegId ?? (3000 + HiveService.eegRawData.length),
      'sessionId': sessionId,
      'deviceId': deviceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'dataFilePath': dataFilePath,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await HiveService.saveEegRawData(eegData);
  }

  /// Get EEG data for a specific session
  static List<Map<String, dynamic>> getEegDataForSession(int sessionId) {
    return HiveService.getEegDataForSession(sessionId);
  }

  // ===== SLEEP QUALITY METRICS =====
  
  /// Save sleep quality metrics
  static Future<void> saveSleepQualityMetrics({
    required int sessionId,
    DateTime? totalSleepTime,
    DateTime? sleepEfficiency,
    DateTime? sleepOnsetLatency,
    double? timeInWake,
    double? timeInN1,
    double? timeInN2,
    double? timeInN3,
    double? timeInREM,
    int? metricId,
  }) async {
    final metricsData = {
      'metricId': metricId ?? (4000 + HiveService.sleepQualityMetrics.length),
      'sessionId': sessionId,
      'totalSleepTime': totalSleepTime?.toIso8601String(),
      'sleepEfficiency': sleepEfficiency?.toIso8601String(),
      'sleepOnsetLatency': sleepOnsetLatency?.toIso8601String(),
      'timeInWake': timeInWake,
      'timeInN1': timeInN1,
      'timeInN2': timeInN2,
      'timeInN3': timeInN3,
      'timeInREM': timeInREM,
      'calculatedAt': DateTime.now().toIso8601String(),
    };
    
    await HiveService.saveSleepQualityMetrics(metricsData);
  }

  // ===== ENVIRONMENTAL DATA =====
  
  /// Save environmental sensor data
  static Future<void> saveEnvironmentalData({
    required int sessionId,
    required int userId,
    required String sensorType,
    required double sensorValue,
    DateTime? timestamp,
  }) async {
    final envData = {
      'sessionId': sessionId,
      'userId': userId,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'sensorType': sensorType,
      'sensorValue': sensorValue,
    };
    
    await HiveService.saveEnvData(envData);
  }

  /// Get environmental data for a session
  static List<Map<String, dynamic>> getEnvironmentalDataForSession(int sessionId) {
    return HiveService.getEnvDataForSession(sessionId);
  }

  // ===== SLEEP STAGES SCORING =====
  
  /// Save sleep stage scoring data
  static Future<void> saveSleepStageScoring({
    required int sessionId,
    required int epochIndex,
    required int confidence,
    required String sleepStage,
    DateTime? startTime,
    DateTime? endTime,
    int? scoreId,
  }) async {
    final scoringData = {
      'scoreId': scoreId ?? (5000 + HiveService.sleepStagesScoring.length),
      'sessionId': sessionId,
      'epochIndex': epochIndex,
      'confidence': confidence,
      'sleepStage': sleepStage,
      'startTime': (startTime ?? DateTime.now()).toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'analyzedAt': DateTime.now().toIso8601String(),
    };
    
    final key = '${sessionId}_${epochIndex}';
    await HiveService.sleepStagesScoring.put(key, scoringData);
  }

  /// Get sleep stage scoring for a session
  static List<Map<String, dynamic>> getSleepStageScoring(int sessionId) {
    return HiveService.sleepStagesScoring.values
        .where((scoring) => (scoring as Map)['sessionId'] == sessionId)
        .map((scoring) => Map<String, dynamic>.from(scoring as Map))
        .toList();
  }

  // ===== USER PREFERENCES =====
  
  /// Save user preferences locally
  static Future<void> saveUserPreference(String key, dynamic value) async {
    await HiveService.userPreferences.put(key, value);
  }

  /// Get user preference
  static T? getUserPreference<T>(String key, {T? defaultValue}) {
    return HiveService.userPreferences.get(key, defaultValue: defaultValue) as T?;
  }

  // ===== UTILITY METHODS =====
  
  /// Get total number of sleep sessions for user
  static int getTotalSleepSessions(String firebaseUid) {
    return getUserSleepSessions(firebaseUid).length;
  }

  /// Get sleep sessions within date range
  static List<Map<String, dynamic>> getSleepSessionsInRange({
    required String firebaseUid,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return getUserSleepSessions(firebaseUid).where((session) {
      final sessionStart = DateTime.parse(session['startTime'] ?? '1970-01-01');
      return sessionStart.isAfter(startDate) && sessionStart.isBefore(endDate);
    }).toList();
  }

  /// Clear all data for a specific user
  static Future<void> clearUserData(String firebaseUid) async {
    // Remove user's sleep sessions
    final sleepSessions = HiveService.sleepSessions;
    final keysToDelete = <dynamic>[];
    
    for (var entry in sleepSessions.toMap().entries) {
      final session = entry.value as Map<String, dynamic>;
      if (session['firebaseUid'] == firebaseUid) {
        keysToDelete.add(entry.key);
      }
    }
    
    for (var key in keysToDelete) {
      await sleepSessions.delete(key);
    }
    
    // Clear user's devices
    final devices = HiveService.devices;
    final deviceKeysToDelete = <dynamic>[];
    
    for (var entry in devices.toMap().entries) {
      final device = entry.value as Map<String, dynamic>;
      if (device['firebaseUid'] == firebaseUid) {
        deviceKeysToDelete.add(entry.key);
      }
    }
    
    for (var key in deviceKeysToDelete) {
      await devices.delete(key);
    }
    
    print('Cleared local data for user: $firebaseUid');
  }
}