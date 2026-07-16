import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/onboarding/onboarding_draft.dart';
import 'package:breakwave/core/onboarding/onboarding_draft_store.dart';
import 'package:breakwave/core/onboarding/onboarding_state.dart';
import 'package:breakwave/core/onboarding/onboarding_state_store.dart';
import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/onboarding/presentation/onboarding_flow_screen.dart';

void main() {
  Widget buildFlow({
    required int initialStep,
  }) {
    return MaterialApp(
      home: OnboardingFlowScreen(
        initialStep: initialStep,
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
    'welcome and privacy explain purpose and local control',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFlow(initialStep: 0),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key(
            'onboarding-welcome-details',
          ),
        ),
        findsOneWidget,
      );

      expect(
        find.text('Why this exists'),
        findsOneWidget,
      );

      expect(
        find.textContaining(
          'help should be within reach',
        ),
        findsOneWidget,
      );

      expect(
        find.textContaining(
          'not therapy, medical treatment, or a cure',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(
          FilledButton,
          'Continue',
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key(
            'onboarding-privacy-details',
          ),
        ),
        findsOneWidget,
      );

      expect(
        find.text('What stays private'),
        findsOneWidget,
      );

      expect(
        find.text('No automatic sharing'),
        findsOneWidget,
      );

      expect(
        find.text('Preview before sharing'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'recovery mode is required and saved only to draft',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFlow(initialStep: 2),
      );

      await tester.pumpAndSettle();

      final Finder continueButton =
          find.widgetWithText(
        FilledButton,
        'Continue',
      );

      expect(
        continueButton,
        findsOneWidget,
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNull,
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'onboarding-mode-christian',
          ),
        ),
      );

      await tester.pumpAndSettle();

      final OnboardingDraft selected =
          await OnboardingDraftStore.load();

      expect(
        selected.recoveryMode,
        RecoveryMode.christian,
      );

      final SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      expect(
        prefs.containsKey(
          'bw_recovery_mode_v1',
        ),
        isFalse,
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNotNull,
      );

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Step 4 of 10'),
        findsOneWidget,
      );

      expect(
        (
          await OnboardingStateStore.load()
        )?.currentStep,
        3,
      );
    },
  );

  testWidgets(
    'support need is required and survives draft reload',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFlow(initialStep: 3),
      );

      await tester.pumpAndSettle();

      final Finder continueButton =
          find.widgetWithText(
        FilledButton,
        'Continue',
      );

      expect(
        continueButton,
        findsOneWidget,
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNull,
      );

      final Finder supportChip =
          find.byKey(
        const ValueKey<String>(
          'support-need-Interrupt urges quickly',
        ),
      );

      expect(
        supportChip,
        findsOneWidget,
      );

      await tester.tap(supportChip);
      await tester.pumpAndSettle();

      final OnboardingDraft draft =
          await OnboardingDraftStore.load();

      expect(
        draft.supportNeeds,
        <String>[
          'Interrupt urges quickly',
        ],
      );

      expect(
        tester
            .widget<FilledButton>(
              continueButton,
            )
            .onPressed,
        isNotNull,
      );

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      await tester.pumpWidget(
        buildFlow(initialStep: 3),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('1 area selected.'),
        findsOneWidget,
      );

      final FilterChip reloadedChip =
          tester.widget<FilterChip>(
        find.byKey(
          const ValueKey<String>(
            'support-need-Interrupt urges quickly',
          ),
        ),
      );

      expect(
        reloadedChip.selected,
        isTrue,
      );
    },
  );
}
