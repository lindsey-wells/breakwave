// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_repository.dart
// Purpose: Local log persistence repository for BreakWave.
// Notes: BW-10 edit/delete support.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../domain/log_entry.dart';

class LogRepository {
  const LogRepository();

  Future<List<LogEntry>> loadEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawEntries =
        prefs.getStringList(BreakWaveStorageKeys.logEntries) ?? <String>[];

    return rawEntries
        .map((String item) => LogEntry.fromMap(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEntry(LogEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<LogEntry> existing = await loadEntries();
    final List<LogEntry> updated = <LogEntry>[entry, ...existing];

    final List<String> encoded = updated
        .map((LogEntry item) => jsonEncode(item.toMap()))
        .toList();

    await prefs.setStringList(BreakWaveStorageKeys.logEntries, encoded);
  }

  Future<void> updateEntry(LogEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<LogEntry> existing = await loadEntries();

    final List<LogEntry> updated = existing
        .map((LogEntry item) => item.id == entry.id ? entry : item)
        .toList();

    final List<String> encoded = updated
        .map((LogEntry item) => jsonEncode(item.toMap()))
        .toList();

    await prefs.setStringList(BreakWaveStorageKeys.logEntries, encoded);
  }

  Future<void> deleteEntry(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<LogEntry> existing = await loadEntries();

    final List<LogEntry> updated =
        existing.where((LogEntry item) => item.id != id).toList();

    final List<String> encoded = updated
        .map((LogEntry item) => jsonEncode(item.toMap()))
        .toList();

    await prefs.setStringList(BreakWaveStorageKeys.logEntries, encoded);
  }

  Future<int> entryCount() async {
    final List<LogEntry> entries = await loadEntries();
    return entries.length;
  }
}
