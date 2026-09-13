// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_attempt_store.dart
// Purpose: IOS-G2E persistence for non-secret failed-attempt state.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_attempt_state.dart';

abstract interface class PrivacyAttemptStoreApi {
  Future<PrivacyAttemptState> load();

  Future<void> save(PrivacyAttemptState state);

  Future<void> clear();
}

class PrivacyAttemptStore implements PrivacyAttemptStoreApi {
  static const String storageKey = 'bw_privacy_lock_attempt_v1';

  // A malformed persisted security record must not silently reset the
  // brute-force counter. The controller converts this defensive count into
  // a fresh cooldown window during initialization.
  static const PrivacyAttemptState defensiveFailureState =
      PrivacyAttemptState(
    failedAttemptCount: 10,
    cooldownUntilUtc: null,
  );

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  @override
  Future<PrivacyAttemptState> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return PrivacyAttemptState.empty;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return defensiveFailureState;
      }

      final Object? rawCount = decoded['failedAttemptCount'];
      final Object? rawCooldown = decoded['cooldownUntilUtc'];
      final Object? rawSchemaVersion = decoded['schemaVersion'];

      if (rawCount is! int || rawCount < 0) {
        return defensiveFailureState;
      }
      if (rawCooldown != null && rawCooldown is! String) {
        return defensiveFailureState;
      }
      if (rawCooldown is String &&
          rawCooldown.trim().isNotEmpty &&
          DateTime.tryParse(rawCooldown) == null) {
        return defensiveFailureState;
      }
      if (rawSchemaVersion is! int) {
        return defensiveFailureState;
      }

      return PrivacyAttemptState.fromMap(decoded);
    } catch (_) {
      return defensiveFailureState;
    }
  }

  @override
  Future<void> save(PrivacyAttemptState state) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(state.toMap()));
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
