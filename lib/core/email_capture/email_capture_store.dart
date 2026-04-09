// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_capture_store.dart
// Purpose: BW-42 email capture persistence.
// Notes: Stores optional email capture settings locally and notifies listeners.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_capture_settings.dart';

class EmailCaptureStore {
  static const String storageKey = 'bw_email_capture_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<EmailCaptureSettings> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return EmailCaptureSettings.defaults;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return EmailCaptureSettings.fromMap(decoded);
    } catch (_) {
      return EmailCaptureSettings.defaults;
    }
  }

  static Future<void> save(EmailCaptureSettings settings) async {
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
