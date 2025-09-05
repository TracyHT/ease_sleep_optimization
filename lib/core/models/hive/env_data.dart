import 'package:hive/hive.dart';

part 'env_data.g.dart';

@HiveType(typeId: 4)
class EnvData extends HiveObject {
  @HiveField(0)
  int? sessionId;

  @HiveField(1)
  int? userId;

  @HiveField(2)
  DateTime? timestamp;

  @HiveField(3)
  String? sensorType;

  @HiveField(4)
  double? sensorValue;

  EnvData({
    this.sessionId,
    this.userId,
    this.timestamp,
    this.sensorType,
    this.sensorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'timestamp': timestamp?.toIso8601String(),
      'sensorType': sensorType,
      'sensorValue': sensorValue,
    };
  }

  factory EnvData.fromJson(Map<String, dynamic> json) {
    return EnvData(
      sessionId: json['sessionId'],
      userId: json['userId'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      sensorType: json['sensorType'],
      sensorValue: json['sensorValue']?.toDouble(),
    );
  }
}