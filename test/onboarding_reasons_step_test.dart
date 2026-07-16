import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/core/reasons/reasons_store.dart';
import 'package:breakwave/core/why/custom_why_store.dart';
import 'package:breakwave/features/onboarding/presentation/onboarding_flow_screen.dart';

void main() {
  Widget buildFlow() {
    return MaterialApp(
      home: OnboardingFlowScreen(
        initialStep: 4,
        onFinished: (
          OnboardingStatus status,
        ) {},
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  testWidgets(
    'Step 5 requires a reason and saves focus only to draft',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFlow(),
      );

      await tester.pumpAndSettle();

      final Finder continueButton =
          find.widgetWithText(
        FilledButton,
        'Continue',
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNull,
      );

      const String reason =
          'I want mental clarity.';

      final Finder reasonChip =
          find.byKey(
        const ValueKey<String>(
          'onboarding-reason-I want mental clarity.',
        ),
      );

      await tester.ensureVisible(
        reasonChip,
      );

      await tester.pumpAndSettle();

      await tester.tap(reasonChip);
      await tester.pumpAndSettle();

      final OnboardingDraft draft =
          await OnboardingDraftStore.load();

      expect(
        draft.reasons,
        <String>[reason],
      );

      expect(
        draft.currentFocus,
        reason,
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNotNull,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.containsKey(
          ReasonsStore.storageKey,
        ),
        isFalse,
      );

      expect(
        prefs.containsKey(
          CustomWhyStore.storageKey,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'custom reason and written Why survive navigation and reload',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFlow(),
      );

      await tester.pumpAndSettle();

      const String customReason =
          'I want peaceful evenings.';

      const String whyText =
          'I want to be present, honest, and free.';

      final Finder customField =
          find.byKey(
        const Key(
          'onboarding-custom-reason-field',
        ),
      );

      await tester.ensureVisible(
        customField,
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        customField,
        customReason,
      );

      final Finder addButton =
          find.byKey(
        const Key(
          'onboarding-add-custom-reason',
        ),
      );

      await tester.ensureVisible(
        addButton,
      );

      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final Finder whyField =
          find.byKey(
        const Key(
          'onboarding-why-field',
        ),
      );

      await tester.ensureVisible(
        whyField,
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        whyField,
        whyText,
      );

      await tester.pump();

      final Finder continueButton =
          find.widgetWithText(
        FilledButton,
        'Continue',
      );

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Step 6 of 10'),
        findsOneWidget,
      );

      final OnboardingDraft saved =
          await OnboardingDraftStore.load();

      expect(
        saved.reasons,
        <String>[customReason],
      );

      expect(
        saved.currentFocus,
        customReason,
      );

      expect(
        saved.whyText,
        whyText,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.currentStep,
        5,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.containsKey(
          ReasonsStore.storageKey,
        ),
        isFalse,
      );

      expect(
        prefs.containsKey(
          CustomWhyStore.storageKey,
        ),
        isFalse,
      );

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      await tester.pumpWidget(
        buildFlow(),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'onboarding-custom-reason-I want peaceful evenings.',
          ),
        ),
        findsOneWidget,
      );

      final TextField reloadedWhy =
          tester.widget<TextField>(
        find.byKey(
          const Key(
            'onboarding-why-field',
          ),
        ),
      );

      expect(
        reloadedWhy.controller?.text,
        whyText,
      );
    },
  );
}
