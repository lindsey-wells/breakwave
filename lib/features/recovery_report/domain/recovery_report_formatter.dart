// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_formatter.dart
// Purpose: Human-readable and structured recovery report output.
// Notes: BW-87B6A3 formats only the privacy-filtered snapshot.
// ------------------------------------------------------------

import 'dart:convert';

import 'recovery_report_selection.dart';
import 'recovery_report_snapshot.dart';

class RecoveryReportFormatter {
  const RecoveryReportFormatter._();

  static const String reportTitle =
      'BreakWave Recovery Summary';

  static const String privacyNotice =
      'This report was created on your device from the sections '
      'you selected. It does not include individual logs, private '
      'notes, CBT reflections, phone numbers, or email addresses.';

  static const String supportNotice =
      'BreakWave is a recovery-support tool, not medical or '
      'mental-health treatment.';

  static String buildText(
    RecoveryReportSnapshot snapshot,
  ) {
    final List<String> lines = <String>[
      reportTitle,
      '',
      'Period: ${snapshot.range.label}',
      'Generated: ${_formatDateTime(snapshot.generatedAtIso)}',
      '',
      'RECOVERY SUMMARY',
      'Recorded moments: ${snapshot.summary.total}',
      'Urges: ${snapshot.summary.urges}',
      'Victories: ${snapshot.summary.victories}',
      'Slips: ${snapshot.summary.slips}',
      snapshot.summary.hasEntries
          ? 'Average recorded intensity: '
              '${snapshot.summary.averageIntensity.toStringAsFixed(1)} / 5'
          : 'Average recorded intensity: No recorded data',
    ];

    final Set<RecoveryReportSection> sections =
        snapshot.selectedSections.toSet();

    if (sections.contains(
      RecoveryReportSection.triggers,
    )) {
      lines.addAll(<String>[
        '',
        'TOP RECORDED TRIGGERS',
      ]);

      if (snapshot.triggers.isEmpty) {
        lines.add(
          'No triggers were recorded in this period.',
        );
      } else {
        for (final trigger in snapshot.triggers) {
          lines.add(
            '• ${trigger.trigger}: ${trigger.count} '
            '${trigger.count == 1 ? 'entry' : 'entries'}',
          );
        }
      }
    }

    if (sections.contains(
      RecoveryReportSection.timingPatterns,
    )) {
      lines.addAll(<String>[
        '',
        'TIMING OBSERVATIONS',
      ]);

      final RecoveryReportTimingPatterns? timing =
          snapshot.timingPatterns;

      if (timing == null || !timing.hasEnoughData) {
        lines.add(
          'At least '
          '${timing?.minimumEntries ?? 5} valid entries are needed '
          'before weekday or time observations are shown.',
        );
      } else if (!timing.hasObservation) {
        lines.add(
          'No single weekday or time window clearly stood out '
          'in this period.',
        );
      } else {
        if (timing.busiestWeekday != null) {
          lines.add(
            'Most common recorded weekday: '
            '${timing.busiestWeekday}',
          );
        }

        if (timing.busiestTimeWindow != null) {
          lines.add(
            'Most common recorded time window: '
            '${timing.busiestTimeWindow}',
          );
        }
      }
    }

    if (sections.contains(
      RecoveryReportSection.completedRoutines,
    )) {
      lines.addAll(<String>[
        '',
        'COMPLETED GUIDED ROUTINES',
      ]);

      if (snapshot.completedRoutines.isEmpty) {
        lines.add(
          'No guided routine completions were recorded '
          'in this period.',
        );
      } else {
        for (final item in snapshot.completedRoutines) {
          lines.add(
            '• ${item.label}: ${item.count} '
            '${item.count == 1 ? 'completion' : 'completions'}',
          );
        }

        lines.add(
          'Total routine completions: '
          '${snapshot.completedRoutineRunCount}',
        );
      }
    }

    if (sections.contains(
      RecoveryReportSection
          .completedChristianJourneys,
    )) {
      lines.addAll(<String>[
        '',
        'COMPLETED CHRISTIAN JOURNEYS',
      ]);

      if (snapshot
          .completedChristianJourneys.isEmpty) {
        lines.add(
          'No Christian journey completions were recorded '
          'in this period.',
        );
      } else {
        for (final item
            in snapshot.completedChristianJourneys) {
          lines.add(
            '• ${item.label}: ${item.count} '
            '${item.count == 1 ? 'completion' : 'completions'}',
          );
        }

        lines.add(
          'Total Christian journey completions: '
          '${snapshot.completedChristianJourneyRunCount}',
        );
      }
    }

    if (sections.contains(
      RecoveryReportSection.personalPlan,
    )) {
      lines.addAll(<String>[
        '',
        'SELECTED RECOVERY PLAN DETAILS',
      ]);

      if (!snapshot.hasSavedPersonalPlan) {
        lines.add(
          'No saved personal recovery plan was available.',
        );
      } else if (snapshot.personalPlanFields.isEmpty) {
        lines.add(
          'The selected recovery-plan fields were empty.',
        );
      } else {
        for (final MapEntry<String, List<String>> field
            in snapshot.personalPlanFields.entries) {
          lines.add('${field.key}:');

          if (field.value.isEmpty) {
            lines.add('• Not provided');
          } else {
            for (final String value in field.value) {
              lines.add('• $value');
            }
          }
        }
      }
    }

    lines.addAll(<String>[
      '',
      'PRIVACY',
      privacyNotice,
      '',
      supportNotice,
    ]);

    return lines.join('\n');
  }

  static String buildJson(
    RecoveryReportSnapshot snapshot,
  ) {
    return const JsonEncoder.withIndent(' ').convert(
      snapshot.toMap(),
    );
  }

  static String _formatDateTime(
    String iso,
  ) {
    final DateTime? parsed = DateTime.tryParse(iso);

    if (parsed == null) {
      return 'Unknown';
    }

    final DateTime local = parsed.toLocal();

    String two(int value) =>
        value.toString().padLeft(2, '0');

    return '${local.month}/${local.day}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
