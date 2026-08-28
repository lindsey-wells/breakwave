// BreakWave
// BW-87B5A1 Christian journey model and progress tests.

import 'package:breakwave/features/faith/data/christian_journey_progress_store.dart';
import 'package:breakwave/features/faith/domain/christian_journey_progress.dart';
import 'package:breakwave/features/faith/domain/christian_recovery_journey.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test(
    'journey requires the complete Christian flow',
    () {
      const ChristianRecoveryJourney journey =
          ChristianRecoveryJourney(
        id: 'grace-after-a-slip',
        title: 'Grace after a slip',
        summary:
            'Return to truth without surrendering to shame.',
        whenToUse:
            'After a slip or when shame is encouraging secrecy.',
        estimatedMinutes: 10,
        steps: <ChristianJourneyStep>[
          ChristianJourneyStep(
            id: 'scripture',
            kind:
                ChristianJourneyStepKind
                    .scripture,
            title: 'Scripture anchor',
            body:
                'Consider what this passage reveals about grace.',
            scriptureReference:
                'Romans 8:1',
          ),
          ChristianJourneyStep(
            id: 'context',
            kind:
                ChristianJourneyStepKind
                    .context,
            title: 'Context',
            body:
                'Grace makes truthful return possible.',
          ),
          ChristianJourneyStep(
            id: 'reflection',
            kind:
                ChristianJourneyStepKind
                    .reflection,
            title: 'Reflect honestly',
            body:
                'Name what shame is asking you to hide.',
          ),
          ChristianJourneyStep(
            id: 'action',
            kind:
                ChristianJourneyStepKind
                    .action,
            title: 'Take action',
            body:
                'Open your plan and restore one boundary.',
            actionTarget:
                ChristianJourneyActionTarget
                    .personalPlan,
            actionLabel:
                'Open personal recovery plan',
          ),
          ChristianJourneyStep(
            id: 'prayer',
            kind:
                ChristianJourneyStepKind
                    .prayer,
            title: 'Pray',
            body:
                'Ask God for honesty and steadiness.',
          ),
        ],
      );

      expect(journey.isUsable, isTrue);
      expect(
        journey.hasRequiredFlow,
        isTrue,
      );

      expect(
        journey.steps.first
            .hasScriptureReference,
        isTrue,
      );

      expect(
        journey.steps[3].hasAction,
        isTrue,
      );
    },
  );

  test(
    'progress completes a journey and preserves history',
    () {
      ChristianJourneyProgress progress =
          ChristianJourneyProgress.emptyFor(
        'grace-after-a-slip',
      );

      progress = progress.begin(
        DateTime(2026, 7, 13, 9),
      );

      expect(progress.isStarted, isTrue);
      expect(progress.isComplete, isFalse);

      const List<String> stepIds =
          <String>[
        'scripture',
        'context',
        'reflection',
        'action',
        'prayer',
      ];

      for (
        int index = 0;
        index < stepIds.length;
        index += 1
      ) {
        progress =
            progress.completeCurrentStep(
          stepId: stepIds[index],
          totalSteps: stepIds.length,
          now: DateTime(
            2026,
            7,
            13,
            9,
            index + 1,
          ),
        );
      }

      expect(progress.isComplete, isTrue);
      expect(progress.completionCount, 1);
      expect(
        progress.fractionFor(
          stepIds.length,
        ),
        1,
      );

      final ChristianJourneyProgress
          restarted =
          progress.restart(
        DateTime(2026, 7, 14, 9),
      );

      expect(
        restarted.isComplete,
        isFalse,
      );

      expect(
        restarted.currentStepIndex,
        0,
      );

      expect(
        restarted.completedStepIds,
        isEmpty,
      );

      expect(
        restarted.completionCount,
        1,
      );
    },
  );

  test(
    'store saves and restores journey progress',
    () async {
      final ChristianJourneyProgress
          progress =
          ChristianJourneyProgress.emptyFor(
        'renewing-the-mind',
      ).begin(
        DateTime(2026, 7, 13, 12),
      ).completeCurrentStep(
        stepId: 'scripture',
        totalSteps: 5,
        now: DateTime(
          2026,
          7,
          13,
          12,
          1,
        ),
      );

      await ChristianJourneyProgressStore
          .saveProgress(progress);

      final ChristianJourneyProgress?
          loaded =
          await ChristianJourneyProgressStore
              .loadFor(
        'renewing-the-mind',
      );

      expect(loaded, isNotNull);

      expect(
        loaded!.currentStepIndex,
        1,
      );

      expect(
        loaded.completedStepIds,
        <String>['scripture'],
      );
    },
  );

  test(
    'private journal note is backward compatible and survives restart',
    () {
      final ChristianJourneyProgress legacy =
          ChristianJourneyProgress.fromMap(
        <String, dynamic>{
          'journeyId': 'grace-after-a-slip',
          'currentStepIndex': 2,
          'completedStepIds': <String>['scripture', 'context'],
          'startedAtIso': '2026-08-27T10:00:00.000',
          'updatedAtIso': '2026-08-27T10:05:00.000',
          'currentRunCompletedAtIso': '',
          'completionHistoryIso': <String>[],
        },
      );

      expect(legacy.journalNote, isEmpty);

      final ChristianJourneyProgress withNote =
          legacy.withJournalNote(
        note: '  I want to remember this.  ',
        now: DateTime(2026, 8, 27, 10, 6),
      );

      expect(
        withNote.journalNote,
        'I want to remember this.',
      );

      final ChristianJourneyProgress restarted =
          withNote.restart(
        DateTime(2026, 8, 28, 9),
      );

      expect(
        restarted.journalNote,
        'I want to remember this.',
      );
    },
  );

  test(
    'store saves and restores the private journey note',
    () async {
      final ChristianJourneyProgress progress =
          ChristianJourneyProgress.emptyFor(
        'rebuild-trust-with-honesty',
      ).withJournalNote(
        note: 'Practice listening without defending.',
        now: DateTime(2026, 8, 27, 11),
      );

      await ChristianJourneyProgressStore
          .saveProgress(progress);

      final ChristianJourneyProgress? loaded =
          await ChristianJourneyProgressStore.loadFor(
        'rebuild-trust-with-honesty',
      );

      expect(loaded, isNotNull);
      expect(
        loaded!.journalNote,
        'Practice listening without defending.',
      );
    },
  );

  test(
    'store rejects corrupt journey data safely',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          ChristianJourneyProgressStore
                  .storageKey:
              '{not-valid-json',
        },
      );

      final Map<String,
              ChristianJourneyProgress>
          loaded =
          await ChristianJourneyProgressStore
              .loadAll();

      expect(loaded, isEmpty);
    },
  );
}
