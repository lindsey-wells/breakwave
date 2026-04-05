// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: reminder_settings_store.dart
// Purpose: BW-22 reminder settings persistence.
// Notes: Saves local reminder settings for notifications.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'reminder_settings.dart';

class ReminderSettingsStore {
  static const String storageKey = 'bw_reminder_settings_v1';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<ReminderSettings> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return ReminderSettings.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return ReminderSettings.fromMap(decoded);
    } catch (_) {
      return ReminderSettings.defaults;
    }
  }

  static Future<void> save(ReminderSettings settings) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(settings.toMap()));
  }
}
