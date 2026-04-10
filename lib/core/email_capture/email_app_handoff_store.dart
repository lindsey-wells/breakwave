// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_app_handoff_store.dart
// Purpose: BW-44B email app handoff settings persistence.
// Notes: Stores one optional team email address locally.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_app_handoff_settings.dart';

class EmailAppHandoffStore {
  static const String storageKey = 'bw_email_app_handoff_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<EmailAppHandoffSettings> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return EmailAppHandoffSettings.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return EmailAppHandoffSettings.fromMap(decoded);
    } catch (_) {
      return EmailAppHandoffSettings.defaults;
    }
  }

  static Future<void> save(EmailAppHandoffSettings settings) async {
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
