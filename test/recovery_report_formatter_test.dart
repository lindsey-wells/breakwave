import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/insights/domain/recovery_insights_snapshot.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_formatter.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_selection.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_snapshot.dart';

RecoveryReportSnapshot buildSnapshot({
  List<RecoveryReportSection> sections =
      const <RecoveryReportSection>[
    RecoveryReportSection.summary,
  ],
  List<TriggerInsight> triggers =
      const <TriggerInsight>[],
  RecoveryReportTimingPatterns? timingPatterns,
  List<RecoveryReportNamedCount> routines =
      const <RecoveryReportNamedCount>[],
  List<RecoveryReportNamedCount> journeys =
      const <RecoveryReportNamedCount>[],
  bool hasSavedPlan = false,
  Map<String, List<String>> planFields =
      const <String, List<String>>{},
}) {
  return RecoveryReportSnapshot(
    generatedAtIso:
        DateTime(2026, 7, 15, 12).toIso8601String(),
    range: RecoveryReportRange.last30Days,
    selectedSections: sections,
    summary: const RecoveryPeriodSummary(
      days: 30,
      total: 4,
      urges: 2,
      slips: 1,
      victories: 1,
      averageIntensity: 3.25,
    ),
    triggers: triggers,
    timingPatterns: timingPatterns,
    completedRoutines: routines,
    completedChristianJourneys: journeys,
    hasSavedPersonalPlan: hasSavedPlan,
    personalPlanFields: planFields,
  );
}

void main() {
  test(
    'summary-only text excludes optional headings',
    () {
      final String text =
          RecoveryReportFormatter.buildText(
        buildSnapshot(),
      );

      expect(
        text,
        contains('BreakWave Recovery Summary'),
      );

      expect(
        text,
        contains('Recorded moments: 4'),
      );

      expect(
        text,
        contains(
          'Average recorded intensity: 3.3 / 5',
        ),
      );

      expect(
        text,
        isNot(contains('TOP RECORDED TRIGGERS')),
      );

      expect(
        text,
        isNot(contains('PRIVATE NOTES')),
      );
    },
  );

  test(
    'selected aggregate sections render readable content',
    () {
      final String text =
          RecoveryReportFormatter.buildText(
        buildSnapshot(
          sections: const <RecoveryReportSection>[
            RecoveryReportSection.summary,
            RecoveryReportSection.triggers,
            RecoveryReportSection.timingPatterns,
            RecoveryReportSection.completedRoutines,
            RecoveryReportSection
                .completedChristianJourneys,
          ],
          triggers: const <TriggerInsight>[
            TriggerInsight(
              trigger: 'Stress',
              count: 3,
            ),
          ],
          timingPatterns:
              const RecoveryReportTimingPatterns(
            days: 30,
            eligibleEntryCount: 6,
            minimumEntries: 5,
            busiestWeekday: 'Monday',
            busiestTimeWindow: 'Late night',
          ),
          routines:
              const <RecoveryReportNamedCount>[
            RecoveryReportNamedCount(
              id: 'morning-reset',
              label: 'Morning reset',
              count: 2,
            ),
          ],
          journeys:
              const <RecoveryReportNamedCount>[
            RecoveryReportNamedCount(
              id: 'grace-after-a-slip',
              label: 'Grace after a slip',
              count: 1,
            ),
          ],
        ),
      );

      expect(text, contains('Stress: 3 entries'));
      expect(text, contains('Monday'));
      expect(text, contains('Late night'));
      expect(
        text,
        contains('Morning reset: 2 completions'),
      );
      expect(
        text,
        contains('Grace after a slip: 1 completion'),
      );
    },
  );

  test(
    'personal plan output includes only snapshot fields',
    () {
      final String text =
          RecoveryReportFormatter.buildText(
        buildSnapshot(
          sections: const <RecoveryReportSection>[
            RecoveryReportSection.summary,
            RecoveryReportSection.personalPlan,
          ],
          hasSavedPlan: true,
          planFields:
              const <String, List<String>>{
            'Primary reason': <String>[
              'My family',
            ],
            'Danger windows': <String>[
              'Late night',
            ],
          },
        ),
      );

      expect(text, contains('My family'));
      expect(text, contains('Late night'));

      expect(
        text,
        isNot(contains('PRIVATE FAITH SUPPORT')),
      );

      expect(
        text,
        isNot(contains('phone number')),
      );
    },
  );

  test(
    'empty optional sections explain missing data',
    () {
      final String text =
          RecoveryReportFormatter.buildText(
        buildSnapshot(
          sections: const <RecoveryReportSection>[
            RecoveryReportSection.summary,
            RecoveryReportSection.triggers,
            RecoveryReportSection.timingPatterns,
            RecoveryReportSection.completedRoutines,
            RecoveryReportSection.personalPlan,
          ],
          timingPatterns:
              const RecoveryReportTimingPatterns(
            days: 30,
            eligibleEntryCount: 2,
            minimumEntries: 5,
            busiestWeekday: null,
            busiestTimeWindow: null,
          ),
        ),
      );

      expect(
        text,
        contains(
          'No triggers were recorded in this period.',
        ),
      );

      expect(
        text,
        contains('At least 5 valid entries'),
      );

      expect(
        text,
        contains(
          'No guided routine completions',
        ),
      );

      expect(
        text,
        contains(
          'No saved personal recovery plan',
        ),
      );
    },
  );

  test(
    'json contains structured filtered snapshot',
    () {
      final String json =
          RecoveryReportFormatter.buildJson(
        buildSnapshot(
          sections: const <RecoveryReportSection>[
            RecoveryReportSection.summary,
            RecoveryReportSection.triggers,
          ],
          triggers: const <TriggerInsight>[
            TriggerInsight(
              trigger: 'Stress',
              count: 2,
            ),
          ],
        ),
      );

      expect(json, contains('"reportVersion": 1'));
      expect(json, contains('"summary"'));
      expect(json, contains('"Stress"'));

      expect(
        json,
        isNot(contains('PRIVATE THOUGHT')),
      );

      expect(
        json,
        isNot(contains('emailAddress')),
      );
    },
  );
}
