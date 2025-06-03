class Alarm {
  final String time; // e.g., "07:30"
  final String label; // e.g., "Workday Wake"
  final String sound; // e.g., "Default"
  final bool snoozeEnabled; // e.g., true or false
  final String alarmType; // e.g., "workdayWake"

  Alarm({
    required this.time,
    required this.label,
    required this.sound,
    required this.snoozeEnabled,
    required this.alarmType,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      time: json['time'] as String,
      label: json['label'] as String,
      sound: json['sound'] as String,
      snoozeEnabled: json['snoozeEnabled'] as bool,
      alarmType: json['alarmType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'label': label,
      'sound': sound,
      'snoozeEnabled': snoozeEnabled,
      'alarmType': alarmType,
    };
  }
}
