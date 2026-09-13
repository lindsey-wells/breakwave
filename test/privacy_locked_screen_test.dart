import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/privacy_lock/presentation/privacy_locked_screen.dart';

void main() {
  testWidgets('Full App locked landing exposes Unlock BreakWave and Open Rescue',
      (WidgetTester tester) async {
    int unlocks = 0;
    int rescueOpens = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyLockedScreen(
            onUnlock: () => unlocks += 1,
            onOpenRescue: () => rescueOpens += 1,
          ),
        ),
      ),
    );

    expect(find.text('Privacy lock'), findsOneWidget);
    expect(find.text('Unlock BreakWave'), findsOneWidget);
    expect(find.text('Open Rescue'), findsOneWidget);
    expect(find.textContaining('Personal Why'), findsNothing);
    expect(find.textContaining('Current Focus'), findsNothing);
    expect(find.textContaining('Plus'), findsNothing);

    await tester.tap(find.text('Open Rescue'));
    await tester.pump();

    expect(rescueOpens, 1);
    expect(unlocks, 0);
  });

  testWidgets('Rescue-safe holding surface remains generic and still locked',
      (WidgetTester tester) async {
    int unlocks = 0;
    int backToLock = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyLockedScreen(
            rescueSafeActive: true,
            onUnlock: () => unlocks += 1,
            onOpenRescue: () {},
            onBackToLock: () => backToLock += 1,
          ),
        ),
      ),
    );

    expect(find.text('Rescue-safe access'), findsOneWidget);
    expect(find.text('Unlock BreakWave'), findsOneWidget);
    expect(find.text('Back to privacy lock'), findsOneWidget);
    expect(find.text('Open Rescue'), findsNothing);
    expect(find.textContaining('private recovery information'), findsOneWidget);
    expect(find.textContaining('Personal Why'), findsNothing);
    expect(find.textContaining('Log'), findsNothing);

    await tester.tap(find.text('Back to privacy lock'));
    await tester.pump();
    expect(backToLock, 1);
    expect(unlocks, 0);
  });
}
