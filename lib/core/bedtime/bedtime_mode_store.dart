// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_mode_store.dart
// Purpose: BW-23 bedtime danger mode persistence.
// Notes: Saves one bedtime risk state keyed to today.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'bedtime_mode_entry.dart';

class BedtimeModeStore {
  static const String storageKey = 'bw_bedtime_mode_v1';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static String dateKeyFor(DateTime value) {
    final DateTime local = value.toLocal();
    final String year = local.year.toString().padLeft(4, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String todayKey() => dateKeyFor(DateTime.now());

  static Future<BedtimeModeEntry?> loadTodayEntry() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final BedtimeModeEntry entry = BedtimeModeEntry.fromMap(decoded);
      if (entry.dateKey == todayKey()) {
        return entry;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveTodayRisk(bool isRisky) async {
    final SharedPreferences prefs = await _prefs();
    final BedtimeModeEntry entry = BedtimeModeEntry(
      dateKey: todayKey(),
      isRisky: isRisky,
      savedAtIso: DateTime.now().toIso8601String(),
    );

    await prefs.setString(storageKey, jsonEncode(entry.toMap()));
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
