// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: legacy_android_privacy_credential_gateway.dart
// Purpose: IOS-G2C compatibility adapter for released Android lock storage.
// Notes:
// - TEMPORARY migration boundary.
// - Preserves current Android credential behavior during IOS-G2.
// - This adapter is the only new architecture layer allowed to touch the
//   legacy plaintext passcode model.
// - It is not an endorsement of plaintext credential persistence.
// ------------------------------------------------------------

import '../privacy_auth_result.dart';
import '../privacy_biometric_status.dart';
import '../privacy_credential_gateway.dart';
import '../privacy_lock_settings.dart';
import '../privacy_lock_store.dart';

typedef LegacyPrivacyLockLoader = Future<PrivacyLockSettings> Function();
typedef LegacyPrivacyLockSaver = Future<void> Function(
  PrivacyLockSettings settings,
);

class LegacyAndroidPrivacyCredentialGateway
    implements PrivacyCredentialGateway {
  LegacyAndroidPrivacyCredentialGateway({
    LegacyPrivacyLockLoader? loadSettings,
    LegacyPrivacyLockSaver? saveSettings,
  })  : _loadSettings = loadSettings ?? PrivacyLockStore.load,
        _saveSettings = saveSettings ?? PrivacyLockStore.save;

  final LegacyPrivacyLockLoader _loadSettings;
  final LegacyPrivacyLockSaver _saveSettings;

  static final RegExp _sixDigitPin = RegExp(r'^\d{6}$');

  @override
  Future<bool> isCredentialConfigured() async {
    final PrivacyLockSettings settings = await _loadSettings();
    return settings.passcode.length == 6;
  }

  @override
  Future<void> configurePin(String pin) async {
    if (!_sixDigitPin.hasMatch(pin)) {
      throw ArgumentError(
        'BreakWave privacy PIN must contain exactly six digits.',
      );
    }

    final PrivacyLockSettings settings = await _loadSettings();
    await _saveSettings(settings.copyWith(passcode: pin));
  }

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    final PrivacyLockSettings settings = await _loadSettings();

    if (settings.passcode.length != 6) {
      return PrivacyAuthResult.unavailable;
    }

    if (!_sixDigitPin.hasMatch(pin)) {
      return PrivacyAuthResult.failed;
    }

    return settings.passcode == pin
        ? PrivacyAuthResult.success
        : PrivacyAuthResult.failed;
  }

  @override
  Future<void> clearCredential() async {
    final PrivacyLockSettings settings = await _loadSettings();
    await _saveSettings(settings.copyWith(passcode: ''));
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async {
    return PrivacyBiometricStatus.notAvailable;
  }

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    return PrivacyAuthResult.unavailable;
  }
}
