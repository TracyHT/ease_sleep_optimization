import 'package:hive/hive.dart';

part 'eeg_raw_data.g.dart';

@HiveType(typeId: 2)
class EegRawData extends HiveObject {
  @HiveField(0)
  int? eegId;

  @HiveField(1)
  int? sessionId;

  @HiveField(2)
  int? deviceId;

  @HiveField(3)
  DateTime? startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  String? dataFilePath;

  EegRawData({
    this.eegId,
    this.sessionId,
    this.deviceId,
    this.startTime,
    this.endTime,
    this.dataFilePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'eegId': eegId,
      'sessionId': sessionId,
      'deviceId': deviceId,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'dataFilePath': dataFilePath,
    };
  }

  factory EegRawData.fromJson(Map<String, dynamic> json) {
    return EegRawData(
      eegId: json['eegId'],
      sessionId: json['sessionId'],
      deviceId: json['deviceId'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      dataFilePath: json['dataFilePath'],
    );
  }
}