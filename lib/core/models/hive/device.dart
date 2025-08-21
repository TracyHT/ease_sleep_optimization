import 'package:hive/hive.dart';

part 'device.g.dart';

@HiveType(typeId: 1)
class Device extends HiveObject {
  @HiveField(0)
  int? deviceId;

  @HiveField(1)
  String? firebaseUid;

  @HiveField(2)
  String? deviceType;

  @HiveField(3)
  String? deviceName;

  @HiveField(4)
  String? status;

  Device({
    this.deviceId,
    this.firebaseUid,
    this.deviceType,
    this.deviceName,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'firebaseUid': firebaseUid,
      'deviceType': deviceType,
      'deviceName': deviceName,
      'status': status,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'],
      firebaseUid: json['firebaseUid'],
      deviceType: json['deviceType'],
      deviceName: json['deviceName'],
      status: json['status'],
    );
  }
}