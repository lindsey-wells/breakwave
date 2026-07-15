import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/faith/domain/christian_journey_progress.dart';
import 'package:breakwave/features/guided_routines/domain/recovery_routine_progress.dart';
import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_selection.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_snapshot_builder.dart';

LogEntry entry({
  required String id,
  required DateTime occurredAt,
  String type = 'Urge',
  int intensity = 3,
  List<String> triggers = const <String>[],
}) {
  return LogEntry(
    id: id,
    entryType: type,
    intensity: intensity,
    triggers: triggers,
    thought: 'PRIVATE THOUGHT',
    actionTaken: 'PRIVATE ACTION',
    consequence: 'PRIVATE CONSEQUENCE',
    betterPlan: 'PRIVATE BETTER PLAN',
    replacementAction: 'PRIVATE REPLACEMENT',
    notes: 'PRIVATE NOTES',
    createdAtIso: occurredAt.toIso8601String(),
  );
}

RecoveryRoutineProgress routineProgress(
  String id,
  List<DateTime> completions,
) {
  return RecoveryRoutineProgress(
    routineId: id,
    currentStepIndex: 0,
    completedStepIds: const <String>[],
    startedAtIso: '',
    updatedAtIso: '',
    currentRunCompletedAtIso: '',
    completionHistoryIso: completions
        .map((DateTime item) => item.toIso8601String())
        .toList(),
  );
}

ChristianJourneyProgress journeyProgress(
  String id,
  List<DateTime> completions,
) {
  return ChristianJourneyProgress(
    journeyId: id,
    currentStepIndex: 0,
    completedStepIds: const <String>[],
    startedAtIso: '',
    updatedAtIso: '',
    currentRunCompletedAtIso: '',
    completionHistoryIso: completions
        .map((DateTime item) => item.toIso8601String())
        .toList(),
  );
}

