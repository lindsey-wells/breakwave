import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/personal_plan/domain/'
    'personal_recovery_plan.dart';
import 'package:breakwave/features/personal_plan/presentation/'
    'personal_recovery_plan_draft_controllers.dart';

PersonalRecoveryPlan _samplePlan() {
  return const PersonalRecoveryPlan(
    reasons: <String>['Relationships', 'Integrity'],
    primaryReason: 'Protect what matters',
    triggers: <String>['Stress'],
    dangerWindows: <String>['Late night'],
    redirectActions: <String>['Open Rescue'],
    trustedSupportName: 'Jordan',
    phoneBoundary: 'Charge outside the bedroom',
    bedtimeStrategy: 'Read for ten minutes',
    afterSlipReset: 'Stop, log, and restart',
    faithSupport: 'Pray honestly',
    createdAtIso: '2026-07-01T12:00:00.000Z',
    updatedAtIso: '2026-07-02T12:00:00.000Z',
    importedReasons: <String>['Relationships'],
    importedPrimaryReason: 'Protect what matters',
    importedTriggers: <String>['Stress'],
    importedDangerWindows: <String>['Late night'],
    importedTrustedSupportName: 'Jordan',
    importSchemaVersion: 3,
  );
}

void main() {
  test('applyPlan maps every field without reporting a user edit', () {
    int changes = 0;
    final PersonalRecoveryPlanDraftControllers controllers =
        PersonalRecoveryPlanDraftControllers(
      onChanged: () => changes += 1,
    );
    addTearDown(controllers.dispose);

    controllers.applyPlan(_samplePlan());

    expect(changes, 0);
    expect(controllers.reasons.text, 'Relationships\nIntegrity');
    expect(controllers.primaryReason.text, 'Protect what matters');
    expect(controllers.triggers.text, 'Stress');
    expect(controllers.dangerWindows.text, 'Late night');
    expect(controllers.redirectActions.text, 'Open Rescue');
    expect(controllers.trustedSupport.text, 'Jordan');
    expect(
      controllers.phoneBoundary.text,
      'Charge outside the bedroom',
    );
    expect(controllers.bedtimeStrategy.text, 'Read for ten minutes');
    expect(controllers.afterSlipReset.text, 'Stop, log, and restart');
    expect(controllers.faithSupport.text, 'Pray honestly');
  });

  test('currentDraft trims text and de-duplicates list values', () {
    int changes = 0;
    final PersonalRecoveryPlanDraftControllers controllers =
        PersonalRecoveryPlanDraftControllers(
      onChanged: () => changes += 1,
    );
    addTearDown(controllers.dispose);

    controllers.applyPlan(_samplePlan());
    controllers.reasons.text =
        ' Relationships\nrelationships, Mental clarity ';
    controllers.primaryReason.text = '  A clear mind  ';
    controllers.triggers.text = 'Stress\nstress\nBoredom';

    final PersonalRecoveryPlan draft = controllers.currentDraft();

    expect(changes, greaterThan(0));
    expect(
      draft.reasons,
      <String>['Relationships', 'Mental clarity'],
    );
    expect(draft.primaryReason, 'A clear mind');
    expect(draft.triggers, <String>['Stress', 'Boredom']);
    expect(draft.importSchemaVersion, 3);
    expect(draft.createdAtIso, '2026-07-01T12:00:00.000Z');
  });

  test('toggleSuggestion removes and adds case-insensitively', () {
    final PersonalRecoveryPlanDraftControllers controllers =
        PersonalRecoveryPlanDraftControllers(
      onChanged: () {},
    );
    addTearDown(controllers.dispose);

    controllers.reasons.text = 'Stress\nBoredom';
    controllers.toggleSuggestion(controllers.reasons, 'stress');
    expect(controllers.reasons.text, 'Boredom');

    controllers.toggleSuggestion(controllers.reasons, 'Lonely');
    expect(controllers.reasons.text, 'Boredom\nLonely');
  });

  test('updateBasePlan preserves edits and refreshes saved metadata', () {
    final PersonalRecoveryPlanDraftControllers controllers =
        PersonalRecoveryPlanDraftControllers(
      onChanged: () {},
    );
    addTearDown(controllers.dispose);

    final PersonalRecoveryPlan original = _samplePlan();
    controllers.applyPlan(original);
    controllers.primaryReason.text = 'My edited reason';

    final PersonalRecoveryPlan saved = original.copyWith(
      updatedAtIso: '2026-07-03T12:00:00.000Z',
      importSchemaVersion: 4,
    );
    controllers.updateBasePlan(saved);

    final PersonalRecoveryPlan draft = controllers.currentDraft();
    expect(draft.primaryReason, 'My edited reason');
    expect(draft.updatedAtIso, '2026-07-03T12:00:00.000Z');
    expect(draft.importSchemaVersion, 4);
  });
}
