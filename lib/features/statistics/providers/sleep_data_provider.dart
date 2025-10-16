import 'package:ease_sleep_optimization/core/models/sleep_summary_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'selected_date_provider.dart';
import '../../../core/services/statistics_data_service.dart';

final sleepDataProvider = FutureProvider<SleepSummaryData?>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  
  // Get current user
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return null;
  }

  // Get real sleep data from Hive database
  try {
    print('Loading sleep data for user ${currentUser.uid} on date ${selectedDate.toString().substring(0, 10)}');
    
    final sleepData = await StatisticsDataService.getSleepDataForDate(
      firebaseUid: currentUser.uid,
      date: selectedDate,
    );
    
    if (sleepData != null) {
      print('Found sleep data: score=${sleepData.score}, sleep=${sleepData.totalSleep}');
    } else {
      print('No sleep data found for this date');
    }
    
    return sleepData;
  } catch (e) {
    print('Error loading sleep data: $e');
    
    // Return null instead of mock data to show no-data state
    return null;
  }
});

// Fallback mock data for demonstration
SleepSummaryData _getMockDataForDate(DateTime date) {
  final mockData = {
    1: SleepSummaryData(
      score: 80,
      totalSleep: Duration(hours: 7, minutes: 40),
      efficiency: 75,
      latency: 14,
      waso: 20,
    ),
    2: SleepSummaryData(
      score: 65,
      totalSleep: Duration(hours: 6, minutes: 30),
      efficiency: 60,
      latency: 20,
      waso: 30,
    ),
    10: SleepSummaryData(
      score: 90,
      totalSleep: Duration(hours: 8, minutes: 10),
      efficiency: 85,
      latency: 10,
      waso: 15,
    ),
    11: SleepSummaryData(
      score: 78,
      totalSleep: Duration(hours: 7, minutes: 20),
      efficiency: 72,
      latency: 12,
      waso: 22,
    ),
  };

  return mockData[date.day] ?? mockData[10]!;
}
