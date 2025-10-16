import '../models/sleep_summary_data.dart';
import 'local_database_service.dart';
import 'hive_service.dart';

/// Service for generating statistics from Hive database data
class StatisticsDataService {
  
  /// Get sleep summary data for a specific date
  static Future<SleepSummaryData?> getSleepDataForDate({
    required String firebaseUid,
    required DateTime date,
  }) async {
    try {
      // Get sleep sessions for the specific date
      final sessions = _getSleepSessionsForDate(firebaseUid, date);
      
      if (sessions.isEmpty) {
        return null; // No data for this date
      }
      
      // Find the main sleep session (longest or most recent)
      final mainSession = _getMainSleepSession(sessions);
      
      if (mainSession == null) {
        return null;
      }
      
      final sessionId = mainSession['sessionId'] as int;
      
      // Get sleep quality metrics for this session
      final metrics = await _getSleepQualityMetrics(sessionId);
      
      // Get sleep stage scoring data
      final stageScoring = LocalDatabaseService.getSleepStageScoring(sessionId);
      
      // Calculate comprehensive sleep summary
      return _calculateSleepSummary(mainSession, metrics, stageScoring);
      
    } catch (e) {
      print('Error getting sleep data for date: $e');
      return null;
    }
  }

  /// Get sleep trends for a date range (e.g., past week)
  static Future<List<SleepSummaryData>> getSleepTrend({
    required String firebaseUid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final List<SleepSummaryData> trendData = [];
      
      // Get data for each day in the range
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final dayData = await getSleepDataForDate(
          firebaseUid: firebaseUid,
          date: currentDate,
        );
        
        if (dayData != null) {
          trendData.add(dayData);
        }
        
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return trendData;
    } catch (e) {
      print('Error getting sleep trend: $e');
      return [];
    }
  }

  /// Get overall sleep statistics summary
  static Future<Map<String, dynamic>> getOverallStatistics(String firebaseUid) async {
    try {
      final allSessions = LocalDatabaseService.getUserSleepSessions(firebaseUid);
      
      if (allSessions.isEmpty) {
        return _getEmptyStatistics();
      }
      
      // Calculate averages and totals
      double totalSleepHours = 0;
      int totalSessions = allSessions.length;
      int totalScore = 0;
      int totalEfficiency = 0;
      int totalLatency = 0;
      int totalWaso = 0;
      
      DateTime? earliestDate;
      DateTime? latestDate;
      
      for (final session in allSessions) {
        final sessionId = session['sessionId'] as int;
        final startTime = DateTime.parse(session['startTime'] ?? '');
        final endTime = session['endTime'] != null 
            ? DateTime.parse(session['endTime']!)
            : null;
            
        // Track date range
        if (earliestDate == null || startTime.isBefore(earliestDate)) {
          earliestDate = startTime;
        }
        if (latestDate == null || startTime.isAfter(latestDate)) {
          latestDate = startTime;
        }
        
        if (endTime != null) {
          final duration = endTime.difference(startTime);
          totalSleepHours += duration.inMinutes / 60.0;
        }
        
        // Get metrics for this session
        final metrics = await _getSleepQualityMetrics(sessionId);
        final stageScoring = LocalDatabaseService.getSleepStageScoring(sessionId);
        final summary = _calculateSleepSummary(session, metrics, stageScoring);
        
        if (summary != null) {
          totalScore += summary.score;
          totalEfficiency += summary.efficiency;
          totalLatency += summary.latency;
          totalWaso += summary.waso;
        }
      }
      
      return {
        'totalSessions': totalSessions,
        'avgSleepHours': totalSleepHours / totalSessions,
        'avgScore': totalScore / totalSessions,
        'avgEfficiency': totalEfficiency / totalSessions,
        'avgLatency': totalLatency / totalSessions,
        'avgWaso': totalWaso / totalSessions,
        'totalSleepHours': totalSleepHours,
        'trackingDays': earliestDate != null && latestDate != null 
            ? latestDate.difference(earliestDate).inDays + 1
            : 0,
        'earliestDate': earliestDate,
        'latestDate': latestDate,
      };
      
    } catch (e) {
      print('Error getting overall statistics: $e');
      return _getEmptyStatistics();
    }
  }

