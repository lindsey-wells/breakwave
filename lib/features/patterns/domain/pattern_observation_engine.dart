// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pattern_observation_engine.dart
// Purpose: Deterministic Pattern Recognition observations from recent Log data.
// Notes: BW-89A2 uses only recorded evidence and never infers cause, diagnosis, or prediction.
// ------------------------------------------------------------

import '../../insights/domain/recovery_insights_calculator.dart';
import '../../log/domain/log_entry.dart';
import '../../log/domain/log_signal_classifier.dart';
import 'pattern_observation.dart';

class PatternObservationEngine {
  const PatternObservationEngine();

  static const int windowDays = 30;
  static const int minimumBehavioralEntries = 3;
  static const int minimumRepeatedSignalCount = 2;

  static const LogSignalClassifier _signalClassifier =
      LogSignalClassifier();

  PatternObservationResult evaluate({
    required List<LogEntry> entries,
    required DateTime now,
  }) {
    final DateTime localNow = now.toLocal();
    final DateTime boundary =
        localNow.subtract(const Duration(days: windowDays));

    final List<_DatedBehavioralEntry> behavioral =
        <_DatedBehavioralEntry>[];

    for (final LogEntry entry in entries) {
      final DateTime? parsed = DateTime.tryParse(entry.createdAtIso);
      if (parsed == null) {
        continue;
      }

      final DateTime occurredAt = parsed.toLocal();
      if (occurredAt.isBefore(boundary) ||
          occurredAt.isAfter(localNow) ||
          !_signalClassifier.isBehavioralEntryType(entry.entryType)) {
        continue;
      }

      behavioral.add(
        _DatedBehavioralEntry(
          entry: entry,
          occurredAt: occurredAt,
        ),
      );
    }

    behavioral.sort(
      (_DatedBehavioralEntry a, _DatedBehavioralEntry b) {
        final int timeComparison =
            b.occurredAt.compareTo(a.occurredAt);
        if (timeComparison != 0) {
          return timeComparison;
        }
        return a.entry.id.compareTo(b.entry.id);
      },
    );

    if (behavioral.length < minimumBehavioralEntries) {
      return PatternObservationResult(
        observations: const <PatternObservation>[],
        behavioralEntryCount: behavioral.length,
        hasEnoughData: false,
        windowDays: windowDays,
      );
    }

    final List<PatternObservation> observations =
        <PatternObservation>[];

    final _RankedSignal? trigger = _topTrigger(behavioral);
    if (trigger != null) {
      observations.add(
        PatternObservation(
          kind: PatternObservationKind.recurringTrigger,
          message:
              '${trigger.display} appeared in ${trigger.count} '
              'logged recovery moments in the last $windowDays days.',
          evidenceCount: trigger.count,
        ),
      );
    }

    final recoverySnapshot =
        const RecoveryInsightsCalculator().calculate(
      entries: entries,
      now: localNow,
    );

    final String? timeWindow =
        recoverySnapshot.busiestTimeWindow30Days;
    if (recoverySnapshot.hasEnoughForTimePatterns &&
        timeWindow != null) {
      observations.add(
        PatternObservation(
          kind: PatternObservationKind.timeWindow,
          message:
              '$timeWindow was the most common recorded time window '
              'among your logged recovery moments in the last '
              '$windowDays days.',
          evidenceCount: recoverySnapshot.last30Days.total,
        ),
      );
    }

    final _RankedSignal? victoryAction =
        _topVictoryReplacementAction(behavioral);
    if (victoryAction != null) {
      observations.add(
        PatternObservation(
          kind: PatternObservationKind.repeatedVictoryAction,
          message:
              '${victoryAction.display} was recorded as what worked '
              'in ${victoryAction.count} victories in the last '
              '$windowDays days.',
          evidenceCount: victoryAction.count,
        ),
      );
    }

    return PatternObservationResult(
      observations: List<PatternObservation>.unmodifiable(
        observations,
      ),
      behavioralEntryCount: behavioral.length,
      hasEnoughData: true,
      windowDays: windowDays,
    );
  }

  _RankedSignal? _topTrigger(
    List<_DatedBehavioralEntry> entries,
  ) {
    final Map<String, _SignalAccumulator> counts =
        <String, _SignalAccumulator>{};

    for (final _DatedBehavioralEntry item in entries) {
      final Set<String> seenInEntry = <String>{};

      for (final String rawTrigger in item.entry.triggers) {
        final String display = rawTrigger.trim();
        final String key =
            _signalClassifier.normalizeTrigger(display);

        if (!_signalClassifier.isUserTrigger(display) ||
            !seenInEntry.add(key)) {
          continue;
        }

        final _SignalAccumulator accumulator =
            counts.putIfAbsent(
          key,
          () => _SignalAccumulator(display: display),
        );
        accumulator.count += 1;
      }
    }

    return _rankedSignal(counts);
  }

  _RankedSignal? _topVictoryReplacementAction(
    List<_DatedBehavioralEntry> entries,
  ) {
    final Map<String, _SignalAccumulator> counts =
        <String, _SignalAccumulator>{};

    for (final _DatedBehavioralEntry item in entries) {
      if (_signalClassifier.normalizeEntryType(
            item.entry.entryType,
          ) !=
          'victory') {
        continue;
      }

      final String display =
          item.entry.replacementAction.trim();
      final String key = display.toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      final _SignalAccumulator accumulator =
          counts.putIfAbsent(
        key,
        () => _SignalAccumulator(display: display),
      );
      accumulator.count += 1;
    }

    return _rankedSignal(counts);
  }

  _RankedSignal? _rankedSignal(
    Map<String, _SignalAccumulator> counts,
  ) {
    final List<MapEntry<String, _SignalAccumulator>> ranked =
        counts.entries.toList()
          ..sort(
            (
              MapEntry<String, _SignalAccumulator> a,
              MapEntry<String, _SignalAccumulator> b,
            ) {
              final int countComparison =
                  b.value.count.compareTo(a.value.count);
              if (countComparison != 0) {
                return countComparison;
              }
              return a.key.compareTo(b.key);
            },
          );

    if (ranked.isEmpty ||
        ranked.first.value.count <
            minimumRepeatedSignalCount) {
      return null;
    }

    return _RankedSignal(
      display: ranked.first.value.display,
      count: ranked.first.value.count,
    );
  }
}

class _DatedBehavioralEntry {
  const _DatedBehavioralEntry({
    required this.entry,
    required this.occurredAt,
  });

  final LogEntry entry;
  final DateTime occurredAt;
}

class _SignalAccumulator {
  _SignalAccumulator({
    required this.display,
  });

  final String display;
  int count = 0;
}

class _RankedSignal {
  const _RankedSignal({
    required this.display,
    required this.count,
  });

  final String display;
  final int count;
}
