// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_configuration.dart
// Purpose: IOS-G2B non-secret privacy lock configuration model.
// Notes: Credential material must never be stored in this model.
// ------------------------------------------------------------

import 'privacy_lock_mode.dart';

class PrivacyLockConfiguration {
  const PrivacyLockConfiguration({
    required this.mode,
    required this.biometricEnabled,
    required this.credentialConfigured,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 2;

  final PrivacyLockMode mode;
  final bool biometricEnabled;
  final bool credentialConfigured;
  final int schemaVersion;

  bool get isEnabled =>
      mode != PrivacyLockMode.none && credentialConfigured;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mode': mode.storageValue,
      'biometricEnabled': biometricEnabled,
      'credentialConfigured': credentialConfigured,
      'schemaVersion': schemaVersion,
    };
  }

  factory PrivacyLockConfiguration.fromMap(Map<String, dynamic> map) {
    final bool credentialConfigured =
        map['credentialConfigured'] == true;
    final Object? rawSchemaVersion = map['schemaVersion'];
    final String rawMode = (map['mode'] ?? '').toString();

    final PrivacyLockMode mode;
    switch (rawMode) {
      case 'none':
        mode = PrivacyLockMode.none;
      case 'fullApp':
        mode = PrivacyLockMode.fullApp;
      case 'sensitiveSections':
        mode = PrivacyLockMode.sensitiveSections;
      default:
        mode = credentialConfigured
            ? PrivacyLockMode.fullApp
            : PrivacyLockMode.none;
    }

    return PrivacyLockConfiguration(
      mode: mode,
      biometricEnabled:
          credentialConfigured && map['biometricEnabled'] == true,
      credentialConfigured: credentialConfigured,
      schemaVersion: rawSchemaVersion is int
          ? rawSchemaVersion
          : currentSchemaVersion,
    );
  }

  PrivacyLockConfiguration copyWith({
    PrivacyLockMode? mode,
    bool? biometricEnabled,
    bool? credentialConfigured,
    int? schemaVersion,
  }) {
    final bool nextCredentialConfigured =
        credentialConfigured ?? this.credentialConfigured;
    final bool nextBiometricEnabled =
        biometricEnabled ?? this.biometricEnabled;

    return PrivacyLockConfiguration(
      mode: mode ?? this.mode,
      biometricEnabled:
          nextCredentialConfigured && nextBiometricEnabled,
      credentialConfigured: nextCredentialConfigured,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  static const PrivacyLockConfiguration defaults =
      PrivacyLockConfiguration(
    mode: PrivacyLockMode.none,
    biometricEnabled: false,
    credentialConfigured: false,
  );
}