void main() {
  const RecoveryReportSnapshotBuilder builder =
      RecoveryReportSnapshotBuilder();

  test(
    'summary-only report excludes optional and raw content',
    () {
      final DateTime now =
          DateTime(2026, 7, 15, 12);

      final snapshot = builder.build(
        selection:
            RecoveryReportSelection.summaryOnly,
        entries: <LogEntry>[
          entry(
            id: 'recent',
            occurredAt:
                now.subtract(const Duration(days: 1)),
            type: 'Urge',
            intensity: 4,
          ),
          entry(
            id: 'old',
            occurredAt:
                now.subtract(const Duration(days: 40)),
            type: 'Slip',
          ),
          entry(
            id: 'future',
            occurredAt:
                now.add(const Duration(days: 1)),
          ),
          entry(
            id: 'unsupported',
            occurredAt:
                now.subtract(const Duration(days: 2)),
            type: 'Other',
          ),
        ],
        routineProgress:
            <String, RecoveryRoutineProgress>{},
        christianJourneyProgress:
            <String, ChristianJourneyProgress>{},
        personalPlan: null,
        recoveryMode: RecoveryMode.secular,
        now: now,
      );

      expect(snapshot.summary.total, 1);
      expect(snapshot.summary.urges, 1);
      expect(snapshot.triggers, isEmpty);
      expect(snapshot.timingPatterns, isNull);
      expect(snapshot.personalPlanFields, isEmpty);

      final String exported =
          snapshot.toMap().toString();

      expect(exported, isNot(contains('triggers:')));
      expect(
        exported,
        isNot(contains('PRIVATE THOUGHT')),
      );
      expect(
        exported,
        isNot(contains('PRIVATE NOTES')),
      );
      expect(
        exported,
        isNot(contains('PRIVATE ACTION')),
      );
    },
  );

  test(
    '90-day trigger and timing patterns use the selected range',
    () {
      final DateTime now =
          DateTime(2026, 7, 15, 12);

      final List<DateTime> mondays =
          <DateTime>[
        DateTime(2026, 6, 1, 22),
        DateTime(2026, 6, 8, 22),
        DateTime(2026, 6, 15, 22),
        DateTime(2026, 6, 22, 22),
        DateTime(2026, 6, 29, 22),
      ];

      final snapshot = builder.build(
        selection:
            const RecoveryReportSelection(
          range: RecoveryReportRange.last90Days,
          includeTriggers: true,
          includeTimingPatterns: true,
        ),
        entries: <LogEntry>[
          for (int index = 0;
              index < mondays.length;
              index += 1)
            entry(
              id: 'entry-$index',
              occurredAt: mondays[index],
              triggers: const <String>[
                'Stress',
                'stress',
                'Rescue Completion',
                'Wave Timer',
              ],
            ),
        ],
        routineProgress:
            <String, RecoveryRoutineProgress>{},
        christianJourneyProgress:
            <String, ChristianJourneyProgress>{},
        personalPlan: null,
        recoveryMode: RecoveryMode.secular,
        now: now,
      );

      expect(snapshot.summary.total, 5);
      expect(snapshot.triggers.length, 1);
      expect(snapshot.triggers.first.trigger, 'Stress');
      expect(snapshot.triggers.first.count, 5);

      expect(
        snapshot.timingPatterns?.hasEnoughData,
        isTrue,
      );

      expect(
        snapshot.timingPatterns?.busiestWeekday,
        'Monday',
      );

      expect(
        snapshot.timingPatterns
            ?.busiestTimeWindow,
        'Late night',
      );

      expect(
        snapshot.toMap().toString(),
        isNot(contains('Rescue Completion')),
      );
    },
  );

  test(
    'routine and journey counts include only selected-range completions',
    () {
      final DateTime now =
          DateTime(2026, 7, 15, 12);

      final snapshot = builder.build(
        selection:
            const RecoveryReportSelection(
          range: RecoveryReportRange.last90Days,
          includeCompletedRoutines: true,
          includeCompletedChristianJourneys:
              true,
        ),
        entries: const <LogEntry>[],
        routineProgress:
            <String, RecoveryRoutineProgress>{
          'morning-reset': routineProgress(
            'morning-reset',
            <DateTime>[
              now.subtract(
                const Duration(days: 10),
              ),
              now.subtract(
                const Duration(days: 40),
              ),
              now.subtract(
                const Duration(days: 100),
              ),
            ],
          ),
          'stress-interruption': routineProgress(
            'stress-interruption',
            <DateTime>[
              now.subtract(
                const Duration(days: 20),
              ),
            ],
          ),
          'unknown-routine': routineProgress(
            'unknown-routine',
            <DateTime>[
              now.subtract(
                const Duration(days: 5),
              ),
            ],
          ),
        },
        christianJourneyProgress:
            <String, ChristianJourneyProgress>{
          'grace-after-a-slip': journeyProgress(
            'grace-after-a-slip',
            <DateTime>[
              now.subtract(
                const Duration(days: 5),
              ),
              now.subtract(
                const Duration(days: 30),
              ),
              now.subtract(
                const Duration(days: 100),
              ),
            ],
          ),
          'unknown-journey': journeyProgress(
            'unknown-journey',
            <DateTime>[
              now.subtract(
                const Duration(days: 2),
              ),
            ],
          ),
        },
        personalPlan: null,
        recoveryMode: RecoveryMode.christian,
        now: now,
      );

      expect(
        snapshot.completedRoutineRunCount,
        3,
      );

      expect(
        snapshot.completedRoutines
            .firstWhere(
              (item) =>
                  item.id == 'morning-reset',
            )
            .count,
        2,
      );

      expect(
        snapshot
            .completedChristianJourneyRunCount,
        2,
      );

      expect(
        snapshot.completedChristianJourneys
            .single
            .label,
        'Grace after a slip',
      );

      expect(
        snapshot.toMap().toString(),
        isNot(contains('unknown-routine')),
      );
    },
  );

  test(
    'personal plan snapshot contains only explicitly selected fields',
    () {
      final DateTime now =
          DateTime(2026, 7, 15, 12);

      final PersonalRecoveryPlan plan =
          PersonalRecoveryPlan(
        reasons: const <String>[
          'Relationships',
        ],
        primaryReason: 'My family',
        triggers: const <String>['Stress'],
        dangerWindows: const <String>[
          'Late night',
        ],
        redirectActions: const <String>[
          'Take a walk',
        ],
        trustedSupportName: 'Alex',
        phoneBoundary: 'Charge outside room',
        bedtimeStrategy: 'Read before bed',
        afterSlipReset: 'Log and restart',
        faithSupport: 'PRIVATE FAITH SUPPORT',
        createdAtIso: now.toIso8601String(),
        updatedAtIso: now.toIso8601String(),
      );

      final snapshot = builder.build(
        selection:
            const RecoveryReportSelection(
          personalPlan:
              RecoveryReportPlanSelection(
            includePrimaryReason: true,
            includeDangerWindows: true,
            includeTrustedSupportName: true,
          ),
        ),
        entries: const <LogEntry>[],
        routineProgress:
            <String, RecoveryRoutineProgress>{},
        christianJourneyProgress:
            <String, ChristianJourneyProgress>{},
        personalPlan: plan,
        recoveryMode: RecoveryMode.secular,
        now: now,
      );

      expect(snapshot.hasSavedPersonalPlan, isTrue);

      expect(
        snapshot.personalPlanFields.keys,
        <String>[
          'Primary reason',
          'Danger windows',
          'Trusted support name',
        ],
      );

      final String exported =
          snapshot.toMap().toString();

      expect(exported, contains('My family'));
      expect(exported, contains('Late night'));
      expect(exported, contains('Alex'));

      expect(
        exported,
        isNot(contains('Charge outside room')),
      );

      expect(
        exported,
        isNot(contains('PRIVATE FAITH SUPPORT')),
      );

      expect(
        exported,
        isNot(contains('Take a walk')),
      );
    },
  );
}
