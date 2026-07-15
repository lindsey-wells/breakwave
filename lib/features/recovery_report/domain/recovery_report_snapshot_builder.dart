// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_snapshot_builder.dart
// Purpose: Build privacy-filtered reports from real local data.
// Notes: BW-87B6A2 never copies raw logs or unselected plan fields.
// ------------------------------------------------------------

import '../../../core/recovery/recovery_mode.dart';
import '../../faith/domain/christian_journey_progress.dart';
import '../../faith/domain/christian_recovery_journey.dart';
import '../../faith/domain/christian_recovery_journey_catalog.dart';
import '../../guided_routines/domain/recovery_routine.dart';
import '../../guided_routines/domain/recovery_routine_catalog.dart';
import '../../guided_routines/domain/recovery_routine_progress.dart';
import '../../insights/domain/recovery_insights_calculator.dart';
import '../../insights/domain/recovery_insights_snapshot.dart';
import '../../log/domain/log_entry.dart';
import '../../personal_plan/domain/personal_recovery_plan.dart';
import 'recovery_report_selection.dart';
import 'recovery_report_snapshot.dart';

class RecoveryReportSnapshotBuilder {
  const RecoveryReportSnapshotBuilder({
    this.insightsCalculator =
        const RecoveryInsightsCalculator(),
  });

  static const int minimumEntriesForTimePatterns =
      RecoveryInsightsCalculator
          .minimumEntriesForTimePatterns;

  static const Set<String> _supportedTypes =
      <String>{
    'urge',
    'slip',
    'victory',
  };

  static const Set<String>
      _operationalTriggersExcludedFromReport =
      <String>{
    'rescue completion',
    'wave timer',
  };

  final RecoveryInsightsCalculator insightsCalculator;

  RecoveryReportSnapshot build({
    required RecoveryReportSelection selection,
    required List<LogEntry> entries,
    required Map<String, RecoveryRoutineProgress>
        routineProgress,
    required Map<String, ChristianJourneyProgress>
        christianJourneyProgress,
    required PersonalRecoveryPlan? personalPlan,
    required RecoveryMode recoveryMode,
    required DateTime now,
  }) {
    final DateTime localNow = now.toLocal();

    final RecoveryInsightsSnapshot insights =
        insightsCalculator.calculate(
      entries: entries,
      now: localNow,
    );

    final RecoveryPeriodSummary summary =
        selection.range ==
                RecoveryReportRange.last90Days
            ? insights.last90Days
            : insights.last30Days;

    final List<_ReportLogEntry> periodEntries =
        _entriesWithin(
      entries,
      now: localNow,
      days: selection.range.days,
    );

    final List<RecoveryReportSection>
        selectedSections =
        selection.selectedSections.toList()
          ..sort(
            (
              RecoveryReportSection a,
              RecoveryReportSection b,
            ) =>
                a.index.compareTo(b.index),
          );

    return RecoveryReportSnapshot(
      generatedAtIso: localNow.toIso8601String(),
      range: selection.range,
      selectedSections:
          List<RecoveryReportSection>.unmodifiable(
        selectedSections,
      ),
      summary: summary,
      triggers: selection.includeTriggers
          ? _topTriggers(periodEntries)
          : const <TriggerInsight>[],
      timingPatterns:
          selection.includeTimingPatterns
              ? _timingPatterns(
                  periodEntries,
                  selection.range.days,
                )
              : null,
      completedRoutines:
          selection.includeCompletedRoutines
              ? _completedRoutines(
                  routineProgress,
                  recoveryMode,
                  now: localNow,
                  days: selection.range.days,
                )
              : const <RecoveryReportNamedCount>[],
      completedChristianJourneys: selection
              .includeCompletedChristianJourneys
          ? _completedChristianJourneys(
              christianJourneyProgress,
              now: localNow,
              days: selection.range.days,
            )
          : const <RecoveryReportNamedCount>[],
      hasSavedPersonalPlan:
          personalPlan?.hasAnyContent ?? false,
      personalPlanFields:
          selection.includePersonalPlan
              ? _selectedPlanFields(
                  personalPlan,
                  selection.personalPlan,
                )
              : const <String, List<String>>{},
    );
  }

  List<_ReportLogEntry> _entriesWithin(
    List<LogEntry> entries, {
    required DateTime now,
    required int days,
  }) {
    final DateTime boundary =
        now.subtract(Duration(days: days));

    final List<_ReportLogEntry> valid =
        <_ReportLogEntry>[];

    for (final LogEntry entry in entries) {
      final DateTime? parsed =
          DateTime.tryParse(entry.createdAtIso);

      if (parsed == null) {
        continue;
      }

      final DateTime occurredAt =
          parsed.toLocal();

      final String normalizedType =
          entry.entryType.trim().toLowerCase();

      if (!_supportedTypes.contains(
            normalizedType,
          ) ||
          occurredAt.isBefore(boundary) ||
          occurredAt.isAfter(now)) {
        continue;
      }

      valid.add(
        _ReportLogEntry(
          entry: entry,
          occurredAt: occurredAt,
        ),
      );
    }

    valid.sort(
      (_ReportLogEntry a, _ReportLogEntry b) =>
          b.occurredAt.compareTo(a.occurredAt),
    );

    return List<_ReportLogEntry>.unmodifiable(
      valid,
    );
  }

