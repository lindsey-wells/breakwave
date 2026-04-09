// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_settings.dart
// Purpose: BW-41 privacy lock settings model.
// Notes: Stores lock mode and a 4-digit passcode.
// ------------------------------------------------------------

import 'privacy_lock_mode.dart';

class PrivacyLockSettings {
  const PrivacyLockSettings({
    required this.mode,
    required this.passcode,
  });

  final PrivacyLockMode mode;
  final String passcode;

  bool get isEnabled => mode != PrivacyLockMode.none && passcode.length == 4;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mode': mode.storageValue,
      'passcode': passcode,
    };
  }

  factory PrivacyLockSettings.fromMap(Map<String, dynamic> map) {
    return PrivacyLockSettings(
      mode: PrivacyLockMode.fromStorage((map['mode'] ?? '').toString()),
      passcode: (map['passcode'] ?? '').toString(),
    );
  }

  PrivacyLockSettings copyWith({
    PrivacyLockMode? mode,
    String? passcode,
  }) {
    return PrivacyLockSettings(
      mode: mode ?? this.mode,
      passcode: passcode ?? this.passcode,
    );
  }

  static const PrivacyLockSettings defaults = PrivacyLockSettings(
    mode: PrivacyLockMode.none,
    passcode: '',
  );
}
