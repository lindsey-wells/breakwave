// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_store.dart
// Purpose: BW-41 privacy lock persistence.
// Notes: Stores privacy lock settings and notifies listeners on change.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_lock_settings.dart';

class PrivacyLockStore {
  static const String storageKey = 'bw_privacy_lock_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<PrivacyLockSettings> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return PrivacyLockSettings.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return PrivacyLockSettings.fromMap(decoded);
    } catch (_) {
      return PrivacyLockSettings.defaults;
    }
  }

  static Future<void> save(PrivacyLockSettings settings) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(settings.toMap()));
    changes.value += 1;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