  List<TriggerInsight> _topTriggers(
    List<_ReportLogEntry> entries,
  ) {
    final Map<String, _TriggerAccumulator>
        counts =
        <String, _TriggerAccumulator>{};

    for (final _ReportLogEntry item in entries) {
      final Set<String> seenInEntry =
          <String>{};

      for (final String raw
          in item.entry.triggers) {
        final String display = raw.trim();
        final String key =
            display.toLowerCase();

        if (display.isEmpty ||
            _operationalTriggersExcludedFromReport
                .contains(key) ||
            !seenInEntry.add(key)) {
          continue;
        }

        final _TriggerAccumulator accumulator =
            counts.putIfAbsent(
          key,
          () => _TriggerAccumulator(
            display: display,
          ),
        );

        accumulator.count += 1;
      }
    }

    final List<TriggerInsight> ranked =
        counts.values
            .map(
              (_TriggerAccumulator item) =>
                  TriggerInsight(
                trigger: item.display,
                count: item.count,
              ),
            )
            .toList();

    ranked.sort(
      (TriggerInsight a, TriggerInsight b) {
        final int countComparison =
            b.count.compareTo(a.count);

        if (countComparison != 0) {
          return countComparison;
        }

        return a.trigger
            .toLowerCase()
            .compareTo(
              b.trigger.toLowerCase(),
            );
      },
    );

    return List<TriggerInsight>.unmodifiable(
      ranked.take(5),
    );
  }

  RecoveryReportTimingPatterns _timingPatterns(
    List<_ReportLogEntry> entries,
    int days,
  ) {
    final bool hasEnoughData =
        entries.length >=
            minimumEntriesForTimePatterns;

    return RecoveryReportTimingPatterns(
      days: days,
      eligibleEntryCount: entries.length,
      minimumEntries:
          minimumEntriesForTimePatterns,
      busiestWeekday: hasEnoughData
          ? _dominantLabel(
              _weekdayCounts(entries),
            )
          : null,
      busiestTimeWindow: hasEnoughData
          ? _dominantLabel(
              _timeWindowCounts(entries),
            )
          : null,
    );
  }

