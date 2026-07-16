import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_completion_service.dart';
import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/reasons/reasons_store.dart';
import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/core/recovery/recovery_mode_store.dart';
import 'package:breakwave/core/triggers/triggers_selection.dart';
import 'package:breakwave/core/triggers/triggers_store.dart';
import 'package:breakwave/core/why/custom_why_entry.dart';
import 'package:breakwave/core/why/custom_why_store.dart';
import 'package:breakwave/features/personal_plan/data/personal_recovery_plan_store.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';

void main() {
  const OnboardingCompletionService service =
      OnboardingCompletionService();

  final DateTime fixedNow =
      DateTime.utc(2026, 7, 16, 5, 45);

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test(
    'completion synchronizes supported answers and clears draft',
    () async {
      await OnboardingDraftStore.save(
        OnboardingDraft.empty.copyWith(
          recoveryMode:
              RecoveryMode.christian,
          reasons: const <String>[
            'I want mental clarity.',
            'I want to protect my relationships.',
          ],
          currentFocus:
              'I want to protect my relationships.',
          whyText:
              'I want my evenings and integrity back.',
          triggers: const <String>[
            'Stress',
            'Scrolling',
          ],
          riskyTimes: const <String>[
            'Late night',
          ],
          interruptionActions:
              const <String>[
            'Open Rescue',
            'Take a short walk',
          ],
          accessChoice:
              OnboardingAccessChoice.reviewPlus,
        ),
        now: fixedNow,
      );

      final OnboardingCompletionResult result =
          await service.complete(
        now: fixedNow,
      );

      expect(result.shouldReviewPlus, isTrue);

      expect(
        await RecoveryModeStore.loadMode(),
        RecoveryMode.christian,
      );

      final ReasonsSelection reasons =
          await ReasonsStore.loadSelection();

      expect(
        reasons.selectedReasons,
        contains(
          'I want mental clarity.',
        ),
      );

      expect(
        reasons.currentFocus,
        'I want to protect my relationships.',
      );

      final TriggersSelection triggers =
          await TriggersStore.loadSelection();

      expect(
        triggers.selectedTriggers,
        <String>['Stress', 'Scrolling'],
      );

      expect(
        triggers.selectedRiskyTimes,
        <String>['Late night'],
      );

      final CustomWhyEntry why =
          await CustomWhyStore.load();

      expect(
        why.whyText,
        'I want my evenings and integrity back.',
      );

      final PersonalRecoveryPlan? plan =
          await PersonalRecoveryPlanStore.load();

      expect(plan, isNotNull);

      expect(
        plan!.redirectActions,
        <String>[
          'Open Rescue',
          'Take a short walk',
        ],
      );

      expect(
        plan.importSchemaVersion,
        greaterThan(0),
      );

      final OnboardingState? state =
          await OnboardingStateStore.load();

      expect(
        state?.status,
        OnboardingStatus.completed,
      );

      expect(
        (
          await OnboardingDraftStore.load(
            now: fixedNow,
          )
        ).hasAnyAnswer,
        isFalse,
      );
    },
  );

  test(
    'completion merges lists without replacing existing manual data',
    () async {
      await ReasonsStore.saveSelection(
        const ReasonsSelection(
          selectedReasons: <String>[
            'Existing reason',
          ],
          currentFocus:
              'Existing reason',
        ),
      );

      await TriggersStore.saveSelection(
        const TriggersSelection(
          selectedTriggers: <String>[
            'Stress',
          ],
          selectedRiskyTimes: <String>[
            'When alone',
          ],
        ),
      );

      await CustomWhyStore.save(
        const CustomWhyEntry(
          whyText: 'Existing Why',
          imagePath:
              '/local/existing-image.jpg',
        ),
      );

      await PersonalRecoveryPlanStore.save(
        const PersonalRecoveryPlan(
          reasons: <String>[],
          primaryReason:
              'Manual primary reason',
          triggers: <String>[],
          dangerWindows: <String>[],
          redirectActions: <String>[
            'Manual redirect action',
          ],
          trustedSupportName: '',
          phoneBoundary: '',
          bedtimeStrategy: '',
          afterSlipReset: '',
          faithSupport: '',
          createdAtIso:
              '2026-07-01T00:00:00.000Z',
          updatedAtIso:
              '2026-07-01T00:00:00.000Z',
        ),
      );

      await service.complete(
        draft:
            OnboardingDraft.empty.copyWith(
          reasons: const <String>[
            'New reason',
          ],
          currentFocus: 'New reason',
          whyText:
              'Draft must not replace existing Why',
          triggers: const <String>[
            'stress',
            'Scrolling',
          ],
          riskyTimes: const <String>[
            'Late night',
          ],
          interruptionActions:
              const <String>[
            'Open Rescue',
          ],
        ),
        now: fixedNow,
      );

      final ReasonsSelection reasons =
          await ReasonsStore.loadSelection();

      expect(
        reasons.selectedReasons,
        <String>[
          'Existing reason',
          'New reason',
        ],
      );

      expect(
        reasons.currentFocus,
        'New reason',
      );

      final TriggersSelection triggers =
          await TriggersStore.loadSelection();

      expect(
        triggers.selectedTriggers,
        <String>[
          'Stress',
          'Scrolling',
        ],
      );

      final CustomWhyEntry why =
          await CustomWhyStore.load();

      expect(why.whyText, 'Existing Why');

      expect(
        why.imagePath,
        '/local/existing-image.jpg',
      );

      final PersonalRecoveryPlan? plan =
          await PersonalRecoveryPlanStore.load();

      expect(
        plan?.primaryReason,
        'Manual primary reason',
      );

      expect(
        plan?.redirectActions,
        <String>[
          'Manual redirect action',
        ],
      );

      expect(
        plan?.reasons,
        contains('New reason'),
      );
    },
  );

  test(
    'repeating completion is idempotent',
    () async {
      final OnboardingDraft draft =
          OnboardingDraft.empty.copyWith(
        reasons: const <String>[
          'Mental clarity',
        ],
        currentFocus: 'Mental clarity',
        triggers: const <String>[
          'Stress',
        ],
        riskyTimes: const <String>[
          'Late night',
        ],
      );

      await service.complete(
        draft: draft,
        now: fixedNow,
      );

      await service.complete(
        draft: draft,
        now: fixedNow,
      );

      final ReasonsSelection reasons =
          await ReasonsStore.loadSelection();

      final TriggersSelection triggers =
          await TriggersStore.loadSelection();

      expect(
        reasons.selectedReasons,
        <String>['Mental clarity'],
      );

      expect(
        triggers.selectedTriggers,
        <String>['Stress'],
      );

      expect(
        triggers.selectedRiskyTimes,
        <String>['Late night'],
      );
    },
  );

  test(
    'review Plus intent never changes premium entitlement',
    () async {
      const String premiumState =
          '{"isPlusUnlocked":false,'
          '"offerVariant":"annual_no_trial"}';

      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_premium_state_v1':
              premiumState,
        },
      );

      final OnboardingCompletionResult result =
          await service.complete(
        draft:
            OnboardingDraft.empty.copyWith(
          accessChoice:
              OnboardingAccessChoice.reviewPlus,
        ),
        now: fixedNow,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(result.shouldReviewPlus, isTrue);

      expect(
        prefs.getString(
          'bw_premium_state_v1',
        ),
        premiumState,
      );
    },
  );

  test(
    'skip clears only onboarding data',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingDraftStore.storageKey:
              '{"schemaVersion":1,'
              '"reasons":["Draft reason"],'
              '"updatedAtIso":"2026-07-01"}',
          'bw_recovery_mode_v1':
              'christian',
          'bw_reasons_selection_v1':
              '{"selectedReasons":'
              '["Existing reason"],'
              '"currentFocus":"Existing reason"}',
          'bw_triggers_selection_v1':
              '{"selectedTriggers":["Stress"],'
              '"selectedRiskyTimes":[]}',
        },
      );

      await service.skip(now: fixedNow);

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.getString(
          'bw_recovery_mode_v1',
        ),
        'christian',
      );

      expect(
        prefs.containsKey(
          'bw_reasons_selection_v1',
        ),
        isTrue,
      );

      expect(
        prefs.containsKey(
          'bw_triggers_selection_v1',
        ),
        isTrue,
      );

      expect(
        prefs.containsKey(
          OnboardingDraftStore.storageKey,
        ),
        isFalse,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.status,
        OnboardingStatus.skipped,
      );
    },
  );
}
