// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_store.dart
// Purpose: BW-39 custom why persistence.
// Notes: Stores one saved why and notifies listeners on change.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_why_entry.dart';

class CustomWhyStore {
  static const String storageKey = 'bw_custom_why_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<CustomWhyEntry> load() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return CustomWhyEntry.empty;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return CustomWhyEntry.fromMap(decoded);
    } catch (_) {
      return CustomWhyEntry.empty;
    }
  }

  static Future<void> save(CustomWhyEntry entry) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(entry.toMap()));
    changes.value += 1;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
