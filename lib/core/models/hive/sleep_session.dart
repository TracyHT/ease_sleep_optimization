import 'package:hive/hive.dart';

part 'sleep_session.g.dart';

@HiveType(typeId: 0)
class SleepSession extends HiveObject {
  @HiveField(0)
  int? sessionId;

  @HiveField(1)
  String? firebaseUid;

  @HiveField(2)
  DateTime? startTime;

  @HiveField(3)
  DateTime? endTime;

  SleepSession({
    this.sessionId,
    this.firebaseUid,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'firebaseUid': firebaseUid,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      sessionId: json['sessionId'],
      firebaseUid: json['firebaseUid'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}