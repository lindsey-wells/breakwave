// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_state_store.dart
// Purpose: Persist and safely resolve onboarding progress.
// Notes: Established users migrate without forced onboarding.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/storage_keys.dart';
import 'onboarding_state.dart';

class OnboardingStateStore {
  const OnboardingStateStore._();

  static const String storageKey =
      'bw_onboarding_state_v1';

  static final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  static const Set<String> legacyEvidenceKeys =
      <String>{
    'bw_recovery_mode_v1',
    BreakWaveStorageKeys.logEntries,
    'bw_reasons_selection_v1',
    'bw_triggers_selection_v1',
    'bw_custom_why_v1',
    'bw_daily_check_ins_v1',
    'bw_support_contact_v1',
  };

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static OnboardingState? _decode(
    String? raw,
  ) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return OnboardingState.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<OnboardingState?> load() async {
    final SharedPreferences prefs =
        await _prefs();

    return _decode(
      prefs.getString(storageKey),
    );
  }

  static Future<void> save(
    OnboardingState state,
  ) async {
    final SharedPreferences prefs =
        await _prefs();

    await _saveWithPrefs(
      prefs,
      state,
    );
  }

  static Future<void> _saveWithPrefs(
    SharedPreferences prefs,
    OnboardingState state,
  ) async {
    await prefs.setString(
      storageKey,
      jsonEncode(state.toMap()),
    );

    changes.value += 1;
  }

  static bool _hasEstablishedLegacyData(
    SharedPreferences prefs,
  ) {
    return legacyEvidenceKeys.any(
      prefs.containsKey,
    );
  }

  static Future<OnboardingState>
      resolveForLaunch({
    DateTime? now,
  }) async {
    final SharedPreferences prefs =
        await _prefs();

    final String? raw =
        prefs.getString(storageKey);

    final OnboardingState? saved =
        _decode(raw);

    if (saved != null) {
      if (saved.schemaVersion ==
          OnboardingState
              .currentSchemaVersion) {
        return saved;
      }

      final OnboardingState upgraded =
          saved.copyWith(
        schemaVersion: OnboardingState
            .currentSchemaVersion,
        updatedAtIso:
            (now ?? DateTime.now())
                .toUtc()
                .toIso8601String(),
      );

      await _saveWithPrefs(
        prefs,
        upgraded,
      );

      return upgraded;
    }

    if (raw != null) {
      await prefs.remove(storageKey);
    }

    if (_hasEstablishedLegacyData(prefs)) {
      final OnboardingState migrated =
          OnboardingState.completed(
        migratedLegacyUser: true,
        now: now,
      );

      await _saveWithPrefs(
        prefs,
        migrated,
      );

      return migrated;
    }

    // Do not persist notStarted during this passive
    // architecture phase. A user who begins using the
    // current app before onboarding launches should be
    // recognized as established on a later startup.
    return OnboardingState.initial(
      now: now,
    );
  }

  static Future<OnboardingState> begin({
    int step = 0,
    DateTime? now,
  }) async {
    final OnboardingState state =
        OnboardingState.inProgress(
      step: step,
      now: now,
    );

    await save(state);
    return state;
  }

  static Future<OnboardingState>
      saveProgress({
    required int step,
    DateTime? now,
  }) async {
    final OnboardingState state =
        OnboardingState.inProgress(
      step: step,
      now: now,
    );

    await save(state);
    return state;
  }

  static Future<OnboardingState> complete({
    DateTime? now,
  }) async {
    final OnboardingState state =
        OnboardingState.completed(
      now: now,
    );

    await save(state);
    return state;
  }

  static Future<OnboardingState> skip({
    DateTime? now,
  }) async {
    final OnboardingState state =
        OnboardingState.skipped(
      now: now,
    );

    await save(state);
    return state;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs =
        await _prefs();

    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
