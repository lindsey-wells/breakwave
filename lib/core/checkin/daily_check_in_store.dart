// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_check_in_store.dart
// Purpose: BW-19 daily check-in persistence.
// Notes: Saves local daily check-in history for Home check-in and control logic.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'daily_check_in_entry.dart';

class DailyCheckInStore {
  static const String storageKey = 'bw_daily_check_ins_v1';

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

  static Future<List<DailyCheckInEntry>> loadEntries() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return const <DailyCheckInEntry>[];
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<DailyCheckInEntry> entries = decoded
          .whereType<Map<String, dynamic>>()
          .map(DailyCheckInEntry.fromMap)
          .where((DailyCheckInEntry entry) =>
              entry.dateKey.trim().isNotEmpty && entry.status.trim().isNotEmpty)
          .toList();

      entries.sort(
        (DailyCheckInEntry a, DailyCheckInEntry b) =>
            b.dateKey.compareTo(a.dateKey),
      );

      return entries;
    } catch (_) {
      return const <DailyCheckInEntry>[];
    }
  }

  static Future<void> saveTodayStatus(String status) async {
    final SharedPreferences prefs = await _prefs();
    final List<DailyCheckInEntry> entries = await loadEntries();
    final String today = todayKey();

    final List<DailyCheckInEntry> updated = entries
        .where((DailyCheckInEntry entry) => entry.dateKey != today)
        .toList();

    updated.add(
      DailyCheckInEntry(
        dateKey: today,
        status: status,
        savedAtIso: DateTime.now().toIso8601String(),
      ),
    );

    updated.sort(
      (DailyCheckInEntry a, DailyCheckInEntry b) =>
          b.dateKey.compareTo(a.dateKey),
    );

    final String encoded = jsonEncode(
      updated.map((DailyCheckInEntry entry) => entry.toMap()).toList(),
    );

    await prefs.setString(storageKey, encoded);
  }

  static Future<DailyCheckInEntry?> loadTodayEntry() async {
    final List<DailyCheckInEntry> entries = await loadEntries();
    final String today = todayKey();

    for (final DailyCheckInEntry entry in entries) {
      if (entry.dateKey == today) {
        return entry;
      }
    }
    return null;
  }

  static Future<void> clearAll() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
