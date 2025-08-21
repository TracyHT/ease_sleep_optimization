import 'package:hive/hive.dart';

part 'sleep_quality_metrics.g.dart';

@HiveType(typeId: 3)
class SleepQualityMetrics extends HiveObject {
  @HiveField(0)
  int? metricId;

  @HiveField(1)
  int? sessionId;

  @HiveField(2)
  DateTime? totalSleepTime;

  @HiveField(3)
  DateTime? sleepEfficiency;

  @HiveField(4)
  DateTime? sleepOnsetLatency;

  @HiveField(5)
  double? timeInWake;

  @HiveField(6)
  double? timeInN1;

  @HiveField(7)
  double? timeInN2;

  @HiveField(8)
  double? timeInN3;

  @HiveField(9)
  double? timeInREM;

  SleepQualityMetrics({
    this.metricId,
    this.sessionId,
    this.totalSleepTime,
    this.sleepEfficiency,
    this.sleepOnsetLatency,
    this.timeInWake,
    this.timeInN1,
    this.timeInN2,
    this.timeInN3,
    this.timeInREM,
  });

  Map<String, dynamic> toJson() {
    return {
      'metricId': metricId,
      'sessionId': sessionId,
      'totalSleepTime': totalSleepTime?.toIso8601String(),
      'sleepEfficiency': sleepEfficiency?.toIso8601String(),
      'sleepOnsetLatency': sleepOnsetLatency?.toIso8601String(),
      'timeInWake': timeInWake,
      'timeInN1': timeInN1,
      'timeInN2': timeInN2,
      'timeInN3': timeInN3,
      'timeInREM': timeInREM,
    };
  }

  factory SleepQualityMetrics.fromJson(Map<String, dynamic> json) {
    return SleepQualityMetrics(
      metricId: json['metricId'],
      sessionId: json['sessionId'],
      totalSleepTime: json['totalSleepTime'] != null ? DateTime.parse(json['totalSleepTime']) : null,
      sleepEfficiency: json['sleepEfficiency'] != null ? DateTime.parse(json['sleepEfficiency']) : null,
      sleepOnsetLatency: json['sleepOnsetLatency'] != null ? DateTime.parse(json['sleepOnsetLatency']) : null,
      timeInWake: json['timeInWake']?.toDouble(),
      timeInN1: json['timeInN1']?.toDouble(),
      timeInN2: json['timeInN2']?.toDouble(),
      timeInN3: json['timeInN3']?.toDouble(),
      timeInREM: json['timeInREM']?.toDouble(),
    );
  }
}