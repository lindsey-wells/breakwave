// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_insights_calculator.dart
// Purpose: Pure calculations for 7/30/90-day recovery insights.
// Notes: BW-87B2A uses only real local log entries.
// Notes: Invalid, future, and unsupported entries are ignored.
// ------------------------------------------------------------

import '../../log/domain/log_entry.dart';
import 'recovery_insights_snapshot.dart';

class RecoveryInsightsCalculator {
  const RecoveryInsightsCalculator();

  static const int minimumEntriesForTimePatterns = 5;

  static const Set<String> _supportedTypes = <String>{
    'urge',
    'slip',
    'victory',
  };

  RecoveryInsightsSnapshot calculate({
    required List<LogEntry> entries,
    required DateTime now,
  }) {
    final DateTime localNow = now.toLocal();
    final List<_DatedLogEntry> validEntries = <_DatedLogEntry>[];

    int ignoredEntryCount = 0;

    for (final LogEntry entry in entries) {
      final DateTime? parsed = DateTime.tryParse(entry.createdAtIso);

      if (parsed == null) {
        ignoredEntryCount += 1;
        continue;
      }

      final DateTime occurredAt = parsed.toLocal();
      final String normalizedType = entry.entryType.trim().toLowerCase();

      if (occurredAt.isAfter(localNow) ||
          !_supportedTypes.contains(normalizedType)) {
        ignoredEntryCount += 1;
        continue;
      }

      validEntries.add(
        _DatedLogEntry(
          entry: entry,
          occurredAt: occurredAt,
          normalizedType: normalizedType,
        ),
      );
    }

    validEntries.sort(
      (_DatedLogEntry a, _DatedLogEntry b) =>
          b.occurredAt.compareTo(a.occurredAt),
    );

    final RecoveryPeriodSummary last7Days = _periodSummary(
      validEntries,
      now: localNow,
      days: 7,
    );

    final RecoveryPeriodSummary last30Days = _periodSummary(
      validEntries,
      now: localNow,
      days: 30,
    );

    final RecoveryPeriodSummary last90Days = _periodSummary(
      validEntries,
      now: localNow,
      days: 90,
    );

    final List<_DatedLogEntry> entries30Days = _entriesWithin(
      validEntries,
      now: localNow,
      days: 30,
    );

    final bool hasEnoughForTimePatterns =
        entries30Days.length >= minimumEntriesForTimePatterns;

    return RecoveryInsightsSnapshot(
      validEntryCount: validEntries.length,
      ignoredEntryCount: ignoredEntryCount,
      last7Days: last7Days,
      last30Days: last30Days,
      last90Days: last90Days,
      topTriggers30Days: _topTriggers(entries30Days),
      busiestWeekday30Days: hasEnoughForTimePatterns
          ? _dominantLabel(_weekdayCounts(entries30Days))
          : null,
      busiestTimeWindow30Days: hasEnoughForTimePatterns
          ? _dominantLabel(_timeWindowCounts(entries30Days))
          : null,
      hasEnoughForTimePatterns: hasEnoughForTimePatterns,
    );
  }

  RecoveryPeriodSummary _periodSummary(
    List<_DatedLogEntry> entries, {
    required DateTime now,
    required int days,
  }) {
    final List<_DatedLogEntry> periodEntries = _entriesWithin(
      entries,
      now: now,
      days: days,
    );

    int urges = 0;
    int slips = 0;
    int victories = 0;
    int totalIntensity = 0;

    for (final _DatedLogEntry item in periodEntries) {
      totalIntensity += item.entry.intensity;

      switch (item.normalizedType) {
        case 'urge':
          urges += 1;
          break;
        case 'slip':
          slips += 1;
          break;
        case 'victory':
          victories += 1;
          break;
      }
    }

    final int total = periodEntries.length;

    return RecoveryPeriodSummary(
      days: days,
      total: total,
      urges: urges,
      slips: slips,
      victories: victories,
      averageIntensity: total == 0 ? 0 : totalIntensity / total,
    );
  }

  List<_DatedLogEntry> _entriesWithin(
    List<_DatedLogEntry> entries, {
    required DateTime now,
    required int days,
  }) {
    final DateTime boundary = now.subtract(Duration(days: days));

    return entries
        .where(
          (_DatedLogEntry item) =>
              !item.occurredAt.isBefore(boundary) &&
              !item.occurredAt.isAfter(now),
        )
        .toList(growable: false);
  }

  List<TriggerInsight> _topTriggers(
    List<_DatedLogEntry> entries,
  ) {
    final Map<String, _TriggerAccumulator> counts =
        <String, _TriggerAccumulator>{};

    for (final _DatedLogEntry item in entries) {
      final Set<String> seenInEntry = <String>{};

      for (final String rawTrigger in item.entry.triggers) {
        final String display = rawTrigger.trim();
        final String key = display.toLowerCase();

        if (display.isEmpty || !seenInEntry.add(key)) {
          continue;
        }

        final _TriggerAccumulator accumulator =
            counts.putIfAbsent(
          key,
          () => _TriggerAccumulator(display: display),
        );

        accumulator.count += 1;
      }
    }

    final List<TriggerInsight> ranked = counts.values
        .map(
          (_TriggerAccumulator item) => TriggerInsight(
            trigger: item.display,
            count: item.count,
          ),
        )
        .toList();

    ranked.sort((TriggerInsight a, TriggerInsight b) {
      final int countComparison = b.count.compareTo(a.count);

      if (countComparison != 0) {
        return countComparison;
      }

      return a.trigger.toLowerCase().compareTo(
            b.trigger.toLowerCase(),
          );
    });

    return List<TriggerInsight>.unmodifiable(
      ranked.take(5),
    );
  }

  Map<String, int> _weekdayCounts(
    List<_DatedLogEntry> entries,
  ) {
    const List<String> names = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final Map<String, int> counts = <String, int>{};

    for (final _DatedLogEntry item in entries) {
      final String label = names[item.occurredAt.weekday - 1];
      counts[label] = (counts[label] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, int> _timeWindowCounts(
    List<_DatedLogEntry> entries,
  ) {
    final Map<String, int> counts = <String, int>{};

    for (final _DatedLogEntry item in entries) {
      final String label = _timeWindowFor(
        item.occurredAt.hour,
      );

      counts[label] = (counts[label] ?? 0) + 1;
    }

    return counts;
  }

  String _timeWindowFor(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    }

    if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    }

    if (hour >= 17 && hour < 21) {
      return 'Evening';
    }

    return 'Late night';
  }

  String? _dominantLabel(Map<String, int> counts) {
    if (counts.isEmpty) {
      return null;
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

    if (ranked.first.value < 2) {
      return null;
    }

    if (ranked.length > 1 &&
        ranked.first.value == ranked[1].value) {
      return null;
    }

    return ranked.first.key;
  }
}

class _DatedLogEntry {
  const _DatedLogEntry({
    required this.entry,
    required this.occurredAt,
    required this.normalizedType,
  });

  final LogEntry entry;
  final DateTime occurredAt;
  final String normalizedType;
}

class _TriggerAccumulator {
  _TriggerAccumulator({
    required this.display,
  });

  final String display;
  int count = 0;
}
