// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: onboarding_draft_store.dart
// Purpose: Local persistence for unfinished onboarding answers.
// Notes: This store never writes real recovery or entitlement data.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_draft.dart';

class OnboardingDraftStore {
  const OnboardingDraftStore._();

  static const String storageKey =
      'bw_onboarding_draft_v1';

  static final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static OnboardingDraft? _decode(
    String? raw,
  ) {
    if (raw == null ||
        raw.trim().isEmpty) {
      return null;
    }

    try {
      final Object? decoded =
          jsonDecode(raw);

      if (decoded
          is! Map<String, dynamic>) {
        return null;
      }

      return OnboardingDraft.fromMap(
        decoded,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<OnboardingDraft> load({
    DateTime? now,
  }) async {
    final SharedPreferences prefs =
        await _prefs();

    final OnboardingDraft? saved =
        _decode(
      prefs.getString(storageKey),
    );

    if (saved == null) {
      return OnboardingDraft.empty;
    }

    if (saved.schemaVersion ==
        OnboardingDraft
            .currentSchemaVersion) {
      return saved;
    }

    final OnboardingDraft upgraded =
        saved.preparedForSave(
      now ?? DateTime.now(),
    );

    await _write(
      prefs,
      upgraded,
    );

    return upgraded;
  }

  static Future<OnboardingDraft> save(
    OnboardingDraft draft, {
    DateTime? now,
  }) async {
    final SharedPreferences prefs =
        await _prefs();

    final OnboardingDraft prepared =
        draft.preparedForSave(
      now ?? DateTime.now(),
    );

    await _write(
      prefs,
      prepared,
    );

    return prepared;
  }

  static Future<void> _write(
    SharedPreferences prefs,
    OnboardingDraft draft,
  ) async {
    await prefs.setString(
      storageKey,
      jsonEncode(draft.toMap()),
    );

    changes.value += 1;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs =
        await _prefs();

    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
