// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_context_observation_engine.dart
// Purpose: BW-89A6 deterministic Daily Context Signals.
// Notes: Uses Daily Check-In history only; never converts check-ins into Log behavior.
// ------------------------------------------------------------

import '../../../core/checkin/daily_check_in_entry.dart';
import 'daily_context_observation.dart';

class DailyContextObservationEngine {
  const DailyContextObservationEngine();

  static const int windowDays = 7;
  static const int minimumCheckIns = 3;
  static const int minimumRepeatedStatusCount = 2;

  static const Map<String, String> _canonicalStatuses = <String, String>{
    'steady': 'Steady',
    'vulnerable': 'Vulnerable',
    'fought through': 'Fought through',
    'slipped': 'Slipped',
  };

  DailyContextObservationResult evaluate({
    required List<DailyCheckInEntry> entries,
    required DateTime now,
  }) {
    final DateTime localNow = now.toLocal();
    final Set<String> validDateKeys = <String>{};

    for (int offset = 0; offset < windowDays; offset += 1) {
      validDateKeys.add(
        _dateKeyFor(localNow.subtract(Duration(days: offset))),
      );
    }

    final Map<String, DailyCheckInEntry> latestByDate =
        <String, DailyCheckInEntry>{};

    for (final DailyCheckInEntry entry in entries) {
      final String dateKey = entry.dateKey.trim();
      final String? canonicalStatus =
          _canonicalStatus(entry.status);

      if (!validDateKeys.contains(dateKey) ||
          canonicalStatus == null) {
        continue;
      }

      final DailyCheckInEntry normalized = DailyCheckInEntry(
        dateKey: dateKey,
        status: canonicalStatus,
        savedAtIso: entry.savedAtIso,
      );

      final DailyCheckInEntry? existing = latestByDate[dateKey];
      if (existing == null ||
          _shouldReplace(existing, normalized)) {
        latestByDate[dateKey] = normalized;
      }
    }

    final List<DailyCheckInEntry> recent =
        latestByDate.values.toList()
          ..sort(
            (DailyCheckInEntry a, DailyCheckInEntry b) =>
                b.dateKey.compareTo(a.dateKey),
          );

    final int checkInCount = recent.length;

    if (checkInCount < minimumCheckIns) {
      final int remaining = minimumCheckIns - checkInCount;
      return DailyContextObservationResult(
        checkInCount: checkInCount,
        hasEnoughData: false,
        hasObservation: false,
        windowDays: windowDays,
        message:
            'Keep checking in. $remaining more recent Daily Check-In${remaining == 1 ? '' : 's'} will give you enough context to look for repetition.',
        dominantStatus: null,
        evidenceCount: 0,
      );
    }

    final Map<String, int> counts = <String, int>{};
    for (final DailyCheckInEntry entry in recent) {
      counts.update(
        entry.status,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final List<MapEntry<String, int>> ranked =
        counts.entries.toList()
          ..sort(
            (MapEntry<String, int> a, MapEntry<String, int> b) {
              final int countComparison =
                  b.value.compareTo(a.value);
              if (countComparison != 0) {
                return countComparison;
              }
              return a.key.compareTo(b.key);
            },
          );

    final int topCount = ranked.first.value;
    final int tiedTopCount = ranked
        .where(
          (MapEntry<String, int> item) =>
              item.value == topCount,
        )
        .length;

    if (topCount < minimumRepeatedStatusCount ||
        tiedTopCount != 1) {
      return DailyContextObservationResult(
        checkInCount: checkInCount,
        hasEnoughData: true,
        hasObservation: false,
        windowDays: windowDays,
        message:
            'No single Daily Check-In status is repeating more than the others yet.',
        dominantStatus: null,
        evidenceCount: 0,
      );
    }

    final MapEntry<String, int> top = ranked.first;

    return DailyContextObservationResult(
      checkInCount: checkInCount,
      hasEnoughData: true,
      hasObservation: true,
      windowDays: windowDays,
      message:
          'You marked ${top.value} of $checkInCount Daily Check-Ins as ${top.key} in the last $windowDays days.',
      dominantStatus: top.key,
      evidenceCount: top.value,
    );
  }

  String? _canonicalStatus(String raw) {
    return _canonicalStatuses[raw.trim().toLowerCase()];
  }

  bool _shouldReplace(
    DailyCheckInEntry existing,
    DailyCheckInEntry candidate,
  ) {
    final DateTime? existingSaved =
        DateTime.tryParse(existing.savedAtIso);
    final DateTime? candidateSaved =
        DateTime.tryParse(candidate.savedAtIso);

    if (existingSaved != null && candidateSaved != null) {
      final int comparison =
          candidateSaved.compareTo(existingSaved);
      if (comparison != 0) {
        return comparison > 0;
      }
    } else if (candidateSaved != null) {
      return true;
    } else if (existingSaved != null) {
      return false;
    }

    return candidate.status.compareTo(existing.status) > 0;
  }

  String _dateKeyFor(DateTime value) {
    final DateTime local = value.toLocal();
    final String year =
        local.year.toString().padLeft(4, '0');
    final String month =
        local.month.toString().padLeft(2, '0');
    final String day =
        local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
