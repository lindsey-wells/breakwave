import 'package:breakwave/features/rescue/presentation/widgets/wave_timer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget host({
    required VoidCallback onReturnHome,
    Future<void> Function(String entryType, String outcomeTag)?
        onOutcomeSaved,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WaveTimerCard(
          onReturnHome: onReturnHome,
          onOutcomeSaved: onOutcomeSaved,
        ),
      ),
    );
  }

  Future<void> finishTimer(
    WidgetTester tester,
  ) async {
    await tester.tap(find.text('Start 90-second timer'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 90));
    expect(find.text('Lower now'), findsOneWidget);
  }

  testWidgets(
    'saved timer outcome hands off to Rescue instead of returning Home',
    (WidgetTester tester) async {
      bool returnedHome = false;
      String? entryType;
      String? outcomeTag;

      await tester.pumpWidget(
        host(
          onReturnHome: () {
            returnedHome = true;
          },
          onOutcomeSaved: (
            String savedEntryType,
            String savedOutcomeTag,
          ) async {
            entryType = savedEntryType;
            outcomeTag = savedOutcomeTag;
          },
        ),
      );

      await finishTimer(tester);
      await tester.tap(find.text('Lower now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(entryType, 'Victory');
      expect(outcomeTag, 'Lower Now');
      expect(returnedHome, isFalse);
    },
  );

  testWidgets(
    'standalone timer keeps its historical Return Home fallback',
    (WidgetTester tester) async {
      bool returnedHome = false;

      await tester.pumpWidget(
        host(
          onReturnHome: () {
            returnedHome = true;
          },
        ),
      );

      await finishTimer(tester);
      await tester.tap(find.text('Lower now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(returnedHome, isTrue);
    },
  );
}
