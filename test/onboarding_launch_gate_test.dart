import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_launch_gate.dart';
import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/features/rescue/presentation/rescue_screen.dart';

void main() {
  Widget buildGate() {
    return const MaterialApp(
      home: OnboardingLaunchGate(
        child: Scaffold(
          body: Center(
            child: Text('APP CHILD'),
          ),
        ),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  testWidgets(
    'fresh user enters onboarding and begins at step one',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      expect(
        find.text('Step 1 of 10'),
        findsOneWidget,
      );

      expect(
        find.text('Welcome to BreakWave'),
        findsOneWidget,
      );

      final OnboardingState? state =
          await OnboardingStateStore.load();

      expect(
        state?.status,
        OnboardingStatus.inProgress,
      );

      expect(state?.currentStep, 0);
    },
  );

  testWidgets(
    'established user bypasses onboarding',
    (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          'bw_recovery_mode_v1': 'secular',
        },
      );

      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      expect(
        find.text('APP CHILD'),
        findsOneWidget,
      );

      expect(
        find.text('BreakWave setup'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'interrupted user resumes saved step',
    (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{
          OnboardingStateStore.storageKey:
              jsonEncode(
            <String, dynamic>{
              'schemaVersion': 1,
              'status': 'inProgress',
              'currentStep': 4,
              'migratedLegacyUser': false,
              'updatedAtIso':
                  '2026-07-16T00:00:00.000Z',
            },
          ),
        },
      );

      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      expect(
        find.text('Step 5 of 10'),
        findsOneWidget,
      );

      expect(
        find.text(
          'What are you protecting?',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'continue and back persist exact progress',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(
          FilledButton,
          'Continue',
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Step 2 of 10'),
        findsOneWidget,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.currentStep,
        1,
      );

      await tester.tap(
        find.widgetWithText(
          OutlinedButton,
          'Back',
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Step 1 of 10'),
        findsOneWidget,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.currentStep,
        0,
      );
    },
  );

  testWidgets(
    'skip exits onboarding without trapping the user',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Skip setup'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Skip setup for now?',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Skip onboarding'),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('APP CHILD'),
        findsOneWidget,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.status,
        OnboardingStatus.skipped,
      );
    },
  );

  testWidgets(
    'Rescue opens and returns to the same step',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildGate());
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(
          'Need help now? Open Rescue',
        ),
      );

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.byType(RescueScreen),
        findsOneWidget,
      );

      final BuildContext rescueContext =
          tester.element(
        find.byType(RescueScreen),
      );

      Navigator.of(rescueContext).pop();

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Step 1 of 10'),
        findsOneWidget,
      );
    },
  );
}
