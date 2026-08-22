import 'package:breakwave/features/home/presentation/widgets/pattern_picture_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'Pattern Picture keeps Recognize sources visibly separate',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PatternPictureCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your Pattern Picture'), findsOneWidget);
      expect(
        find.text(
          'See the signals without turning them into conclusions.',
        ),
        findsOneWidget,
      );

      expect(find.text('Recovery moments'), findsOneWidget);
      expect(find.text('From your Log'), findsOneWidget);

      expect(find.text('Daily context'), findsOneWidget);
      expect(find.text('From Daily Check-In'), findsOneWidget);

      expect(find.text('Bedtime context'), findsOneWidget);
      expect(find.text('From bedtime check-ins'), findsOneWidget);

      expect(
        find.textContaining(
          'These are separate observations from what you recorded.',
        ),
        findsOneWidget,
      );

      expect(find.textContaining('risk score'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
