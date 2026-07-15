import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/recovery_report/domain/recovery_report_selection.dart';

void main() {
  test(
    'default report is 30-day summary only',
    () {
      const RecoveryReportSelection selection =
          RecoveryReportSelection.summaryOnly;

      expect(
        selection.range,
        RecoveryReportRange.last30Days,
      );

      expect(selection.includeSummary, isTrue);
      expect(selection.includeTriggers, isFalse);

      expect(
        selection.includeTimingPatterns,
        isFalse,
      );

      expect(
        selection.includeCompletedRoutines,
        isFalse,
      );

      expect(
        selection
            .includeCompletedChristianJourneys,
        isFalse,
      );

      expect(
        selection.includePersonalPlan,
        isFalse,
      );

      expect(
        selection.selectedSections,
        <RecoveryReportSection>{
          RecoveryReportSection.summary,
        },
      );
    },
  );

  test(
    'optional aggregate sections require opt-in',
    () {
      const RecoveryReportSelection selection =
          RecoveryReportSelection(
        range: RecoveryReportRange.last90Days,
        includeTriggers: true,
        includeTimingPatterns: true,
        includeCompletedRoutines: true,
        includeCompletedChristianJourneys:
            true,
      );

      expect(selection.range.days, 90);
      expect(selection.selectedSectionCount, 5);

      expect(
        selection.selectedSections.contains(
          RecoveryReportSection
              .completedChristianJourneys,
        ),
        isTrue,
      );
    },
  );

  test(
    'personal plan fields are individually selected',
    () {
      const RecoveryReportPlanSelection plan =
          RecoveryReportPlanSelection(
        includePrimaryReason: true,
        includeDangerWindows: true,
        includeAfterSlipReset: true,
      );

      expect(plan.anySelected, isTrue);

      expect(
        plan.selectedFieldKeys,
        <String>[
          'primaryReason',
          'dangerWindows',
          'afterSlipReset',
        ],
      );

      const RecoveryReportSelection selection =
          RecoveryReportSelection(
        personalPlan: plan,
      );

      expect(
        selection.includePersonalPlan,
        isTrue,
      );

      expect(
        selection.selectedSections.contains(
          RecoveryReportSection.personalPlan,
        ),
        isTrue,
      );
    },
  );

  test(
    'selection survives map round trip',
    () {
      const RecoveryReportSelection original =
          RecoveryReportSelection(
        range: RecoveryReportRange.last90Days,
        includeTriggers: true,
        includeCompletedRoutines: true,
        personalPlan:
            RecoveryReportPlanSelection(
          includePrimaryReason: true,
          includePhoneBoundary: true,
        ),
      );

      final RecoveryReportSelection restored =
          RecoveryReportSelection.fromMap(
        original.toMap(),
      );

      expect(
        restored.range,
        RecoveryReportRange.last90Days,
      );

      expect(restored.includeTriggers, isTrue);

      expect(
        restored.includeCompletedRoutines,
        isTrue,
      );

      expect(
        restored.personalPlan
            .includePrimaryReason,
        isTrue,
      );

      expect(
        restored.personalPlan
            .includePhoneBoundary,
        isTrue,
      );
    },
  );

  test(
    'malformed values never opt users into sharing',
    () {
      final RecoveryReportSelection restored =
          RecoveryReportSelection.fromMap(
        <String, dynamic>{
          'range': 'unknown',
          'includeTriggers': 'true',
          'includeTimingPatterns': 1,
          'personalPlan': 'invalid',
        },
      );

      expect(
        restored.range,
        RecoveryReportRange.last30Days,
      );

      expect(restored.includeTriggers, isFalse);

      expect(
        restored.includeTimingPatterns,
        isFalse,
      );

      expect(
        restored.includePersonalPlan,
        isFalse,
      );
    },
  );

  test(
    'raw logs and contact details are excluded',
    () {
      expect(
        RecoveryReportSelection
            .excludedByDesign,
        contains('Individual log entries'),
      );

      expect(
        RecoveryReportSelection
            .excludedByDesign,
        contains(
          'Log notes and CBT reflections',
        ),
      );

      expect(
        RecoveryReportSelection
            .excludedByDesign,
        contains(
          'Trusted-contact phone numbers',
        ),
      );

      expect(
        RecoveryReportSelection
            .excludedByDesign,
        contains(
          'Trusted-contact email addresses',
        ),
      );
    },
  );
}
