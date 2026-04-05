// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: reminder_settings.dart
// Purpose: BW-22 reminder settings model.
// Notes: Stores local reminder and risky-time nudge settings.
// ------------------------------------------------------------

class ReminderSettings {
  const ReminderSettings({
    required this.dailyReminderEnabled,
    required this.dailyHour,
    required this.dailyMinute,
    required this.riskyNudgeEnabled,
    required this.riskyHour,
    required this.riskyMinute,
  });

  final bool dailyReminderEnabled;
  final int dailyHour;
  final int dailyMinute;
  final bool riskyNudgeEnabled;
  final int riskyHour;
  final int riskyMinute;

  static const ReminderSettings defaults = ReminderSettings(
    dailyReminderEnabled: false,
    dailyHour: 9,
    dailyMinute: 0,
    riskyNudgeEnabled: false,
    riskyHour: 21,
    riskyMinute: 30,
  );

  ReminderSettings copyWith({
    bool? dailyReminderEnabled,
    int? dailyHour,
    int? dailyMinute,
    bool? riskyNudgeEnabled,
    int? riskyHour,
    int? riskyMinute,
  }) {
    return ReminderSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      riskyNudgeEnabled: riskyNudgeEnabled ?? this.riskyNudgeEnabled,
      riskyHour: riskyHour ?? this.riskyHour,
      riskyMinute: riskyMinute ?? this.riskyMinute,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyHour': dailyHour,
      'dailyMinute': dailyMinute,
      'riskyNudgeEnabled': riskyNudgeEnabled,
      'riskyHour': riskyHour,
      'riskyMinute': riskyMinute,
    };
  }

  factory ReminderSettings.fromMap(Map<String, dynamic> map) {
    return ReminderSettings(
      dailyReminderEnabled: map['dailyReminderEnabled'] == true,
      dailyHour: (map['dailyHour'] as num?)?.toInt() ?? 9,
      dailyMinute: (map['dailyMinute'] as num?)?.toInt() ?? 0,
      riskyNudgeEnabled: map['riskyNudgeEnabled'] == true,
      riskyHour: (map['riskyHour'] as num?)?.toInt() ?? 21,
      riskyMinute: (map['riskyMinute'] as num?)?.toInt() ?? 30,
    );
  }
}
