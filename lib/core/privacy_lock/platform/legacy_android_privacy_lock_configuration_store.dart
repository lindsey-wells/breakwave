// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: legacy_android_privacy_lock_configuration_store.dart
// Purpose: IOS-G2F Android compatibility bridge from legacy lock settings to v2 metadata.
// Notes:
// - Preserves released Android lock behavior while the shared session controller is wired.
// - Does not create, expose, or persist any new credential material.
// ------------------------------------------------------------

import '../privacy_lock_configuration.dart';
import '../privacy_lock_configuration_store.dart';
import '../privacy_lock_mode.dart';
import '../privacy_lock_settings.dart';
import '../privacy_lock_store.dart';

typedef LegacyPrivacySettingsLoader = Future<PrivacyLockSettings> Function();
typedef LegacyPrivacySettingsSaver = Future<void> Function(
  PrivacyLockSettings settings,
);
typedef LegacyPrivacySettingsClearer = Future<void> Function();

class LegacyAndroidPrivacyLockConfigurationStore
    implements PrivacyLockConfigurationStoreApi {
  LegacyAndroidPrivacyLockConfigurationStore({
    LegacyPrivacySettingsLoader? loadSettings,
    LegacyPrivacySettingsSaver? saveSettings,
    LegacyPrivacySettingsClearer? clearSettings,
  })  : _loadSettings = loadSettings ?? PrivacyLockStore.load,
        _saveSettings = saveSettings ?? PrivacyLockStore.save,
        _clearSettings = clearSettings ?? PrivacyLockStore.clear;

  final LegacyPrivacySettingsLoader _loadSettings;
  final LegacyPrivacySettingsSaver _saveSettings;
  final LegacyPrivacySettingsClearer _clearSettings;

  @override
  Future<PrivacyLockConfiguration> load() async {
    final PrivacyLockSettings settings = await _loadSettings();
    final bool credentialConfigured = settings.passcode.length == 6;

    return PrivacyLockConfiguration(
      mode: settings.isEnabled ? settings.mode : PrivacyLockMode.none,
      biometricEnabled: false,
      credentialConfigured: credentialConfigured,
    );
  }

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {
    if (!configuration.isEnabled || !configuration.credentialConfigured) {
      await _saveSettings(
        const PrivacyLockSettings(
          mode: PrivacyLockMode.none,
          passcode: '',
        ),
      );
      return;
    }

    final PrivacyLockSettings current = await _loadSettings();
    if (current.passcode.length != 6) {
      throw StateError(
        'Legacy Android privacy configuration cannot enable a lock without an existing six-character credential.',
      );
    }

    await _saveSettings(
      PrivacyLockSettings(
        mode: configuration.mode,
        passcode: current.passcode,
      ),
    );
  }

  @override
  Future<void> clear() {
    return _clearSettings();
  }
}
