// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_snapshot.dart
// Purpose: Privacy-filtered recovery report snapshot.
// Notes: BW-87B6A2 contains aggregates and explicitly selected content only.
// ------------------------------------------------------------

import '../../insights/domain/recovery_insights_snapshot.dart';
import 'recovery_report_selection.dart';

class RecoveryReportNamedCount {
  const RecoveryReportNamedCount({
    required this.id,
    required this.label,
    required this.count,
  });

  final String id;
  final String label;
  final int count;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'count': count,
    };
  }
}

class RecoveryReportTimingPatterns {
  const RecoveryReportTimingPatterns({
    required this.days,
    required this.eligibleEntryCount,
    required this.minimumEntries,
    required this.busiestWeekday,
    required this.busiestTimeWindow,
  });

  final int days;
  final int eligibleEntryCount;
  final int minimumEntries;
  final String? busiestWeekday;
  final String? busiestTimeWindow;

  bool get hasEnoughData =>
      eligibleEntryCount >= minimumEntries;

  bool get hasObservation =>
      busiestWeekday != null ||
      busiestTimeWindow != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'days': days,
      'eligibleEntryCount': eligibleEntryCount,
      'minimumEntries': minimumEntries,
      'hasEnoughData': hasEnoughData,
      'busiestWeekday': busiestWeekday,
      'busiestTimeWindow': busiestTimeWindow,
    };
  }
}

class RecoveryReportSnapshot {
  const RecoveryReportSnapshot({
    required this.generatedAtIso,
    required this.range,
    required this.selectedSections,
    required this.summary,
    required this.triggers,
    required this.timingPatterns,
    required this.completedRoutines,
    required this.completedChristianJourneys,
    required this.hasSavedPersonalPlan,
    required this.personalPlanFields,
  });

  static const int reportVersion = 1;

  final String generatedAtIso;
  final RecoveryReportRange range;
  final List<RecoveryReportSection> selectedSections;
  final RecoveryPeriodSummary summary;
  final List<TriggerInsight> triggers;
  final RecoveryReportTimingPatterns? timingPatterns;
  final List<RecoveryReportNamedCount> completedRoutines;
  final List<RecoveryReportNamedCount>
      completedChristianJourneys;

  final bool hasSavedPersonalPlan;

  // Keys are user-facing labels. Values contain only fields
  // explicitly selected in RecoveryReportPlanSelection.
  final Map<String, List<String>> personalPlanFields;

  bool get hasRecordedRecoveryData =>
      summary.hasEntries;

  int get completedRoutineRunCount =>
      completedRoutines.fold<int>(
        0,
        (
          int total,
          RecoveryReportNamedCount item,
        ) =>
            total + item.count,
      );

  int get completedChristianJourneyRunCount =>
      completedChristianJourneys.fold<int>(
        0,
        (
          int total,
          RecoveryReportNamedCount item,
        ) =>
            total + item.count,
      );

  Map<String, dynamic> toMap() {
    final Set<RecoveryReportSection> included =
        selectedSections.toSet();

    final Map<String, dynamic> map =
        <String, dynamic>{
      'reportVersion': reportVersion,
      'generatedAtIso': generatedAtIso,
      'range': <String, dynamic>{
        'key': range.name,
        'label': range.label,
        'days': range.days,
      },
      'selectedSections': selectedSections
          .map(
            (
              RecoveryReportSection section,
            ) =>
                section.name,
          )
          .toList(growable: false),
      'summary': <String, dynamic>{
        'days': summary.days,
        'total': summary.total,
        'urges': summary.urges,
        'slips': summary.slips,
        'victories': summary.victories,
        'averageIntensity':
            summary.averageIntensity,
      },
      'excludedByDesign':
          RecoveryReportSelection.excludedByDesign,
    };

    if (included.contains(
      RecoveryReportSection.triggers,
    )) {
      map['triggers'] = triggers
          .map(
            (TriggerInsight item) =>
                <String, dynamic>{
              'label': item.trigger,
              'count': item.count,
            },
          )
          .toList(growable: false);
    }

    if (included.contains(
      RecoveryReportSection.timingPatterns,
    )) {
      map['timingPatterns'] =
          timingPatterns?.toMap();
    }

    if (included.contains(
      RecoveryReportSection.completedRoutines,
    )) {
      map['completedRoutines'] =
          completedRoutines
              .map(
                (
                  RecoveryReportNamedCount item,
                ) =>
                    item.toMap(),
              )
              .toList(growable: false);
    }

    if (included.contains(
      RecoveryReportSection
          .completedChristianJourneys,
    )) {
      map['completedChristianJourneys'] =
          completedChristianJourneys
              .map(
                (
                  RecoveryReportNamedCount item,
                ) =>
                    item.toMap(),
              )
              .toList(growable: false);
    }

    if (included.contains(
      RecoveryReportSection.personalPlan,
    )) {
      map['personalPlan'] = <String, dynamic>{
        'hasSavedPlan': hasSavedPersonalPlan,
        'fields': personalPlanFields,
      };
    }

    return map;
  }
}
