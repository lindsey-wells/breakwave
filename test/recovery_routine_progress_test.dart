// BreakWave
// BW-87B4A guided routine catalog and progress tests.

import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/guided_routines/data/recovery_routine_progress_store.dart';
import 'package:breakwave/features/guided_routines/domain/recovery_routine.dart';
import 'package:breakwave/features/guided_routines/domain/recovery_routine_catalog.dart';
import 'package:breakwave/features/guided_routines/domain/recovery_routine_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test('catalog provides six actionable routines', () {
    final List<RecoveryRoutine> routines =
        RecoveryRoutineCatalog.forMode(
      RecoveryMode.secular,
    );

    expect(routines.length, 6);

    expect(
      routines.map((RecoveryRoutine item) => item.id).toSet(),
      <String>{
        'morning-reset',
        'stress-interruption',
        'loneliness-response',
        'phone-boundary-reset',
        'bedtime-protection',
        'after-slip-reset',
      },
    );

    for (final RecoveryRoutine routine in routines) {
      expect(routine.isUsable, isTrue);
      expect(routine.steps.length, greaterThanOrEqualTo(4));
      expect(routine.estimatedMinutes, greaterThan(0));
    }

    final Iterable<RecoveryRoutineStep> allSteps =
        routines.expand(
      (RecoveryRoutine routine) => routine.steps,
    );

    expect(
      allSteps.any(
        (RecoveryRoutineStep step) =>
            step.actionTarget ==
            RoutineActionTarget.rescue,
      ),
      isTrue,
    );

    expect(
      allSteps.any(
        (RecoveryRoutineStep step) =>
            step.actionTarget ==
            RoutineActionTarget.log,
      ),
      isTrue,
    );

    expect(
      allSteps.any(
        (RecoveryRoutineStep step) =>
            step.actionTarget ==
            RoutineActionTarget.support,
      ),
      isTrue,
    );

    expect(
      allSteps.any(
        (RecoveryRoutineStep step) =>
            step.actionTarget ==
            RoutineActionTarget.personalPlan,
      ),
      isTrue,
    );
  });

  test('Christian wording appears only in Christian catalog',
      () {
    final String secularText =
        RecoveryRoutineCatalog.forMode(
      RecoveryMode.secular,
    )
            .expand(
              (RecoveryRoutine routine) =>
                  routine.steps,
            )
            .map(
              (RecoveryRoutineStep step) =>
                  step.instruction,
            )
            .join(' ')
            .toLowerCase();

    final String christianText =
        RecoveryRoutineCatalog.forMode(
      RecoveryMode.christian,
    )
            .expand(
              (RecoveryRoutine routine) =>
                  routine.steps,
            )
            .map(
              (RecoveryRoutineStep step) =>
                  step.instruction,
            )
            .join(' ')
            .toLowerCase();

    expect(secularText, isNot(contains('god')));
    expect(secularText, isNot(contains('pray')));

    expect(christianText, contains('god'));
    expect(christianText, contains('pray'));
  });

  test('progress completes a run and preserves history',
      () {
    final RecoveryRoutine routine =
        RecoveryRoutineCatalog.forMode(
      RecoveryMode.secular,
    ).firstWhere(
      (RecoveryRoutine item) =>
          item.id == 'morning-reset',
    );

    RecoveryRoutineProgress progress =
        RecoveryRoutineProgress.emptyFor(routine.id);

    progress = progress.begin(
      DateTime(2026, 7, 12, 8),
    );

    expect(progress.isStarted, isTrue);
    expect(progress.isComplete, isFalse);

    for (
      int index = 0;
      index < routine.steps.length;
      index += 1
    ) {
      progress = progress.completeCurrentStep(
        stepId: routine.steps[index].id,
        totalSteps: routine.steps.length,
        now: DateTime(
          2026,
          7,
          12,
          8,
          index + 1,
        ),
      );
    }

    expect(progress.isComplete, isTrue);
    expect(progress.completionCount, 1);
    expect(
      progress.currentStepIndex,
      routine.steps.length,
    );
    expect(progress.fractionFor(routine.steps.length), 1);

    final RecoveryRoutineProgress restarted =
        progress.restart(
      DateTime(2026, 7, 13, 8),
    );

    expect(restarted.isComplete, isFalse);
    expect(restarted.currentStepIndex, 0);
    expect(restarted.completedStepIds, isEmpty);
    expect(restarted.completionCount, 1);
  });

  test('store saves and restores routine progress',
      () async {
    final RecoveryRoutineProgress progress =
        RecoveryRoutineProgress.emptyFor(
      'stress-interruption',
    ).begin(
      DateTime(2026, 7, 12, 12),
    ).completeCurrentStep(
      stepId: 'stress-name',
      totalSteps: 5,
      now: DateTime(2026, 7, 12, 12, 1),
    );

    await RecoveryRoutineProgressStore.saveProgress(
      progress,
    );

    final RecoveryRoutineProgress? loaded =
        await RecoveryRoutineProgressStore.loadFor(
      'stress-interruption',
    );

    expect(loaded, isNotNull);
    expect(loaded!.currentStepIndex, 1);
    expect(
      loaded.completedStepIds,
      <String>['stress-name'],
    );
    expect(loaded.completionCount, 0);
  });

  test('store rejects corrupt progress safely',
      () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        RecoveryRoutineProgressStore.storageKey:
            '{not-valid-json',
      },
    );

    final Map<String, RecoveryRoutineProgress> loaded =
        await RecoveryRoutineProgressStore.loadAll();

    expect(loaded, isEmpty);
  });
}
