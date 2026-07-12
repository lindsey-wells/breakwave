// BreakWave
// BW-87B3B1 personal recovery plan refresh tests.

import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/support/support_contact.dart';
import 'package:breakwave/core/triggers/triggers_selection.dart';
import 'package:breakwave/core/why/custom_why_entry.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan_prefill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PersonalRecoveryPlanPrefill prefill =
      PersonalRecoveryPlanPrefill();

  test(
    'refreshes imported sections and preserves manual additions',
    () {
      final PersonalRecoveryPlan first =
          prefill.refreshFromCurrentChoices(
        current: PersonalRecoveryPlan.empty,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>['Family'],
          currentFocus: 'Family',
        ),
        triggersSelection:
            const TriggersSelection(
          selectedTriggers: <String>['Stress'],
          selectedRiskyTimes:
              <String>['Late night'],
        ),
        supportContact:
            const SupportContact(
          name: 'Alex',
          phoneNumber: '555-0100',
          emailAddress: '',
        ),
        customWhy: const CustomWhyEntry(
          whyText: 'I want my life back.',
          imagePath: '',
        ),
        observedTriggers:
            const <String>['Boredom'],
        observedDangerWindows:
            const <String>['Sunday'],
      );

      final PersonalRecoveryPlan edited =
          first.copyWith(
        reasons: <String>[
          ...first.reasons,
          'My custom reason',
        ],
        triggers: <String>[
          ...first.triggers,
          'My custom trigger',
        ],
        phoneBoundary:
            'Charge my phone outside.',
      );

      final PersonalRecoveryPlan refreshed =
          prefill.refreshFromCurrentChoices(
        current: edited,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>['Health'],
          currentFocus: 'Health',
        ),
        triggersSelection:
            const TriggersSelection(
          selectedTriggers: <String>['Tired'],
          selectedRiskyTimes:
              <String>['Home alone'],
        ),
        supportContact:
            const SupportContact(
          name: 'Sam',
          phoneNumber: '555-0199',
          emailAddress: '',
        ),
        customWhy: const CustomWhyEntry(
          whyText: 'A new saved Why',
          imagePath: '',
        ),
        observedTriggers:
            const <String>['Environment'],
        observedDangerWindows:
            const <String>['Evening'],
      );

      expect(
        refreshed.reasons,
        containsAll(<String>[
          'My custom reason',
          'Health',
        ]),
      );
      expect(
        refreshed.reasons,
        isNot(contains('A new saved Why')),
      );
      expect(
        refreshed.reasons,
        isNot(contains('Family')),
      );

      expect(
        refreshed.triggers,
        containsAll(<String>[
          'My custom trigger',
          'Tired',
          'Environment',
        ]),
      );
      expect(
        refreshed.triggers,
        isNot(contains('Stress')),
      );

      expect(
        refreshed.dangerWindows,
        containsAll(<String>[
          'Home alone',
          'Evening',
        ]),
      );

      expect(
        refreshed.primaryReason,
        'A new saved Why',
      );
      expect(
        refreshed.trustedSupportName,
        'Sam',
      );
      expect(
        refreshed.phoneBoundary,
        'Charge my phone outside.',
      );
    },
  );

  test(
    'manual scalar edits are never replaced by refresh',
    () {
      final PersonalRecoveryPlan first =
          prefill.refreshFromCurrentChoices(
        current: PersonalRecoveryPlan.empty,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>['Family'],
          currentFocus: 'Family',
        ),
        triggersSelection:
            TriggersSelection.empty,
        supportContact:
            const SupportContact(
          name: 'Alex',
          phoneNumber: '555-0100',
          emailAddress: '',
        ),
        customWhy: CustomWhyEntry.empty,
      );

      final PersonalRecoveryPlan edited =
          first.copyWith(
        primaryReason:
            'My own wording',
        trustedSupportName: 'Jordan',
      );

      final PersonalRecoveryPlan refreshed =
          prefill.refreshFromCurrentChoices(
        current: edited,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>['Health'],
          currentFocus: 'Health',
        ),
        triggersSelection:
            TriggersSelection.empty,
        supportContact:
            const SupportContact(
          name: 'Sam',
          phoneNumber: '555-0199',
          emailAddress: '',
        ),
        customWhy: CustomWhyEntry.empty,
      );

      expect(
        refreshed.primaryReason,
        'My own wording',
      );
      expect(
        refreshed.trustedSupportName,
        'Jordan',
      );
    },
  );
  test(
    'legacy imported Why and contact refresh when metadata is missing',
    () {
      const PersonalRecoveryPlan legacyPlan =
          PersonalRecoveryPlan(
        reasons: <String>['Relationships'],
        primaryReason: 'My family',
        triggers: <String>[],
        dangerWindows: <String>[],
        redirectActions: <String>[],
        trustedSupportName: 'Alex',
        phoneBoundary: '',
        bedtimeStrategy: '',
        afterSlipReset: '',
        faithSupport: '',
        createdAtIso: '2026-07-12T10:00:00.000',
        updatedAtIso: '2026-07-12T10:00:00.000',
      );

      final PersonalRecoveryPlan refreshed =
          prefill.refreshFromCurrentChoices(
        current: legacyPlan,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>[
            'Relationships',
            'Sexual health',
          ],
          currentFocus: 'Relationships',
        ),
        triggersSelection:
            TriggersSelection.empty,
        supportContact:
            const SupportContact(
          name: 'Sam',
          phoneNumber: '555-0199',
          emailAddress: '',
        ),
        customWhy:
            const CustomWhyEntry(
          whyText: 'Mi familia',
          imagePath: '',
        ),
      );

      expect(
        refreshed.primaryReason,
        'Mi familia',
      );
      expect(
        refreshed.trustedSupportName,
        'Sam',
      );
      expect(
        refreshed.reasons,
        <String>[
          'Relationships',
          'Sexual health',
        ],
      );
      expect(
        refreshed.importedPrimaryReason,
        'Mi familia',
      );
      expect(
        refreshed.importedTrustedSupportName,
        'Sam',
      );
    },
  );

  test(
    'migrates incorrect metadata saved by earlier plan builds',
    () {
      const PersonalRecoveryPlan brokenEarlierPlan =
          PersonalRecoveryPlan(
        reasons: <String>[
          'Relationships',
          'My family',
        ],
        primaryReason: 'My family',
        triggers: <String>['Stress'],
        dangerWindows: <String>['Late night'],
        redirectActions: <String>[],
        trustedSupportName: 'Alex',
        phoneBoundary:
            'Charge my phone outside the bedroom.',
        bedtimeStrategy: '',
        afterSlipReset: '',
        faithSupport: '',
        createdAtIso: '2026-07-12T10:00:00.000',
        updatedAtIso: '2026-07-12T10:00:00.000',
        importedReasons: <String>[
          'Relationships',
          'My family',
        ],
        importedPrimaryReason: 'Relationships',
        importedTriggers: <String>['Stress'],
        importedDangerWindows: <String>['Late night'],
        importedTrustedSupportName: 'Alex',
        importSchemaVersion: 0,
      );

      final PersonalRecoveryPlan refreshed =
          prefill.refreshFromCurrentChoices(
        current: brokenEarlierPlan,
        reasonsSelection:
            const ReasonsSelection(
          selectedReasons: <String>[
            'Relationships',
            'Sexual health',
          ],
          currentFocus: 'Relationships',
        ),
        triggersSelection:
            const TriggersSelection(
          selectedTriggers: <String>[
            'Boredom',
          ],
          selectedRiskyTimes: <String>[
            'Home alone',
          ],
        ),
        supportContact:
            const SupportContact(
          name: 'Sam',
          phoneNumber: '555-0199',
          emailAddress: '',
        ),
        customWhy:
            const CustomWhyEntry(
          whyText: 'Mi familia',
          imagePath: '',
        ),
      );

      expect(
        refreshed.primaryReason,
        'Mi familia',
      );
      expect(
        refreshed.trustedSupportName,
        'Sam',
      );
      expect(
        refreshed.reasons,
        <String>[
          'Relationships',
          'Sexual health',
        ],
      );
      expect(
        refreshed.reasons,
        isNot(contains('My family')),
      );
      expect(
        refreshed.reasons,
        isNot(contains('Mi familia')),
      );
      expect(
        refreshed.phoneBoundary,
        'Charge my phone outside the bedroom.',
      );
      expect(
        refreshed.importSchemaVersion,
        PersonalRecoveryPlanPrefill
            .currentImportSchemaVersion,
      );
    },
  );

}
