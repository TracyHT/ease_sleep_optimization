import 'dart:math';
import 'local_database_service.dart';
import 'hive_service.dart';

/// Service for testing the Hive database functionality
class DatabaseTestService {
  static const String testUserId = 'test_user_12345';
  
  /// Run all database tests
  static Future<Map<String, dynamic>> runAllTests() async {
    final results = <String, dynamic>{};
    
    try {
      print('🔄 Starting database tests...\n');
      
      // Clear any existing test data
      await clearTestData();
      
      // Test 1: User Preferences
      results['userPreferences'] = await testUserPreferences();
      
      // Test 2: Sleep Sessions
      results['sleepSessions'] = await testSleepSessions();
      
      // Test 3: Devices
      results['devices'] = await testDevices();
      
      // Test 4: EEG Data
      results['eegData'] = await testEegData();
      
      // Test 5: Sleep Quality Metrics
      results['sleepQualityMetrics'] = await testSleepQualityMetrics();
      
      // Test 6: Environmental Data
      results['environmentalData'] = await testEnvironmentalData();
      
      // Test 7: Sleep Stage Scoring
      results['sleepStageScoring'] = await testSleepStageScoring();
      
      // Summary
      final passed = results.values.where((r) => r['success'] == true).length;
      final total = results.length;
      
      results['summary'] = {
        'totalTests': total,
        'passed': passed,
        'failed': total - passed,
        'success': passed == total,
      };
      
      print('\n✅ Database tests completed!');
      print('📊 Results: $passed/$total tests passed');
      
      return results;
    } catch (e) {
      print('❌ Test suite failed: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Test user preferences
  static Future<Map<String, dynamic>> testUserPreferences() async {
    try {
      print('🧪 Testing User Preferences...');
      
      // Save preferences
      await LocalDatabaseService.saveUserPreference('theme', 'dark');
      await LocalDatabaseService.saveUserPreference('notifications', true);
      await LocalDatabaseService.saveUserPreference('language', 'en');
      await LocalDatabaseService.saveUserPreference('sleepGoal', 8.5);
      
      // Retrieve preferences
      final theme = LocalDatabaseService.getUserPreference<String>('theme');
      final notifications = LocalDatabaseService.getUserPreference<bool>('notifications');
      final language = LocalDatabaseService.getUserPreference<String>('language');
      final sleepGoal = LocalDatabaseService.getUserPreference<double>('sleepGoal');
      
      final success = theme == 'dark' && 
                     notifications == true && 
                     language == 'en' && 
                     sleepGoal == 8.5;
      
      print(success ? '✅ User Preferences: PASSED' : '❌ User Preferences: FAILED');
      
      return {
        'success': success,
        'data': {
          'theme': theme,
          'notifications': notifications,
          'language': language,
          'sleepGoal': sleepGoal,
        }
      };
    } catch (e) {
      print('❌ User Preferences: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test sleep sessions
  static Future<Map<String, dynamic>> testSleepSessions() async {
    try {
      print('🧪 Testing Sleep Sessions...');
      
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Save test sleep sessions
      await LocalDatabaseService.saveSleepSession(
        firebaseUid: testUserId,
        startTime: yesterday.subtract(const Duration(hours: 8)),
        endTime: yesterday,
        sessionId: 1001,
      );
      
      await LocalDatabaseService.saveSleepSession(
        firebaseUid: testUserId,
        startTime: now.subtract(const Duration(hours: 7)),
        endTime: now.subtract(const Duration(hours: 1)),
        sessionId: 1002,
      );
      
      // Test retrieval
      final sessions = LocalDatabaseService.getUserSleepSessions(testUserId);
      final latestSession = LocalDatabaseService.getLatestSleepSession(testUserId);
      final totalSessions = LocalDatabaseService.getTotalSleepSessions(testUserId);
      
      final success = sessions.length == 2 && 
                     latestSession != null && 
                     totalSessions == 2;
      
      print(success ? '✅ Sleep Sessions: PASSED' : '❌ Sleep Sessions: FAILED');
      
      return {
        'success': success,
        'data': {
          'totalSessions': sessions.length,
          'latestSessionId': latestSession?['sessionId'],
          'sessionsCount': totalSessions,
        }
      };
    } catch (e) {
      print('❌ Sleep Sessions: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test devices
  static Future<Map<String, dynamic>> testDevices() async {
    try {
      print('🧪 Testing Devices...');
      
      // Register test devices
      await LocalDatabaseService.registerDevice(
        firebaseUid: testUserId,
        deviceType: 'EEG_Headband',
        deviceName: 'Muse S',
        deviceId: 2001,
      );
      
      await LocalDatabaseService.registerDevice(
        firebaseUid: testUserId,
        deviceType: 'Smartwatch',
        deviceName: 'Apple Watch',
        status: 'inactive',
        deviceId: 2002,
      );
      
      // Test retrieval
      final allDevices = LocalDatabaseService.getUserDevices(testUserId);
      final activeDevices = LocalDatabaseService.getActiveDevices(testUserId);
      
      final success = allDevices.length == 2 && activeDevices.length == 1;
      
      print(success ? '✅ Devices: PASSED' : '❌ Devices: FAILED');
      
      return {
        'success': success,
        'data': {
          'totalDevices': allDevices.length,
          'activeDevices': activeDevices.length,
        }
      };
    } catch (e) {
      print('❌ Devices: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test EEG data
  static Future<Map<String, dynamic>> testEegData() async {
    try {
      print('🧪 Testing EEG Data...');
      
      final now = DateTime.now();
      
      // Save EEG data
      await LocalDatabaseService.saveEegData(
        sessionId: 1001,
        deviceId: 2001,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 7)),
        dataFilePath: '/data/eeg/session_1001.csv',
        eegId: 3001,
      );
      
      await LocalDatabaseService.saveEegData(
        sessionId: 1001,
        deviceId: 2001,
        startTime: now.subtract(const Duration(hours: 7)),
        endTime: now.subtract(const Duration(hours: 6)),
        dataFilePath: '/data/eeg/session_1001_part2.csv',
        eegId: 3002,
      );
      
      // Test retrieval
      final eegData = LocalDatabaseService.getEegDataForSession(1001);
      
      final success = eegData.length == 2;
      
      print(success ? '✅ EEG Data: PASSED' : '❌ EEG Data: FAILED');
      
      return {
        'success': success,
        'data': {
          'eegRecords': eegData.length,
        }
      };
    } catch (e) {
      print('❌ EEG Data: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test sleep quality metrics
  static Future<Map<String, dynamic>> testSleepQualityMetrics() async {
    try {
      print('🧪 Testing Sleep Quality Metrics...');
      
      // Save sleep quality metrics
      await LocalDatabaseService.saveSleepQualityMetrics(
        sessionId: 1001,
        timeInWake: 0.15,
        timeInN1: 0.05,
        timeInN2: 0.45,
        timeInN3: 0.20,
        timeInREM: 0.15,
        metricId: 4001,
      );
      
      // Verify data was saved (we'll check the box directly)
      final metricsBox = HiveService.sleepQualityMetrics;
      final success = metricsBox.length > 0;
      
      print(success ? '✅ Sleep Quality Metrics: PASSED' : '❌ Sleep Quality Metrics: FAILED');
      
      return {
        'success': success,
        'data': {
          'metricsRecords': metricsBox.length,
        }
      };
    } catch (e) {
      print('❌ Sleep Quality Metrics: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test environmental data
  static Future<Map<String, dynamic>> testEnvironmentalData() async {
    try {
      print('🧪 Testing Environmental Data...');
      
      final random = Random();
      
      // Save various environmental readings
      await LocalDatabaseService.saveEnvironmentalData(
        sessionId: 1001,
        userId: 123,
        sensorType: 'temperature',
        sensorValue: 22.5,
      );
      
      await LocalDatabaseService.saveEnvironmentalData(
        sessionId: 1001,
        userId: 123,
        sensorType: 'humidity',
        sensorValue: 45.0,
      );
      
      await LocalDatabaseService.saveEnvironmentalData(
        sessionId: 1001,
        userId: 123,
        sensorType: 'light',
        sensorValue: 0.2,
      );
      
      // Test retrieval
      final envData = LocalDatabaseService.getEnvironmentalDataForSession(1001);
      
      final success = envData.length == 3;
      
      print(success ? '✅ Environmental Data: PASSED' : '❌ Environmental Data: FAILED');
      
      return {
        'success': success,
        'data': {
          'environmentalRecords': envData.length,
        }
      };
    } catch (e) {
      print('❌ Environmental Data: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test sleep stage scoring
  static Future<Map<String, dynamic>> testSleepStageScoring() async {
    try {
      print('🧪 Testing Sleep Stage Scoring...');
      
      final stages = ['Wake', 'N1', 'N2', 'N3', 'REM'];
      final random = Random();
      
      // Save sleep stage scoring for multiple epochs
      for (int epoch = 0; epoch < 10; epoch++) {
        await LocalDatabaseService.saveSleepStageScoring(
          sessionId: 1001,
          epochIndex: epoch,
          confidence: random.nextInt(100) + 1,
          sleepStage: stages[random.nextInt(stages.length)],
          scoreId: 5000 + epoch,
        );
      }
      
      // Test retrieval
      final stageScoring = LocalDatabaseService.getSleepStageScoring(1001);
      
      final success = stageScoring.length == 10;
      
      print(success ? '✅ Sleep Stage Scoring: PASSED' : '❌ Sleep Stage Scoring: FAILED');
      
      return {
        'success': success,
        'data': {
          'scoringRecords': stageScoring.length,
        }
      };
    } catch (e) {
      print('❌ Sleep Stage Scoring: ERROR - $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generate sample data for testing
  static Future<void> generateSampleData({int days = 7, String? firebaseUid}) async {
    try {
      print('🎲 Generating sample data for $days days...');
      
      // Use provided firebaseUid or fall back to test user
      final userId = firebaseUid ?? testUserId;
      final random = Random();
      final now = DateTime.now();
      
      for (int day = 0; day < days; day++) {
        final sessionDate = now.subtract(Duration(days: day));
        final sessionId = 1000 + day;
        
        // Create sleep session that represents sleeping on the night of sessionDate
        // Sleep starts on the evening of sessionDate and ends in the morning of the next day
        final sleepStart = DateTime(sessionDate.year, sessionDate.month, sessionDate.day, 22 + random.nextInt(2), random.nextInt(60));
        final sleepEnd = sleepStart.add(Duration(hours: 6 + random.nextInt(3), minutes: random.nextInt(60)));
        
        await LocalDatabaseService.saveSleepSession(
          firebaseUid: userId,
          startTime: sleepStart,
          endTime: sleepEnd,
          sessionId: sessionId,
        );
        
        // Add EEG data
        await LocalDatabaseService.saveEegData(
          sessionId: sessionId,
          deviceId: 2001,
          startTime: sleepStart,
          endTime: sleepEnd,
          dataFilePath: '/data/eeg/session_$sessionId.csv',
        );
        
        // Add sleep quality metrics
        await LocalDatabaseService.saveSleepQualityMetrics(
          sessionId: sessionId,
          timeInWake: 0.10 + random.nextDouble() * 0.10,
          timeInN1: 0.05 + random.nextDouble() * 0.05,
          timeInN2: 0.40 + random.nextDouble() * 0.10,
          timeInN3: 0.15 + random.nextDouble() * 0.10,
          timeInREM: 0.15 + random.nextDouble() * 0.10,
        );
        
        // Add environmental data
        final sensors = ['temperature', 'humidity', 'light', 'sound'];
        for (String sensor in sensors) {
          await LocalDatabaseService.saveEnvironmentalData(
            sessionId: sessionId,
            userId: 123,
            sensorType: sensor,
            sensorValue: random.nextDouble() * 100,
          );
        }
        
        // Add sleep stage scoring
        final stages = ['Wake', 'N1', 'N2', 'N3', 'REM'];
        for (int epoch = 0; epoch < 20; epoch++) {
          await LocalDatabaseService.saveSleepStageScoring(
            sessionId: sessionId,
            epochIndex: epoch,
            confidence: random.nextInt(100) + 1,
            sleepStage: stages[random.nextInt(stages.length)],
          );
        }
      }
      
      print('✅ Sample data generated successfully!');
    } catch (e) {
      print('❌ Failed to generate sample data: $e');
    }
  }

  /// Get database statistics
  static Map<String, dynamic> getDatabaseStats() {
    try {
      final stats = <String, dynamic>{};
      
      // Get counts for each box
      stats['sleepSessions'] = HiveService.sleepSessions.length;
      stats['devices'] = HiveService.devices.length;
      stats['eegRawData'] = HiveService.eegRawData.length;
      stats['sleepQualityMetrics'] = HiveService.sleepQualityMetrics.length;
      stats['envData'] = HiveService.envData.length;
      stats['sleepStagesScoring'] = HiveService.sleepStagesScoring.length;
      stats['eegFeatures'] = HiveService.eegFeatures.length;
      stats['envLog'] = HiveService.envLog.length;
      stats['userPreferences'] = HiveService.userPreferences.length;
      
      // Calculate totals
      stats['totalRecords'] = stats.values
          .where((v) => v is int)
          .fold<int>(0, (sum, count) => sum + (count as int));
      
      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Clear test data
  static Future<void> clearTestData() async {
    try {
      print('🧹 Clearing test data...');
      await LocalDatabaseService.clearUserData(testUserId);
      await HiveService.userPreferences.clear();
      print('✅ Test data cleared');
    } catch (e) {
      print('❌ Failed to clear test data: $e');
    }
  }

  /// Print database contents (for debugging)
  static void printDatabaseContents() {
    print('\n📊 DATABASE CONTENTS:');
    print('=' * 40);
    
    final stats = getDatabaseStats();
    for (String key in stats.keys) {
      if (key != 'totalRecords' && key != 'error') {
        print('$key: ${stats[key]} records');
      }
    }
    
    print('=' * 40);
    print('TOTAL RECORDS: ${stats['totalRecords']}');
    print('\n');
  }
}