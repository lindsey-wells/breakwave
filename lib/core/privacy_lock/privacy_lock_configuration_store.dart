// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_configuration_store.dart
// Purpose: IOS-G2E persistence for non-secret privacy-lock configuration.
// Notes: Never stores PIN, verifier, salt, or biometric secret material.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_lock_configuration.dart';
import 'privacy_lock_mode.dart';

abstract interface class PrivacyLockConfigurationStoreApi {
  Future<PrivacyLockConfiguration> load();

  Future<void> save(PrivacyLockConfiguration configuration);

  Future<void> clear();
}

class PrivacyLockConfigurationStore
    implements PrivacyLockConfigurationStoreApi {
  static const String storageKey = 'bw_privacy_lock_config_v2';

  // If a configuration record exists but cannot be decoded, protected data
  // fails closed. Rescue-safe remains available once shell integration lands.
  static const PrivacyLockConfiguration failClosedConfiguration =
      PrivacyLockConfiguration(
    mode: PrivacyLockMode.fullApp,
    biometricEnabled: false,
    credentialConfigured: true,
  );

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  @override
  Future<PrivacyLockConfiguration> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return PrivacyLockConfiguration.defaults;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return failClosedConfiguration;
      }

      final Object? rawMode = decoded['mode'];
      final Object? rawBiometricEnabled = decoded['biometricEnabled'];
      final Object? rawCredentialConfigured = decoded['credentialConfigured'];
      final Object? rawSchemaVersion = decoded['schemaVersion'];
      const Set<String> allowedModes = <String>{
        'none',
        'fullApp',
        'sensitiveSections',
      };

      if (rawMode is! String ||
          !allowedModes.contains(rawMode) ||
          rawBiometricEnabled is! bool ||
          rawCredentialConfigured is! bool ||
          rawSchemaVersion is! int) {
        return failClosedConfiguration;
      }

      return PrivacyLockConfiguration.fromMap(decoded);
    } catch (_) {
      return failClosedConfiguration;
    }
  }

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(configuration.toMap()));
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
