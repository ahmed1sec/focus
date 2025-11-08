import 'dart:convert';

class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int focusDuration; // in minutes
  final int breakDuration; // in minutes
  final bool isCompleted;

  PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.focusDuration,
    required this.breakDuration,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'focusDuration': focusDuration,
      'breakDuration': breakDuration,
      'isCompleted': isCompleted,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      focusDuration: map['focusDuration'],
      breakDuration: map['breakDuration'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PomodoroSession.fromJson(String source) =>
      PomodoroSession.fromMap(json.decode(source));
}

class PomodoroSettings {
  int focusDuration; // in minutes
  int breakDuration; // in minutes
  bool autoStartBreak;
  bool autoStartFocus;
  String? backgroundSound;

  PomodoroSettings({
    this.focusDuration = 25,
    this.breakDuration = 5,
    this.autoStartBreak = false,
    this.autoStartFocus = false,
    this.backgroundSound,
  });

  Map<String, dynamic> toMap() {
    return {
      'focusDuration': focusDuration,
      'breakDuration': breakDuration,
      'autoStartBreak': autoStartBreak,
      'autoStartFocus': autoStartFocus,
      'backgroundSound': backgroundSound,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      focusDuration: map['focusDuration'] ?? 25,
      breakDuration: map['breakDuration'] ?? 5,
      autoStartBreak: map['autoStartBreak'] ?? false,
      autoStartFocus: map['autoStartFocus'] ?? false,
      backgroundSound: map['backgroundSound'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PomodoroSettings.fromJson(String source) =>
      PomodoroSettings.fromMap(json.decode(source));
}

