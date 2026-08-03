// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: teach_me_breakwave_screen_test.dart
// Purpose: BW-ONBOARD-01B1 route, progress, and completion coverage.
// ------------------------------------------------------------

import 'package:breakwave/core/recovery/recovery_mode_store.dart';
import 'package:breakwave/core/tutorial/breakwave_tutorial_state_store.dart';
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

  testWidgets('tutorial advances through six compact sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TeachMeBreakWaveScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Part 1 of 6'), findsOneWidget);
    expect(find.text('What BreakWave is for'), findsOneWidget);

    await tester.tap(find.byKey(const Key('teach-me-breakwave-next')));
    await tester.pumpAndSettle();

    expect(find.text('Part 2 of 6'), findsOneWidget);
    expect(find.text('Rescue comes first'), findsOneWidget);

    await tester.tap(find.byKey(const Key('teach-me-breakwave-back')));
    await tester.pumpAndSettle();

    expect(find.text('Part 1 of 6'), findsOneWidget);
  });

  testWidgets('finishing marks the replayable tutorial complete', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const TeachMeBreakWaveScreen(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    for (int index = 0; index < 6; index++) {
      await tester.tap(find.byKey(const Key('teach-me-breakwave-next')));
      await tester.pumpAndSettle();
    }

    final state = await BreakWaveTutorialStateStore.load();
    expect(state.completed, isTrue);
    expect(find.text('Open'), findsOneWidget);
  });
}
