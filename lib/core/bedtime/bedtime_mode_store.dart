// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_mode_store.dart
// Purpose: BW-23 bedtime danger mode persistence.
// Notes: Saves one bedtime risk state keyed to today.
// Notes: BW-89A8A preserves dated bedtime context history alongside the
// existing current-night record without changing callers of loadTodayEntry()
// or saveTodayRisk().
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'bedtime_mode_entry.dart';

class BedtimeModeStore {
  static const String storageKey = 'bw_bedtime_mode_v1';
  static const String historyStorageKey = 'bw_bedtime_mode_history_v1';

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

  static Future<List<BedtimeModeEntry>> loadEntries() async {
    final SharedPreferences prefs = await _prefs();
    final Map<String, BedtimeModeEntry> byDate =
        <String, BedtimeModeEntry>{};

    final List<String>? encodedHistory =
        prefs.getStringList(historyStorageKey);

    if (encodedHistory != null) {
      for (final String raw in encodedHistory) {
        final BedtimeModeEntry? entry = _decodeEntry(raw);
        if (entry == null || entry.dateKey.trim().isEmpty) {
          continue;
        }
        _keepLatest(byDate, entry);
      }
    }

    // Compatibility bridge: include the legacy/current-night record in
    // returned history even before the next save migrates it into the list.
    final String? currentRaw = prefs.getString(storageKey);
    if (currentRaw != null && currentRaw.trim().isNotEmpty) {
      final BedtimeModeEntry? current = _decodeEntry(currentRaw);
      if (current != null && current.dateKey.trim().isNotEmpty) {
        _keepLatest(byDate, current);
      }
    }

    final List<BedtimeModeEntry> entries = byDate.values.toList()
      ..sort(
        (BedtimeModeEntry a, BedtimeModeEntry b) =>
            b.dateKey.compareTo(a.dateKey),
      );

    return entries;
  }

  static Future<void> saveTodayRisk(bool isRisky) async {
    final SharedPreferences prefs = await _prefs();
    final BedtimeModeEntry entry = BedtimeModeEntry(
      dateKey: todayKey(),
      isRisky: isRisky,
      savedAtIso: DateTime.now().toIso8601String(),
    );

    final Map<String, BedtimeModeEntry> historyByDate =
        <String, BedtimeModeEntry>{};

    final List<String>? encodedHistory =
        prefs.getStringList(historyStorageKey);
    if (encodedHistory != null) {
      for (final String raw in encodedHistory) {
        final BedtimeModeEntry? historic = _decodeEntry(raw);
        if (historic == null || historic.dateKey.trim().isEmpty) {
          continue;
        }
        _keepLatest(historyByDate, historic);
      }
    }

    // Migrate/preserve the previous single-record value before replacing it.
    final String? previousRaw = prefs.getString(storageKey);
    if (previousRaw != null && previousRaw.trim().isNotEmpty) {
      final BedtimeModeEntry? previous = _decodeEntry(previousRaw);
      if (previous != null && previous.dateKey.trim().isNotEmpty) {
        _keepLatest(historyByDate, previous);
      }
    }

    // One dated entry per night. Re-saving tonight replaces only tonight.
    historyByDate[entry.dateKey] = entry;

    final List<BedtimeModeEntry> ordered = historyByDate.values.toList()
      ..sort(
        (BedtimeModeEntry a, BedtimeModeEntry b) =>
            b.dateKey.compareTo(a.dateKey),
      );

    await prefs.setStringList(
      historyStorageKey,
      ordered
          .map(
            (BedtimeModeEntry item) =>
                jsonEncode(item.toMap()),
          )
          .toList(),
    );

    // Preserve the original BW-23 current-night contract for all callers.
    await prefs.setString(storageKey, jsonEncode(entry.toMap()));
  }

  static BedtimeModeEntry? _decodeEntry(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return BedtimeModeEntry.fromMap(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  static void _keepLatest(
    Map<String, BedtimeModeEntry> byDate,
    BedtimeModeEntry candidate,
  ) {
    final BedtimeModeEntry? existing = byDate[candidate.dateKey];
    if (existing == null) {
      byDate[candidate.dateKey] = candidate;
      return;
    }

    final DateTime? existingSaved =
        DateTime.tryParse(existing.savedAtIso);
    final DateTime? candidateSaved =
        DateTime.tryParse(candidate.savedAtIso);

    if (existingSaved == null && candidateSaved != null) {
      byDate[candidate.dateKey] = candidate;
      return;
    }

    if (existingSaved != null &&
        candidateSaved != null &&
        candidateSaved.isAfter(existingSaved)) {
      byDate[candidate.dateKey] = candidate;
    }
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
    await prefs.remove(historyStorageKey);
  }
}
