// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_routine_progress_store.dart
// Purpose: Local persistence for guided-routine progress.
// Notes: BW-87B4A safely stores progress and completion history.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recovery_routine_progress.dart';

class RecoveryRoutineProgressStore {
  static const String storageKey =
      'bw_guided_routine_progress_v1';

  static final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<
      Map<String, RecoveryRoutineProgress>>
      loadAll() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return <String, RecoveryRoutineProgress>{};
    }

    try {
      final List<dynamic> decoded =
          jsonDecode(raw) as List<dynamic>;

      final Map<String, RecoveryRoutineProgress>
          result =
          <String, RecoveryRoutineProgress>{};

      for (final dynamic item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final RecoveryRoutineProgress progress =
            RecoveryRoutineProgress.fromMap(item);

        if (progress.routineId.isEmpty) {
          continue;
        }

        result[progress.routineId] = progress;
      }

      return result;
    } catch (_) {
      return <String, RecoveryRoutineProgress>{};
    }
  }

  static Future<RecoveryRoutineProgress?> loadFor(
    String routineId,
  ) async {
    final Map<String, RecoveryRoutineProgress> all =
        await loadAll();

    return all[routineId];
  }

  static Future<void> saveProgress(
    RecoveryRoutineProgress progress,
  ) async {
    if (progress.routineId.trim().isEmpty) {
      return;
    }

    final SharedPreferences prefs = await _prefs();

    final Map<String, RecoveryRoutineProgress> all =
        await loadAll();

    all[progress.routineId] = progress;

    final List<RecoveryRoutineProgress> sorted =
        all.values.toList()
          ..sort(
            (
              RecoveryRoutineProgress a,
              RecoveryRoutineProgress b,
            ) =>
                a.routineId.compareTo(b.routineId),
          );

    await prefs.setString(
      storageKey,
      jsonEncode(
        sorted
            .map(
              (
                RecoveryRoutineProgress item,
              ) =>
                  item.toMap(),
            )
            .toList(),
      ),
    );

    changes.value += 1;
  }

  static Future<void> clearRoutine(
    String routineId,
  ) async {
    final SharedPreferences prefs = await _prefs();

    final Map<String, RecoveryRoutineProgress> all =
        await loadAll();

    all.remove(routineId);

    await prefs.setString(
      storageKey,
      jsonEncode(
        all.values
            .map(
              (
                RecoveryRoutineProgress item,
              ) =>
                  item.toMap(),
            )
            .toList(),
      ),
    );

    changes.value += 1;
  }

  static Future<void> clearAll() async {
    final SharedPreferences prefs = await _prefs();

    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