  Map<String, int> _weekdayCounts(
    List<_ReportLogEntry> entries,
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

    final Map<String, int> counts =
        <String, int>{};

    for (final _ReportLogEntry item in entries) {
      final String label =
          names[item.occurredAt.weekday - 1];

      counts[label] =
          (counts[label] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, int> _timeWindowCounts(
    List<_ReportLogEntry> entries,
  ) {
    final Map<String, int> counts =
        <String, int>{};

    for (final _ReportLogEntry item in entries) {
      final String label =
          _timeWindowFor(
        item.occurredAt.hour,
      );

      counts[label] =
          (counts[label] ?? 0) + 1;
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

  String? _dominantLabel(
    Map<String, int> counts,
  ) {
    if (counts.isEmpty) {
      return null;
    }

    final List<MapEntry<String, int>> ranked =
        counts.entries.toList()
          ..sort(
            (
              MapEntry<String, int> a,
              MapEntry<String, int> b,
            ) {
              final int comparison =
                  b.value.compareTo(a.value);

              if (comparison != 0) {
                return comparison;
              }

              return a.key.compareTo(b.key);
            },
          );

    if (ranked.first.value < 2) {
      return null;
    }

    if (ranked.length > 1 &&
        ranked.first.value ==
            ranked[1].value) {
      return null;
    }

    return ranked.first.key;
  }

  List<RecoveryReportNamedCount>
      _completedRoutines(
    Map<String, RecoveryRoutineProgress>
        progress,
    RecoveryMode recoveryMode, {
    required DateTime now,
    required int days,
  }) {
    final List<RecoveryReportNamedCount>
        result =
        <RecoveryReportNamedCount>[];

    for (final MapEntry<String,
            RecoveryRoutineProgress> item
        in progress.entries) {
      final RecoveryRoutine? routine =
          RecoveryRoutineCatalog.findById(
        item.key,
        recoveryMode,
      );

      if (routine == null) {
        continue;
      }

      final int count = _completionCountWithin(
        item.value.completionHistoryIso,
        now: now,
        days: days,
      );

      if (count <= 0) {
        continue;
      }

      result.add(
        RecoveryReportNamedCount(
          id: routine.id,
          label: routine.title,
          count: count,
        ),
      );
    }

    return _sortedCounts(result);
  }

  List<RecoveryReportNamedCount>
      _completedChristianJourneys(
    Map<String, ChristianJourneyProgress>
        progress, {
    required DateTime now,
    required int days,
  }) {
    final Map<String, ChristianRecoveryJourney>
        journeys =
        <String, ChristianRecoveryJourney>{
      for (final ChristianRecoveryJourney journey
          in ChristianRecoveryJourneyCatalog
              .journeys)
        journey.id: journey,
    };

    final List<RecoveryReportNamedCount>
        result =
        <RecoveryReportNamedCount>[];

    for (final MapEntry<String,
            ChristianJourneyProgress> item
        in progress.entries) {
      final ChristianRecoveryJourney? journey =
          journeys[item.key];

      if (journey == null) {
        continue;
      }

      final int count = _completionCountWithin(
        item.value.completionHistoryIso,
        now: now,
        days: days,
      );

      if (count <= 0) {
        continue;
      }

      result.add(
        RecoveryReportNamedCount(
          id: journey.id,
          label: journey.title,
          count: count,
        ),
      );
    }

    return _sortedCounts(result);
  }

  int _completionCountWithin(
    List<String> completionHistoryIso, {
    required DateTime now,
    required int days,
  }) {
    final DateTime boundary =
        now.subtract(Duration(days: days));

    int count = 0;

    for (final String raw
        in completionHistoryIso) {
      final DateTime? parsed =
          DateTime.tryParse(raw);

      if (parsed == null) {
        continue;
      }

      final DateTime occurredAt =
          parsed.toLocal();

      if (!occurredAt.isBefore(boundary) &&
          !occurredAt.isAfter(now)) {
        count += 1;
      }
    }

    return count;
  }

  List<RecoveryReportNamedCount> _sortedCounts(
    List<RecoveryReportNamedCount> values,
  ) {
    values.sort(
      (
        RecoveryReportNamedCount a,
        RecoveryReportNamedCount b,
      ) {
        final int countComparison =
            b.count.compareTo(a.count);

        if (countComparison != 0) {
          return countComparison;
        }

        return a.label
            .toLowerCase()
            .compareTo(
              b.label.toLowerCase(),
            );
      },
    );

    return List<RecoveryReportNamedCount>
        .unmodifiable(values);
  }

  Map<String, List<String>> _selectedPlanFields(
    PersonalRecoveryPlan? plan,
    RecoveryReportPlanSelection selection,
  ) {
    if (plan == null) {
      return const <String, List<String>>{};
    }

    final Map<String, List<String>> fields =
        <String, List<String>>{};

    void addText(
      String label,
      String raw,
    ) {
      final String value = raw.trim();

      fields[label] = value.isEmpty
          ? const <String>[]
          : <String>[value];
    }

    void addList(
      String label,
      List<String> raw,
    ) {
      fields[label] = List<String>.unmodifiable(
        raw
            .map((String item) => item.trim())
            .where((String item) => item.isNotEmpty),
      );
    }

    if (selection.includePrimaryReason) {
      addText(
        'Primary reason',
        plan.primaryReason,
      );
    }

    if (selection.includeReasons) {
      addList(
        'Reasons that matter',
        plan.reasons,
      );
    }

    if (selection.includeTriggers) {
      addList(
        'Plan triggers',
        plan.triggers,
      );
    }

    if (selection.includeDangerWindows) {
      addList(
        'Danger windows',
        plan.dangerWindows,
      );
    }

    if (selection.includeRedirectActions) {
      addList(
        'Redirect actions',
        plan.redirectActions,
      );
    }

    if (selection.includePhoneBoundary) {
      addText(
        'Phone boundary',
        plan.phoneBoundary,
      );
    }

    if (selection.includeBedtimeStrategy) {
      addText(
        'Bedtime strategy',
        plan.bedtimeStrategy,
      );
    }

    if (selection.includeAfterSlipReset) {
      addText(
        'After-slip reset',
        plan.afterSlipReset,
      );
    }

    if (selection.includeTrustedSupportName) {
      addText(
        'Trusted support name',
        plan.trustedSupportName,
      );
    }

    if (selection.includeFaithSupport) {
      addText(
        'Faith support',
        plan.faithSupport,
      );
    }

    return Map<String, List<String>>.unmodifiable(
      fields,
    );
  }
}

class _ReportLogEntry {
  const _ReportLogEntry({
    required this.entry,
    required this.occurredAt,
  });

  final LogEntry entry;
  final DateTime occurredAt;
}

class _TriggerAccumulator {
  _TriggerAccumulator({
    required this.display,
  });

  final String display;
  int count = 0;
}
