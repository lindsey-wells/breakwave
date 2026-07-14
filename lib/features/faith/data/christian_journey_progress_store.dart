// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_journey_progress_store.dart
// Purpose: Local Christian journey progress persistence.
// Notes: BW-87B5A1 safely preserves progress and history.
// ------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/christian_journey_progress.dart';

class ChristianJourneyProgressStore {
  static const String storageKey =
      'bw_christian_journey_progress_v1';

  static final ValueNotifier<int> changes =
      ValueNotifier<int>(0);

  static Future<SharedPreferences>
      _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<
      Map<String, ChristianJourneyProgress>>
      loadAll() async {
    final SharedPreferences prefs =
        await _prefs();

    final String? raw =
        prefs.getString(storageKey);

    if (raw == null ||
        raw.trim().isEmpty) {
      return <String,
          ChristianJourneyProgress>{};
    }

    try {
      final List<dynamic> decoded =
          jsonDecode(raw) as List<dynamic>;

      final Map<String,
              ChristianJourneyProgress>
          result =
          <String,
              ChristianJourneyProgress>{};

      for (final dynamic item in decoded) {
        if (item
            is! Map<String, dynamic>) {
          continue;
        }

        final ChristianJourneyProgress
            progress =
            ChristianJourneyProgress
                .fromMap(item);

        if (progress.journeyId.isEmpty) {
          continue;
        }

        result[progress.journeyId] =
            progress;
      }

      return result;
    } catch (_) {
      return <String,
          ChristianJourneyProgress>{};
    }
  }

  static Future<
      ChristianJourneyProgress?> loadFor(
    String journeyId,
  ) async {
    final Map<String,
            ChristianJourneyProgress>
        all =
        await loadAll();

    return all[journeyId];
  }

  static Future<void> saveProgress(
    ChristianJourneyProgress progress,
  ) async {
    if (progress.journeyId
        .trim()
        .isEmpty) {
      return;
    }

    final SharedPreferences prefs =
        await _prefs();

    final Map<String,
            ChristianJourneyProgress>
        all =
        await loadAll();

    all[progress.journeyId] = progress;

    final List<ChristianJourneyProgress>
        sorted =
        all.values.toList()
          ..sort(
            (
              ChristianJourneyProgress a,
              ChristianJourneyProgress b,
            ) =>
                a.journeyId.compareTo(
              b.journeyId,
            ),
          );

    await prefs.setString(
      storageKey,
      jsonEncode(
        sorted
            .map(
              (
                ChristianJourneyProgress
                    item,
              ) =>
                  item.toMap(),
            )
            .toList(),
      ),
    );

    changes.value += 1;
  }

  static Future<void> clearJourney(
    String journeyId,
  ) async {
    final SharedPreferences prefs =
        await _prefs();

    final Map<String,
            ChristianJourneyProgress>
        all =
        await loadAll();

    all.remove(journeyId);

    await prefs.setString(
      storageKey,
      jsonEncode(
        all.values
            .map(
              (
                ChristianJourneyProgress
                    item,
              ) =>
                  item.toMap(),
            )
            .toList(),
      ),
    );

    changes.value += 1;
  }

  static Future<void> clearAll() async {
    final SharedPreferences prefs =
        await _prefs();

    await prefs.remove(storageKey);
    changes.value += 1;
  }
}
