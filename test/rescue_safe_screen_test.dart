import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/rescue/presentation/rescue_safe_screen.dart';

void main() {
  testWidgets(
    'Rescue-safe renders generic tools without protected recovery content',
    (WidgetTester tester) async {
      bool unlockRequested = false;
      bool backRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RescueSafeScreen(
              onUnlock: () {
                unlockRequested = true;
              },
              onBackToLock: () {
                backRequested = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Rescue-safe access'), findsOneWidget);
      expect(find.text('Urge Intensity'), findsOneWidget);
      expect(find.text('Calm Reset'), findsOneWidget);
      expect(find.text('60-second pause'), findsOneWidget);
      expect(find.text('Move to a different room'), findsOneWidget);
      expect(find.text('Wave is easing'), findsOneWidget);
      expect(find.text('Still strong'), findsOneWidget);
      expect(find.text('Unlock BreakWave'), findsOneWidget);
      expect(find.text('Back to privacy lock'), findsOneWidget);

      expect(find.text('Personal Why'), findsNothing);
      expect(find.text('Log'), findsNothing);
      expect(find.text('BreakWave Plus'), findsNothing);

      await tester.ensureVisible(find.text('Still strong'));
      await tester.tap(find.text('Still strong'));
      await tester.pump();
      expect(
        find.textContaining('Stay with the generic tools'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Unlock BreakWave'));
      await tester.tap(find.text('Unlock BreakWave'));
      await tester.pump();
      expect(unlockRequested, isTrue);
      expect(backRequested, isFalse);
    },
  );

  testWidgets(
    'Rescue-safe back action returns to privacy lock',
    (WidgetTester tester) async {
      bool backRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RescueSafeScreen(
              onUnlock: () {},
              onBackToLock: () {
                backRequested = true;
              },
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Back to privacy lock'));
    await tester.tap(find.text('Back to privacy lock'));
      await tester.pump();

      expect(backRequested, isTrue);
    },
  );
}
