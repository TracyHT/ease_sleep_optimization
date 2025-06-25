import 'package:ease_sleep_optimization/core/models/sleep_summary_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'selected_date_provider.dart';
import '../widgets/sleep_summary_widget.dart';

final sleepDataProvider = FutureProvider<SleepSummaryData>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);

  // TODO: gọi API hoặc DB để lấy data theo ngày
  // Tạm thời mock data theo ngày
  final mock = {
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

  await Future.delayed(const Duration(milliseconds: 500)); // simulate loading
  return mock[selectedDate.day] ?? mock[10]!;
});
