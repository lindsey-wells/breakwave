// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_workflow_test.dart
// Purpose: BW-MOD-01D refresh-workflow characterization.
// ------------------------------------------------------------

import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/reasons/reasons_store.dart';
import 'package:breakwave/features/insights/domain/recovery_insights_calculator.dart';
import 'package:breakwave/features/log/data/log_repository.dart';
import 'package:breakwave/features/personal_plan/application/personal_recovery_plan_workflow.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan_prefill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const PersonalRecoveryPlanWorkflow workflow =
      PersonalRecoveryPlanWorkflow(
    prefill: PersonalRecoveryPlanPrefill(),
    logRepository: LogRepository(),
    insightsCalculator: RecoveryInsightsCalculator(),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'refresh imports current reasons through the extracted workflow',
    () async {
      await ReasonsStore.saveSelection(
        const ReasonsSelection(
          selectedReasons: <String>['Relationships'],
          currentFocus: 'Relationships',
        ),
      );

      final PersonalRecoveryPlan refreshed =
          await workflow.refreshFromBreakWave(
        PersonalRecoveryPlan.empty,
      );

      expect(refreshed.reasons, <String>['Relationships']);
      expect(refreshed.primaryReason, 'Relationships');
      expect(
        refreshed.importSchemaVersion,
        PersonalRecoveryPlanPrefill.currentImportSchemaVersion,
      );
    },
  );

  test(
    'editable signature ignores display case and scalar whitespace',
    () {
      const PersonalRecoveryPlan first = PersonalRecoveryPlan(
        reasons: <String>['Relationships'],
        primaryReason: 'Freedom',
        triggers: <String>['Stress'],
        dangerWindows: <String>[],
        redirectActions: <String>['Open Rescue'],
        trustedSupportName: 'Alex',
        phoneBoundary: 'Phone away',
        bedtimeStrategy: '',
        afterSlipReset: '',
        faithSupport: '',
        createdAtIso: '',
        updatedAtIso: '',
      );
      final PersonalRecoveryPlan second = first.copyWith(
        reasons: <String>['relationships'],
        primaryReason: '  freedom  ',
        triggers: <String>['stress'],
        trustedSupportName: ' alex ',
      );

      expect(
        workflow.editableSignature(second),
        workflow.editableSignature(first),
      );
    },
  );

  test('source metadata is compared separately from editable content', () {
    const PersonalRecoveryPlan first = PersonalRecoveryPlan.empty;
    final PersonalRecoveryPlan second = first.copyWith(
      importSchemaVersion: 2,
      importedReasons: <String>['Relationships'],
    );

    expect(
      workflow.editableSignature(second),
      workflow.editableSignature(first),
    );
    expect(
      workflow.importSourceSignature(second),
      isNot(workflow.importSourceSignature(first)),
    );
    expect(
      workflow.hasChanges(current: first, refreshed: second),
      isTrue,
    );
  });

  test('identical plans report no workflow changes', () {
    const PersonalRecoveryPlan plan = PersonalRecoveryPlan.empty;

    expect(
      workflow.hasChanges(current: plan, refreshed: plan),
      isFalse,
    );
  });
}
