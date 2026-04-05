// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: premium_state_store.dart
// Purpose: BW-25 premium entitlement persistence.
// Notes: Local-only premium state and notifier for UI scaffolding.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_state.dart';

class PremiumStateStore {
  static const String storageKey = 'bw_premium_state_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<PremiumState> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return PremiumState.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return PremiumState.fromMap(decoded);
    } catch (_) {
      return PremiumState.defaults;
    }
  }

  static Future<void> save(PremiumState state) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(state.toMap()));
    changes.value += 1;
  }

  static Future<void> setPlusUnlocked(bool value) async {
    final PremiumState current = await load();
    await save(current.copyWith(isPlusUnlocked: value));
  }

  static Future<void> setOfferVariant(String value) async {
    final PremiumState current = await load();
    await save(current.copyWith(offerVariant: value));
  }
}
