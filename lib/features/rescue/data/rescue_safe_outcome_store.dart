// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_safe_outcome_store.dart
// Purpose: IOS-G2H isolated pending queue for locked Rescue-safe outcomes.
// ------------------------------------------------------------

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/pending_rescue_outcome.dart';

class RescueSafeOutcomeStore {
  const RescueSafeOutcomeStore();

  Future<List<PendingRescueOutcome>> loadPending() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes) ?? <String>[];
    return raw.map((String item) {
      final dynamic decoded = jsonDecode(item);
      if (decoded is! Map<String, dynamic>) throw const FormatException('Invalid pending Rescue payload.');
      return PendingRescueOutcome.fromMap(decoded);
    }).toList(growable: false);
  }

  Future<void> save(PendingRescueOutcome outcome) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes) ?? <String>[];
    final String encoded = jsonEncode(outcome.toMap());
    final List<String> updated = <String>[];
    bool replaced = false;
    for (final String raw in existing) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final PendingRescueOutcome parsed = PendingRescueOutcome.fromMap(decoded);
          if (parsed.id == outcome.id) {
            if (!replaced) { updated.add(encoded); replaced = true; }
            continue;
          }
        }
      } catch (_) {}
      updated.add(raw);
    }
    if (!replaced) updated.add(encoded);
    await prefs.setStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes, updated);
  }

  Future<void> removeIds(Set<String> ids) async {
    if (ids.isEmpty) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes) ?? <String>[];
    final List<String> retained = <String>[];
    for (final String raw in existing) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic> && ids.contains(PendingRescueOutcome.fromMap(decoded).id)) continue;
      } catch (_) {}
      retained.add(raw);
    }
    await prefs.setStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes, retained);
  }
}
