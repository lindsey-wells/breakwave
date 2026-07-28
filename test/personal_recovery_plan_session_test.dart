// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_session_test.dart
// Purpose: BW-MOD-01F session orchestration coverage.
// ------------------------------------------------------------

import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/insights/domain/recovery_insights_calculator.dart';
import 'package:breakwave/features/log/data/log_repository.dart';
import 'package:breakwave/features/personal_plan/application/personal_recovery_plan_session.dart';
import 'package:breakwave/features/personal_plan/application/personal_recovery_plan_workflow.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan_prefill.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkflow extends PersonalRecoveryPlanWorkflow {
  _FakeWorkflow({
    required this.refreshed,
    this.throwOnRefresh = false,
  }) : super(
          prefill: const PersonalRecoveryPlanPrefill(),
          logRepository: const LogRepository(),
          insightsCalculator:
              const RecoveryInsightsCalculator(),
        );

  final PersonalRecoveryPlan refreshed;
  final bool throwOnRefresh;

  @override
  Future<PersonalRecoveryPlan> refreshFromBreakWave(
    PersonalRecoveryPlan current,
  ) async {
    if (throwOnRefresh) {
      throw StateError('refresh failed');
    }
    return refreshed;
  }
}

void main() {
  final DateTime fixedNow =
      DateTime.utc(2026, 7, 28, 19, 30);

  PersonalRecoveryPlanSession buildSession({
    PersonalRecoveryPlan? loadedPlan,
    RecoveryMode? mode,
    PersonalRecoveryPlan? refreshed,
    bool loadFails = false,
    bool refreshFails = false,
    bool saveFails = false,
    void Function(PersonalRecoveryPlan plan)? onSave,
  }) {
    final PersonalRecoveryPlan next =
        refreshed ?? loadedPlan ?? PersonalRecoveryPlan.empty;

    return PersonalRecoveryPlanSession(
      workflow: _FakeWorkflow(
        refreshed: next,
        throwOnRefresh: refreshFails,
      ),
      loadPlan: () async {
        if (loadFails) {
          throw StateError('load failed');
        }
        return loadedPlan;
      },
      loadMode: () async => mode,
      savePlan: (PersonalRecoveryPlan plan) async {
        if (saveFails) {
          throw StateError('save failed');
        }
        onSave?.call(plan);
      },
      now: () => fixedNow,
    );
  }

  test('load returns saved plan mode and source-update state',
      () async {
    final PersonalRecoveryPlan saved =
        PersonalRecoveryPlan.empty.copyWith(
      primaryReason: 'Protect my future',
    );
    final PersonalRecoveryPlan refreshed =
        saved.copyWith(
      triggers: const <String>['Stress'],
    );
    final PersonalRecoveryPlanSession session =
        buildSession(
      loadedPlan: saved,
      mode: RecoveryMode.christian,
      refreshed: refreshed,
    );

    final PersonalRecoveryPlanLoadResult result =
        await session.load();

    expect(result.succeeded, isTrue);
    expect(result.savedPlan, same(saved));
    expect(result.basePlan, same(saved));
    expect(result.mode, RecoveryMode.christian);
    expect(result.sourceUpdateAvailable, isTrue);
    expect(result.errorMessage, isNull);
  });

  test('load failure returns the existing safe error message',
      () async {
    final PersonalRecoveryPlanLoadResult result =
        await buildSession(loadFails: true).load();

    expect(result.succeeded, isFalse);
    expect(
      result.errorMessage,
      contains('Your other recovery data was not changed.'),
    );
  });

  test('import reports changed content and preservation wording',
      () async {
    final PersonalRecoveryPlan current =
        PersonalRecoveryPlan.empty.copyWith(
      reasons: const <String>['My custom reason'],
    );
    final PersonalRecoveryPlan refreshed =
        current.copyWith(
      triggers: const <String>['Stress'],
    );
    final PersonalRecoveryPlanImportResult result =
        await buildSession(
      refreshed: refreshed,
    ).importCurrentChoices(current);

    expect(result.succeeded, isTrue);
    expect(result.changed, isTrue);
    expect(result.plan.triggers, const <String>['Stress']);
    expect(
      result.statusMessage,
      contains('Custom plan work was preserved.'),
    );
  });

  test('import failure preserves the current plan', () async {
    final PersonalRecoveryPlan current =
        PersonalRecoveryPlan.empty.copyWith(
      primaryReason: 'Keep going',
    );
    final PersonalRecoveryPlanImportResult result =
        await buildSession(
      refreshFails: true,
    ).importCurrentChoices(current);

    expect(result.succeeded, isFalse);
    expect(result.changed, isFalse);
    expect(result.plan, same(current));
    expect(
      result.statusMessage,
      contains('Your plan was not changed.'),
    );
  });

  test('empty draft validation stays synchronous', () {
    final PersonalRecoveryPlanSession session =
        buildSession();

    expect(
      session.canSave(PersonalRecoveryPlan.empty),
      isFalse,
    );
    expect(
      PersonalRecoveryPlanSession.emptyDraftMessage,
      contains('Add at least one useful part'),
    );
  });

  test('save prepares timestamps and returns the saved plan',
      () async {
    PersonalRecoveryPlan? captured;
    final PersonalRecoveryPlan draft =
        PersonalRecoveryPlan.empty.copyWith(
      primaryReason: 'Protect my peace',
    );

    final PersonalRecoveryPlanSaveResult result =
        await buildSession(
      onSave: (PersonalRecoveryPlan plan) {
        captured = plan;
      },
    ).save(draft);

    expect(result.succeeded, isTrue);
    expect(result.savedPlan, isNotNull);
    expect(captured, same(result.savedPlan));
    expect(
      result.savedPlan!.updatedAtIso,
      fixedNow.toIso8601String(),
    );
    expect(
      result.statusMessage,
      'Personal recovery plan saved on this device.',
    );
  });

  test('save failure keeps the existing draft-safe wording',
      () async {
    final PersonalRecoveryPlan draft =
        PersonalRecoveryPlan.empty.copyWith(
      primaryReason: 'Keep trying',
    );
    final PersonalRecoveryPlanSaveResult result =
        await buildSession(
      saveFails: true,
    ).save(draft);

    expect(result.succeeded, isFalse);
    expect(result.savedPlan, isNull);
    expect(
      result.statusMessage,
      contains('Your draft is still on this screen.'),
    );
  });
}
