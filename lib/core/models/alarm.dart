class Alarm {
  final String id;
  final String time; // e.g., "07:30"
  final String label; // e.g., "Workday Wake"
  final String sound; // e.g., "Default"
  final bool snoozeEnabled; // e.g., true or false
  final int snoozeDuration; // in minutes
  final String alarmType; // e.g., "workdayWake"
  final bool isActive;
  final List<int> repeatDays; // 0 = Sunday, 1 = Monday, etc.
  final DateTime createdAt;
  final DateTime? updatedAt;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.sound,
    required this.snoozeEnabled,
    this.snoozeDuration = 5,
    required this.alarmType,
    this.isActive = true,
    required this.repeatDays,
    required this.createdAt,
    this.updatedAt,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      time: json['time'] as String,
      label: json['label'] as String,
      sound: json['sound'] as String,
      snoozeEnabled: json['snoozeEnabled'] as bool,
      snoozeDuration: json['snoozeDuration'] as int? ?? 5,
      alarmType: json['alarmType'] as String,
      isActive: json['isActive'] as bool? ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)?.cast<int>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'label': label,
      'sound': sound,
      'snoozeEnabled': snoozeEnabled,
      'snoozeDuration': snoozeDuration,
      'alarmType': alarmType,
      'isActive': isActive,
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Alarm copyWith({
    String? id,
    String? time,
    String? label,
    String? sound,
    bool? snoozeEnabled,
    int? snoozeDuration,
    String? alarmType,
    bool? isActive,
    List<int>? repeatDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      sound: sound ?? this.sound,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      alarmType: alarmType ?? this.alarmType,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
