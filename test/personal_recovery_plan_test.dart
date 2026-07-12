// BreakWave
// BW-87B3A personal recovery plan domain and storage tests.

import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/support/support_contact.dart';
import 'package:breakwave/core/triggers/triggers_selection.dart';
import 'package:breakwave/core/why/custom_why_entry.dart';
import 'package:breakwave/features/personal_plan/data/personal_recovery_plan_store.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan.dart';
import 'package:breakwave/features/personal_plan/domain/personal_recovery_plan_prefill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const PersonalRecoveryPlanPrefill prefill =
      PersonalRecoveryPlanPrefill();

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test('normalizes stored list values safely', () {
    final PersonalRecoveryPlan plan =
        PersonalRecoveryPlan.fromMap(
      <String, dynamic>{
        'reasons': <dynamic>[
          'Family',
          ' family ',
          '',
          'Health',
        ],
        'triggers': <dynamic>[
          'Stress',
          'stress',
          'Tired',
        ],
      },
    );

    expect(
      plan.reasons,
      <String>['Family', 'Health'],
    );

    expect(
      plan.triggers,
      <String>['Stress', 'Tired'],
    );
  });

  test('prefills empty sections from current choices', () {
    final PersonalRecoveryPlan result =
        prefill.fillEmptySections(
      current: PersonalRecoveryPlan.empty,
      reasonsSelection: const ReasonsSelection(
        selectedReasons: <String>[
          'Family',
          'Health',
        ],
        currentFocus: 'Family',
      ),
      triggersSelection: const TriggersSelection(
        selectedTriggers: <String>[
          'Stress',
          'Tired',
        ],
        selectedRiskyTimes: <String>[
          'Late night',
        ],
      ),
      supportContact: const SupportContact(
        name: 'Alex',
        phoneNumber: '555-0100',
        emailAddress: 'alex@example.com',
      ),
      customWhy: const CustomWhyEntry(
        whyText: 'I want my life back.',
        imagePath: '',
      ),
    );

    expect(
      result.reasons,
      <String>['Family', 'Health'],
    );
    expect(result.primaryReason, 'Family');
    expect(
      result.triggers,
      <String>['Stress', 'Tired'],
    );
    expect(
      result.dangerWindows,
      <String>['Late night'],
    );
    expect(result.trustedSupportName, 'Alex');
  });

  test('prefill never overwrites existing plan work', () {
    const PersonalRecoveryPlan current =
        PersonalRecoveryPlan(
      reasons: <String>['My existing reason'],
      primaryReason: 'My existing focus',
      triggers: <String>['My existing trigger'],
      dangerWindows: <String>['My existing window'],
      redirectActions: <String>['Leave the room'],
      trustedSupportName: 'Jordan',
      phoneBoundary: 'Charge the phone outside.',
      bedtimeStrategy: 'Read before bed.',
      afterSlipReset: 'Tell the truth and restart.',
      faithSupport: 'Pray and contact support.',
      createdAtIso: '',
      updatedAtIso: '',
    );

    final PersonalRecoveryPlan result =
        prefill.fillEmptySections(
      current: current,
      reasonsSelection: const ReasonsSelection(
        selectedReasons: <String>['Imported reason'],
        currentFocus: 'Imported reason',
      ),
      triggersSelection: const TriggersSelection(
        selectedTriggers: <String>['Imported trigger'],
        selectedRiskyTimes: <String>['Imported window'],
      ),
      supportContact: const SupportContact(
        name: 'Imported contact',
        phoneNumber: '555-0199',
        emailAddress: 'other@example.com',
      ),
      customWhy: const CustomWhyEntry(
        whyText: 'Imported why',
        imagePath: '',
      ),
    );

    expect(result.reasons, current.reasons);
    expect(result.primaryReason, current.primaryReason);
    expect(result.triggers, current.triggers);
    expect(
      result.dangerWindows,
      current.dangerWindows,
    );
    expect(
      result.redirectActions,
      current.redirectActions,
    );
    expect(
      result.trustedSupportName,
      current.trustedSupportName,
    );
    expect(result.phoneBoundary, current.phoneBoundary);
    expect(
      result.bedtimeStrategy,
      current.bedtimeStrategy,
    );
    expect(
      result.afterSlipReset,
      current.afterSlipReset,
    );
    expect(result.faithSupport, current.faithSupport);
  });

  test('preparedForSave preserves created date', () {
    final DateTime firstSave =
        DateTime(2026, 7, 12, 10);
    final DateTime secondSave =
        DateTime(2026, 7, 13, 11);

    final PersonalRecoveryPlan first =
        PersonalRecoveryPlan.empty
            .copyWith(primaryReason: 'My reason')
            .preparedForSave(firstSave);

    final PersonalRecoveryPlan second =
        first.preparedForSave(secondSave);

    expect(
      first.createdAtIso,
      firstSave.toIso8601String(),
    );
    expect(
      second.createdAtIso,
      first.createdAtIso,
    );
    expect(
      second.updatedAtIso,
      secondSave.toIso8601String(),
    );
  });

  test('store saves, loads, and rejects corrupt JSON',
      () async {
    final PersonalRecoveryPlan saved =
        PersonalRecoveryPlan.empty
            .copyWith(
              primaryReason: 'Build a better life',
              trustedSupportName: 'Alex',
            )
            .preparedForSave(
              DateTime(2026, 7, 12, 12),
            );

    await PersonalRecoveryPlanStore.save(saved);

    final PersonalRecoveryPlan? loaded =
        await PersonalRecoveryPlanStore.load();

    expect(loaded, isNotNull);
    expect(
      loaded!.primaryReason,
      'Build a better life',
    );
    expect(
      loaded.trustedSupportName,
      'Alex',
    );

    SharedPreferences.setMockInitialValues(
      <String, Object>{
        PersonalRecoveryPlanStore.storageKey:
            '{not-valid-json',
      },
    );

    expect(
      await PersonalRecoveryPlanStore.load(),
      isNull,
    );
  });
}
