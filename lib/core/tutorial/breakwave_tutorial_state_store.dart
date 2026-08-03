// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_state_store.dart
// Purpose: Persist replayable tutorial progress locally.
// Notes: BW-ONBOARD-01B1 never changes onboarding or entitlement state.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'breakwave_tutorial_state.dart';

class BreakWaveTutorialStateStore {
  const BreakWaveTutorialStateStore._();

  static const String storageKey = 'bw_tutorial_state_v1';

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<BreakWaveTutorialState> load({
    DateTime? now,
  }) async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return BreakWaveTutorialState.initial(now: now);
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Tutorial state is not a map.');
      }

      final BreakWaveTutorialState saved =
          BreakWaveTutorialState.fromMap(decoded);
      if (saved.schemaVersion ==
          BreakWaveTutorialState.currentSchemaVersion) {
        return saved;
      }

      final BreakWaveTutorialState upgraded = BreakWaveTutorialState(
        schemaVersion: BreakWaveTutorialState.currentSchemaVersion,
        currentStep: saved.currentStep,
        completed: saved.completed,
        updatedAtIso: (now ?? DateTime.now()).toUtc().toIso8601String(),
        completedAtIso: saved.completedAtIso,
      );
      await _saveWithPrefs(prefs, upgraded);
      return upgraded;
    } catch (_) {
      await prefs.remove(storageKey);
      changes.value += 1;
      return BreakWaveTutorialState.initial(now: now);
    }
  }

  static Future<BreakWaveTutorialState> saveProgress({
    required int step,
    DateTime? now,
  }) async {
    final int safeStep = step < 0
        ? 0
        : step >= BreakWaveTutorialState.totalSteps
            ? BreakWaveTutorialState.totalSteps - 1
            : step;
    final BreakWaveTutorialState existing = await load(now: now);
    final BreakWaveTutorialState state = BreakWaveTutorialState(
      schemaVersion: BreakWaveTutorialState.currentSchemaVersion,
      currentStep: safeStep,
      completed: existing.completed,
      updatedAtIso: (now ?? DateTime.now()).toUtc().toIso8601String(),
      completedAtIso: existing.completedAtIso,
    );
    await save(state);
    return state;
  }

  static Future<BreakWaveTutorialState> complete({
    DateTime? now,
  }) async {
    final DateTime effectiveNow = now ?? DateTime.now();
    final String timestamp = effectiveNow.toUtc().toIso8601String();
    final BreakWaveTutorialState state = BreakWaveTutorialState(
      schemaVersion: BreakWaveTutorialState.currentSchemaVersion,
      currentStep: BreakWaveTutorialState.totalSteps - 1,
      completed: true,
      updatedAtIso: timestamp,
      completedAtIso: timestamp,
    );
    await save(state);
    return state;
  }

  static Future<void> save(BreakWaveTutorialState state) async {
    final SharedPreferences prefs = await _prefs();
    await _saveWithPrefs(prefs, state);
  }

  static Future<void> _saveWithPrefs(
    SharedPreferences prefs,
    BreakWaveTutorialState state,
  ) async {
    await prefs.setString(storageKey, jsonEncode(state.toMap()));
    changes.value += 1;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
