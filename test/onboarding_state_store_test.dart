import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';

void main() {
  final DateTime fixedNow =
      DateTime.utc(2026, 7, 16, 1, 30);

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test(
    'fresh install remains not started without persistence',
    () async {
      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        state.status,
        OnboardingStatus.notStarted,
      );

      expect(
        state.shouldShowOnboarding,
        isTrue,
      );

      expect(
        prefs.containsKey(
          OnboardingStateStore.storageKey,
        ),
        isFalse,
      );
    },
  );

  test(
    'established recovery-mode user migrates as completed',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_recovery_mode_v1': 'secular',
        },
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.status,
        OnboardingStatus.completed,
      );

      expect(
        state.migratedLegacyUser,
        isTrue,
      );

      expect(
        state.shouldShowOnboarding,
        isFalse,
      );

      expect(
        await OnboardingStateStore.load(),
        isNotNull,
      );
    },
  );

  test(
    'existing log data also counts as established use',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_log_entries_v1': <String>[
            '{"id":"legacy-entry"}',
          ],
        },
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.status,
        OnboardingStatus.completed,
      );

      expect(
        state.migratedLegacyUser,
        isTrue,
      );
    },
  );

  test(
    'saved in-progress onboarding resumes exact step',
    () async {
      await OnboardingStateStore.begin(
        step: 6,
        now: fixedNow,
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.status,
        OnboardingStatus.inProgress,
      );

      expect(state.currentStep, 6);
      expect(state.shouldShowOnboarding, isTrue);
    },
  );

  test(
    'active onboarding steps are clamped safely',
    () {
      final OnboardingState below =
          OnboardingState.inProgress(
        step: -20,
        now: fixedNow,
      );

      final OnboardingState above =
          OnboardingState.inProgress(
        step: 999,
        now: fixedNow,
      );

      expect(below.currentStep, 0);

      expect(
        above.currentStep,
        OnboardingState.totalSteps - 1,
      );
    },
  );

  test(
    'completed and skipped states are terminal',
    () {
      final OnboardingState completed =
          OnboardingState.completed(
        now: fixedNow,
      );

      final OnboardingState skipped =
          OnboardingState.skipped(
        now: fixedNow,
      );

      expect(completed.isTerminal, isTrue);
      expect(skipped.isTerminal, isTrue);

      expect(
        completed.currentStep,
        OnboardingState.totalSteps,
      );

      expect(
        skipped.currentStep,
        OnboardingState.totalSteps,
      );
    },
  );

  test(
    'corrupt saved state falls back to legacy migration',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingStateStore.storageKey:
              '{not valid json',
          'bw_recovery_mode_v1': 'christian',
        },
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.status,
        OnboardingStatus.completed,
      );

      expect(
        state.migratedLegacyUser,
        isTrue,
      );
    },
  );

  test(
    'older saved schema upgrades without losing status',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingStateStore.storageKey:
              jsonEncode(
            <String, dynamic>{
              'schemaVersion': 0,
              'status': 'skipped',
              'currentStep': 2,
              'migratedLegacyUser': false,
              'updatedAtIso':
                  '2026-07-01T00:00:00.000Z',
            },
          ),
        },
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.schemaVersion,
        OnboardingState.currentSchemaVersion,
      );

      expect(
        state.status,
        OnboardingStatus.skipped,
      );

      expect(
        state.currentStep,
        OnboardingState.totalSteps,
      );
    },
  );

  test(
    'technical settings alone do not imply legacy use',
    () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_premium_state_v1':
              '{"isPlusUnlocked":false}',
          'bw_privacy_settings_v1':
              '{"blockScreenshots":true}',
        },
      );

      final OnboardingState state =
          await OnboardingStateStore
              .resolveForLaunch(
        now: fixedNow,
      );

      expect(
        state.status,
        OnboardingStatus.notStarted,
      );

      expect(
        state.migratedLegacyUser,
        isFalse,
      );
    },
  );
}
