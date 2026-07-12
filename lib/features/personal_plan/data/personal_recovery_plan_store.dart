// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_store.dart
// Purpose: Local persistence for the saved personal recovery plan.
// Notes: BW-87B3A fails safely when stored JSON is unavailable.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/personal_recovery_plan.dart';

class PersonalRecoveryPlanStore {
  static const String storageKey =
      'bw_personal_recovery_plan_v1';

  static final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<PersonalRecoveryPlan?> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;

      final PersonalRecoveryPlan plan =
          PersonalRecoveryPlan.fromMap(decoded);

      return plan.hasAnyContent ? plan : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(
    PersonalRecoveryPlan plan,
  ) async {
    final SharedPreferences prefs = await _prefs();

    await prefs.setString(
      storageKey,
      jsonEncode(plan.toMap()),
    );

    changes.value += 1;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();

    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
