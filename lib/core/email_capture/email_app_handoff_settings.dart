// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_app_handoff_settings.dart
// Purpose: BW-44B email app handoff settings model.
// Notes: Stores one optional BreakWave team email address locally.
// ------------------------------------------------------------

class EmailAppHandoffSettings {
  const EmailAppHandoffSettings({
    required this.teamEmailAddress,
  });

  final String teamEmailAddress;

  bool get hasRecipient =>
      teamEmailAddress.contains('@') && teamEmailAddress.contains('.');

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'teamEmailAddress': teamEmailAddress,
    };
  }

  factory EmailAppHandoffSettings.fromMap(Map<String, dynamic> map) {
    return EmailAppHandoffSettings(
      teamEmailAddress: (map['teamEmailAddress'] ?? '').toString(),
    );
  }

  static const EmailAppHandoffSettings defaults =
      EmailAppHandoffSettings(teamEmailAddress: '');
}
