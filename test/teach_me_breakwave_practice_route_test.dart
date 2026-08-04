import 'package:breakwave/core/recovery/recovery_mode_store.dart';
import 'package:breakwave/core/tutorial/breakwave_tutorial_state_store.dart';
import 'package:breakwave/features/tutorial/presentation/practice_rescue_screen.dart';
import 'package:breakwave/features/tutorial/presentation/teach_me_breakwave_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      RecoveryModeStore.storageKey: 'secular',
    });
  });

  testWidgets('Rescue tutorial opens sandbox and returns to Part 2', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TeachMeBreakWaveScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('teach-me-breakwave-next')));
    await tester.pumpAndSettle();
    expect(find.text('Part 2 of 6'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('teach-me-breakwave-practice-rescue')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PracticeRescueScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('practice-rescue-exit')));
    await tester.pumpAndSettle();

    expect(find.byType(PracticeRescueScreen), findsNothing);
    expect(find.text('Part 2 of 6'), findsOneWidget);
    expect(
      (await BreakWaveTutorialStateStore.load()).currentStep,
      1,
    );
  });
}
