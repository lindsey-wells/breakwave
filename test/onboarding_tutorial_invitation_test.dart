import 'dart:convert';

import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/onboarding/onboarding_launch_gate.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/core/tutorial/breakwave_tutorial_invitation_store.dart';
import 'package:breakwave/features/premium/presentation/breakwave_plus_screen.dart';
import 'package:breakwave/features/tutorial/presentation/teach_me_breakwave_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/breakwave_billing_test_harness.dart';

void _prepareFinalStep(OnboardingAccessChoice choice) {
  SharedPreferences.setMockInitialValues(<String, Object>{
    OnboardingStateStore.storageKey: jsonEncode(<String, dynamic>{
      'schemaVersion': 1,
      'status': 'inProgress',
      'currentStep': 9,
      'migratedLegacyUser': false,
      'updatedAtIso': '2026-08-03T00:00:00.000Z',
    }),
    OnboardingDraftStore.storageKey: jsonEncode(<String, dynamic>{
      'schemaVersion': 1,
      'recoveryMode': 'secular',
      'supportNeeds': <String>[],
      'reasons': <String>[],
      'currentFocus': '',
      'whyText': '',
      'triggers': <String>[],
      'riskyTimes': <String>[],
      'interruptionActions': <String>[],
      'accessChoice': choice.storageValue,
      'updatedAtIso': '2026-08-03T00:00:00.000Z',
    }),
  });
}

Widget _buildGate() {
  return buildBreakWaveBillingTestApp(
    home: const OnboardingLaunchGate(
      child: Scaffold(
        body: Center(child: Text('APP CHILD')),
      ),
    ),
  );
}

Future<void> _finishOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(_buildGate());
  await tester.pumpAndSettle();
  expect(find.text('Step 10 of 10'), findsOneWidget);
  await tester.tap(find.text('Finish setup'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Continue Free shows one optional tutorial invitation', (
    WidgetTester tester,
  ) async {
    _prepareFinalStep(OnboardingAccessChoice.continueFree);
    await _finishOnboarding(tester);

    expect(find.text('Would you like a quick tour?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tutorial-invitation-decline')));
    await tester.pumpAndSettle();

    expect(find.text('APP CHILD'), findsOneWidget);
    expect(
      await BreakWaveTutorialInvitationStore.load(),
      BreakWaveTutorialInvitationChoice.declined,
    );

    await tester.pumpWidget(_buildGate());
    await tester.pumpAndSettle();
    expect(find.text('Would you like a quick tour?'), findsNothing);
  });

  testWidgets('Show me opens the replayable tutorial', (
    WidgetTester tester,
  ) async {
    _prepareFinalStep(OnboardingAccessChoice.continueFree);
    await _finishOnboarding(tester);

    await tester.tap(find.byKey(const Key('tutorial-invitation-accept')));
    await tester.pumpAndSettle();

    expect(find.byType(TeachMeBreakWaveScreen), findsOneWidget);
    expect(find.text('Part 1 of 6'), findsOneWidget);
    expect(
      await BreakWaveTutorialInvitationStore.load(),
      BreakWaveTutorialInvitationChoice.accepted,
    );
  });

  testWidgets('Review Plus remains first, then invitation appears', (
    WidgetTester tester,
  ) async {
    _prepareFinalStep(OnboardingAccessChoice.reviewPlus);
    await _finishOnboarding(tester);

    expect(find.byType(BreakWavePlusScreen), findsOneWidget);
    expect(find.text('Would you like a quick tour?'), findsNothing);

    final BuildContext plusContext = tester.element(
      find.byType(BreakWavePlusScreen),
    );
    Navigator.of(plusContext).pop();
    await tester.pumpAndSettle();

    expect(find.text('Would you like a quick tour?'), findsOneWidget);
  });
}
