// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_settings_store.dart
// Purpose: BW-24 privacy settings persistence.
// Notes: Saves privacy preferences and notifies listeners on change.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_settings.dart';

class PrivacySettingsStore {
  static const String storageKey = 'bw_privacy_settings_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<PrivacySettings> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return PrivacySettings.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return PrivacySettings.fromMap(decoded);
    } catch (_) {
      return PrivacySettings.defaults;
    }
  }

  static Future<void> save(PrivacySettings settings) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(settings.toMap()));
    changes.value += 1;
  }
}
