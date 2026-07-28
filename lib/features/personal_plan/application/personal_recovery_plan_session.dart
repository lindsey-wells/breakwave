// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_session.dart
// Purpose: Load, import, and save orchestration for the recovery plan.
// Notes: BW-MOD-01F keeps UI state and navigation in the screen.
// ------------------------------------------------------------

import '../../../core/recovery/recovery_mode.dart';
import '../domain/personal_recovery_plan.dart';
import 'personal_recovery_plan_workflow.dart';

typedef PersonalRecoveryPlanLoader =
    Future<PersonalRecoveryPlan?> Function();
typedef RecoveryModeLoader =
    Future<RecoveryMode?> Function();
typedef PersonalRecoveryPlanSaver =
    Future<void> Function(PersonalRecoveryPlan plan);
typedef PersonalRecoveryPlanClock = DateTime Function();

class PersonalRecoveryPlanLoadResult {
  const PersonalRecoveryPlanLoadResult({
    required this.succeeded,
    required this.savedPlan,
    required this.basePlan,
    required this.mode,
    required this.sourceUpdateAvailable,
    required this.errorMessage,
  });

  final bool succeeded;
  final PersonalRecoveryPlan? savedPlan;
  final PersonalRecoveryPlan basePlan;
  final RecoveryMode mode;
  final bool sourceUpdateAvailable;
  final String? errorMessage;
}

class PersonalRecoveryPlanImportResult {
  const PersonalRecoveryPlanImportResult({
    required this.succeeded,
    required this.plan,
    required this.changed,
    required this.statusMessage,
  });

  final bool succeeded;
  final PersonalRecoveryPlan plan;
  final bool changed;
  final String statusMessage;
}

class PersonalRecoveryPlanSaveResult {
  const PersonalRecoveryPlanSaveResult({
    required this.succeeded,
    required this.savedPlan,
    required this.statusMessage,
  });

  final bool succeeded;
  final PersonalRecoveryPlan? savedPlan;
  final String statusMessage;
}

class PersonalRecoveryPlanSession {
  const PersonalRecoveryPlanSession({
    required PersonalRecoveryPlanWorkflow workflow,
    required PersonalRecoveryPlanLoader loadPlan,
    required RecoveryModeLoader loadMode,
    required PersonalRecoveryPlanSaver savePlan,
    required PersonalRecoveryPlanClock now,
  })  : _workflow = workflow,
        _loadPlan = loadPlan,
        _loadMode = loadMode,
        _savePlan = savePlan,
        _now = now;

  final PersonalRecoveryPlanWorkflow _workflow;
  final PersonalRecoveryPlanLoader _loadPlan;
  final RecoveryModeLoader _loadMode;
  final PersonalRecoveryPlanSaver _savePlan;
  final PersonalRecoveryPlanClock _now;

  static const String emptyDraftMessage =
      'Add at least one useful part of your plan before saving.';

  bool canSave(PersonalRecoveryPlan draft) {
    return draft.hasAnyContent;
  }

  Future<PersonalRecoveryPlanLoadResult> load() async {
    try {
      final PersonalRecoveryPlan? plan = await _loadPlan();
      final RecoveryMode mode =
          await _loadMode() ?? RecoveryMode.secular;
      final PersonalRecoveryPlan basePlan =
          plan ?? PersonalRecoveryPlan.empty;
      final PersonalRecoveryPlan refreshed =
          await _workflow.refreshFromBreakWave(basePlan);

      return PersonalRecoveryPlanLoadResult(
        succeeded: true,
        savedPlan: plan,
        basePlan: basePlan,
        mode: mode,
        sourceUpdateAvailable: _workflow.hasChanges(
          current: basePlan,
          refreshed: refreshed,
        ),
        errorMessage: null,
      );
    } catch (_) {
      return const PersonalRecoveryPlanLoadResult(
        succeeded: false,
        savedPlan: null,
        basePlan: PersonalRecoveryPlan.empty,
        mode: RecoveryMode.secular,
        sourceUpdateAvailable: false,
        errorMessage:
            'BreakWave could not load your saved plan. '
            'Your other recovery data was not changed.',
      );
    }
  }

  Future<PersonalRecoveryPlanImportResult> importCurrentChoices(
    PersonalRecoveryPlan current,
  ) async {
    try {
      final PersonalRecoveryPlan imported =
          await _workflow.refreshFromBreakWave(current);
      final bool changed = _workflow.hasChanges(
        current: current,
        refreshed: imported,
      );

      return PersonalRecoveryPlanImportResult(
        succeeded: true,
        plan: imported,
        changed: changed,
        statusMessage: changed
            ? 'Current BreakWave choices and recent log patterns were added or refreshed. Custom plan work was preserved. Review the plan, then save.'
            : 'Your plan already matches the latest saved choices '
                'and recent log patterns. Custom plan work was '
                'not replaced.',
      );
    } catch (_) {
      return PersonalRecoveryPlanImportResult(
        succeeded: false,
        plan: current,
        changed: false,
        statusMessage:
            'BreakWave could not import your saved choices '
            'right now. Your plan was not changed.',
      );
    }
  }

  Future<PersonalRecoveryPlanSaveResult> save(
    PersonalRecoveryPlan draft,
  ) async {
    try {
      final PersonalRecoveryPlan saved =
          draft.preparedForSave(_now());
      await _savePlan(saved);

      return PersonalRecoveryPlanSaveResult(
        succeeded: true,
        savedPlan: saved,
        statusMessage:
            'Personal recovery plan saved on this device.',
      );
    } catch (_) {
      return const PersonalRecoveryPlanSaveResult(
        succeeded: false,
        savedPlan: null,
        statusMessage:
            'BreakWave could not save your plan right now. '
            'Your draft is still on this screen.',
      );
    }
  }
}