  /// Get sleep stage distribution for a session
  static Map<String, double> getSleepStageDistribution(int sessionId) {
    try {
      final stageScoring = LocalDatabaseService.getSleepStageScoring(sessionId);
      
      if (stageScoring.isEmpty) {
        return {
          'Wake': 0.0,
          'N1': 0.0,
          'N2': 0.0,
          'N3': 0.0,
          'REM': 0.0,
        };
      }
      
      // Count epochs for each stage
      final stageCounts = <String, int>{};
      for (final scoring in stageScoring) {
        final stage = scoring['sleepStage'] as String;
        stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;
      }
      
      // Convert to percentages
      final totalEpochs = stageScoring.length;
      final stageDistribution = <String, double>{};
      
      stageCounts.forEach((stage, count) {
        stageDistribution[stage] = (count / totalEpochs) * 100;
      });
      
      return stageDistribution;
      
    } catch (e) {
      print('Error getting stage distribution: $e');
      return {};
    }
  }

  /// Get environmental timeline for a session
  static List<Map<String, dynamic>> getEnvironmentalTimeline(int sessionId) {
    try {
      final envData = LocalDatabaseService.getEnvironmentalDataForSession(sessionId);
      
      // Group by sensor type and create timeline events
      final timeline = <Map<String, dynamic>>[];
      
      for (final data in envData) {
        final sensorType = data['sensorType'] as String;
        final sensorValue = data['sensorValue'] as double;
        final timestamp = DateTime.parse(data['timestamp'] ?? '');
        
        // Create meaningful timeline entries
        String event = '';
        String description = '';
        
        switch (sensorType) {
          case 'temperature':
            if (sensorValue > 26) {
              event = 'Room too warm (${sensorValue.toStringAsFixed(1)}°C)';
              description = 'Temperature spike may affect sleep quality';
            } else if (sensorValue < 18) {
              event = 'Room too cold (${sensorValue.toStringAsFixed(1)}°C)';
              description = 'Low temperature detected';
            }
            break;
          case 'humidity':
            if (sensorValue > 60) {
              event = 'High humidity (${sensorValue.toStringAsFixed(1)}%)';
              description = 'Humidity level may cause discomfort';
            }
            break;
          case 'light':
            if (sensorValue > 10) {
              event = 'Light detected (${sensorValue.toStringAsFixed(1)} lux)';
              description = 'Ambient light may disrupt sleep';
            }
            break;
          case 'sound':
            if (sensorValue > 40) {
              event = 'Noise detected (${sensorValue.toStringAsFixed(1)} dB)';
              description = 'Sound disturbance recorded';
            }
            break;
        }
        
        if (event.isNotEmpty) {
          timeline.add({
            'time': timestamp,
            'event': event,
            'description': description,
            'sensorType': sensorType,
            'value': sensorValue,
          });
        }
      }
      
      // Sort by timestamp
      timeline.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
      
      return timeline;
      
    } catch (e) {
      print('Error getting environmental timeline: $e');
      return [];
    }
  }

  // Helper methods

  static List<Map<String, dynamic>> _getSleepSessionsForDate(String firebaseUid, DateTime date) {
    final allSessions = LocalDatabaseService.getUserSleepSessions(firebaseUid);
    
    print('Looking for sessions for date: ${date.toString().substring(0, 10)}');
    print('Found ${allSessions.length} total sessions for user');
    
    return allSessions.where((session) {
      final startTime = DateTime.parse(session['startTime'] ?? '');
      final endTime = session['endTime'] != null 
          ? DateTime.parse(session['endTime']!)
          : null;
          
      print('  Session ${session['sessionId']}: ${startTime.toString().substring(0, 10)} - ${endTime?.toString().substring(0, 10)}');
          
      // Check if the sleep session overlaps with the selected date
      // This handles cases where sleep starts on one day and ends on the next
      final sessionDate = DateTime(startTime.year, startTime.month, startTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      
      // Session matches if it starts on the target date OR if it ends on the day after target date
      // (representing sleep that happened on the night of the target date)
      final startsOnDate = sessionDate.isAtSameMomentAs(targetDate);
      final endsOnNextDay = endTime != null && 
          DateTime(endTime.year, endTime.month, endTime.day).isAtSameMomentAs(
            targetDate.add(const Duration(days: 1))
          );
      
      final matches = startsOnDate || endsOnNextDay;
      if (matches) {
        print('    ✅ Match found for session ${session['sessionId']}');
      }
      
      return matches;
    }).toList();
  }

  static Map<String, dynamic>? _getMainSleepSession(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) return null;
    
    // Find the longest session (best proxy for main sleep)
    Map<String, dynamic>? mainSession;
    Duration longestDuration = Duration.zero;
    
    for (final session in sessions) {
      final startTime = DateTime.parse(session['startTime'] ?? '');
      final endTime = session['endTime'] != null 
          ? DateTime.parse(session['endTime']!)
          : null;
          
      if (endTime != null) {
        final duration = endTime.difference(startTime);
        if (duration > longestDuration) {
          longestDuration = duration;
          mainSession = session;
        }
      }
    }
    
    return mainSession ?? sessions.first;
  }

