import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/recovery/recovery_mode.dart';

void main() {
  final DateTime fixedNow =
      DateTime.utc(
    2026,
    7,
    16,
    3,
    15,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test(
    'missing draft loads as empty',
    () async {
      final OnboardingDraft draft =
          await OnboardingDraftStore.load(
        now: fixedNow,
      );

      expect(
        draft,
        same(OnboardingDraft.empty),
      );

      expect(draft.hasAnyAnswer, isFalse);
    },
  );

  test(
    'save normalizes duplicate and blank answers',
    () async {
      final OnboardingDraft saved =
          await OnboardingDraftStore.save(
        OnboardingDraft(
          schemaVersion: 0,
          recoveryMode:
              RecoveryMode.christian,
          supportNeeds: const <String>[
            'Interrupt urges',
            ' interrupt urges ',
            '',
          ],
          reasons: const <String>[
            'Protect relationships',
            ' protect relationships ',
            'Mental clarity',
          ],
          currentFocus:
              'mental clarity',
          whyText:
              '  I want my evenings back.  ',
          triggers: const <String>[
            'Stress',
            'stress',
            'Scrolling',
          ],
          riskyTimes: const <String>[
            'Late night',
            ' late night ',
          ],
          interruptionActions:
              const <String>[
            'Open Rescue',
            'open rescue',
            'Take a short walk',
          ],
          accessChoice:
              OnboardingAccessChoice
                  .reviewPlus,
          updatedAtIso: '',
        ),
        now: fixedNow,
      );

      expect(
        saved.schemaVersion,
        OnboardingDraft
            .currentSchemaVersion,
      );

      expect(
        saved.supportNeeds,
        <String>['Interrupt urges'],
      );

      expect(
        saved.reasons,
        <String>[
          'Protect relationships',
          'Mental clarity',
        ],
      );

      expect(
        saved.currentFocus,
        'Mental clarity',
      );

      expect(
        saved.whyText,
        'I want my evenings back.',
      );

      expect(
        saved.triggers,
        <String>[
          'Stress',
          'Scrolling',
        ],
      );

      expect(
        saved.riskyTimes,
        <String>['Late night'],
      );

      expect(
        saved.interruptionActions,
        <String>[
          'Open Rescue',
          'Take a short walk',
        ],
      );
    },
  );

  test(
    'draft round trip preserves supported answers',
    () async {
      final OnboardingDraft original =
          OnboardingDraft.empty.copyWith(
        recoveryMode:
            RecoveryMode.secular,
        supportNeeds: const <String>[
          'Understand patterns',
        ],
        reasons: const <String>[
          'I want mental clarity.',
        ],
        currentFocus:
            'I want mental clarity.',
        whyText: 'I want peace.',
        triggers: const <String>[
          'Stress',
        ],
        riskyTimes: const <String>[
          'Late night',
        ],
        interruptionActions:
            const <String>[
          'Put the phone down',
        ],
        accessChoice:
            OnboardingAccessChoice
                .continueFree,
      );

      await OnboardingDraftStore.save(
        original,
        now: fixedNow,
      );

      final OnboardingDraft loaded =
          await OnboardingDraftStore.load(
        now: fixedNow,
      );

      expect(
        loaded.recoveryMode,
        RecoveryMode.secular,
      );

      expect(
        loaded.accessChoice,
        OnboardingAccessChoice
            .continueFree,
      );

      expect(
        loaded.whyText,
        'I want peace.',
      );
    },
  );

  test(
    'corrupt draft fails safely as empty',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingDraftStore.storageKey:
              '{not valid json',
        },
      );

      final OnboardingDraft draft =
          await OnboardingDraftStore.load(
        now: fixedNow,
      );

      expect(draft.hasAnyAnswer, isFalse);
    },
  );

  test(
    'older schema upgrades without losing answers',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingDraftStore.storageKey:
              jsonEncode(
            <String, dynamic>{
              'schemaVersion': 0,
              'recoveryMode': 'christian',
              'supportNeeds': <String>[
                'Build a plan',
              ],
              'reasons': <String>[
                'Live with integrity',
              ],
              'currentFocus':
                  'Live with integrity',
              'whyText': 'My future.',
              'triggers': <String>[
                'Stress',
              ],
              'riskyTimes': <String>[
                'Late night',
              ],
              'interruptionActions':
                  <String>[
                'Open Rescue',
              ],
              'accessChoice':
                  'continueFree',
              'updatedAtIso':
                  '2026-07-01T00:00:00.000Z',
            },
          ),
        },
      );

      final OnboardingDraft draft =
          await OnboardingDraftStore.load(
        now: fixedNow,
      );

      expect(
        draft.schemaVersion,
        OnboardingDraft
            .currentSchemaVersion,
      );

      expect(
        draft.whyText,
        'My future.',
      );
    },
  );

  test(
    'review Plus choice does not alter premium state',
    () async {
      const String existingPremium =
          '{"isPlusUnlocked":false,'
          '"offerVariant":"annual_no_trial"}';

      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_premium_state_v1':
              existingPremium,
        },
      );

      await OnboardingDraftStore.save(
        OnboardingDraft.empty.copyWith(
          accessChoice:
              OnboardingAccessChoice
                  .reviewPlus,
        ),
        now: fixedNow,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.getString(
          'bw_premium_state_v1',
        ),
        existingPremium,
      );
    },
  );

  test(
    'clearing draft leaves real recovery data untouched',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingDraftStore.storageKey:
              '{"schemaVersion":1}',
          'bw_recovery_mode_v1':
              'christian',
          'bw_reasons_selection_v1':
              '{"selectedReasons":["Family"]}',
          'bw_triggers_selection_v1':
              '{"selectedTriggers":["Stress"]}',
        },
      );

      await OnboardingDraftStore.clear();

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.containsKey(
          OnboardingDraftStore.storageKey,
        ),
        isFalse,
      );

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
    },
  );
}