  static Future<Map<String, dynamic>?> _getSleepQualityMetrics(int sessionId) async {
    try {
      final metricsBox = HiveService.sleepQualityMetrics;
      
      // Find metrics for this session
      for (final entry in metricsBox.toMap().entries) {
        final metrics = Map<String, dynamic>.from(entry.value as Map);
        if (metrics['sessionId'] == sessionId) {
          return metrics;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting sleep quality metrics: $e');
      return null;
    }
  }

  static SleepSummaryData? _calculateSleepSummary(
    Map<String, dynamic> session,
    Map<String, dynamic>? metrics,
    List<Map<String, dynamic>> stageScoring,
  ) {
    try {
      final startTime = DateTime.parse(session['startTime'] ?? '');
      final endTime = session['endTime'] != null 
          ? DateTime.parse(session['endTime']!)
          : null;
          
      if (endTime == null) {
        return null;
      }
      
      final totalSleep = endTime.difference(startTime);
      
      // Use metrics if available, otherwise calculate from stage scoring
      double timeInWake = metrics?['timeInWake'] ?? 0.0;
      double timeInN1 = metrics?['timeInN1'] ?? 0.0;
      double timeInN2 = metrics?['timeInN2'] ?? 0.0;
      double timeInN3 = metrics?['timeInN3'] ?? 0.0;
      double timeInREM = metrics?['timeInREM'] ?? 0.0;
      
      // If no metrics, calculate from stage scoring
      if (metrics == null && stageScoring.isNotEmpty) {
        final stageDistribution = getSleepStageDistribution(session['sessionId'] as int);
        timeInWake = stageDistribution['Wake'] ?? 0.0;
        timeInN1 = stageDistribution['N1'] ?? 0.0;
        timeInN2 = stageDistribution['N2'] ?? 0.0;
        timeInN3 = stageDistribution['N3'] ?? 0.0;
        timeInREM = stageDistribution['REM'] ?? 0.0;
      }
      
      // Calculate sleep efficiency (time asleep / time in bed)
      final timeAsleep = timeInN1 + timeInN2 + timeInN3 + timeInREM;
      final efficiency = timeAsleep.round(); // Already a percentage from stage distribution
      
      // Calculate sleep latency (assume first 30min of wake time is latency)
      final latency = (timeInWake * 0.3 * totalSleep.inMinutes / 100).round();
      
      // Calculate WASO (Wake After Sleep Onset)
      final waso = (timeInWake * 0.7 * totalSleep.inMinutes / 100).round();
      
      // Calculate sleep score (based on efficiency, deep sleep, REM)
      final deepSleepScore = (timeInN3 / 25 * 100).clamp(0, 100); // Target 25% deep sleep
      final remScore = (timeInREM / 20 * 100).clamp(0, 100); // Target 20% REM
      final efficiencyScore = efficiency.toDouble();
      
      final score = ((deepSleepScore * 0.4) + (remScore * 0.3) + (efficiencyScore * 0.3)).round();
      
      return SleepSummaryData(
        score: score.clamp(0, 100),
        totalSleep: totalSleep,
        efficiency: efficiency.clamp(0, 100),
        latency: latency.clamp(0, 60),
        waso: waso.clamp(0, 120),
      );
      
    } catch (e) {
      print('Error calculating sleep summary: $e');
      return null;
    }
  }

  static Map<String, dynamic> _getEmptyStatistics() {
    return {
      'totalSessions': 0,
      'avgSleepHours': 0.0,
      'avgScore': 0,
      'avgEfficiency': 0,
      'avgLatency': 0,
      'avgWaso': 0,
      'totalSleepHours': 0.0,
      'trackingDays': 0,
      'earliestDate': null,
      'latestDate': null,
    };
  }
}