import 'package:breakwave/features/home/presentation/widgets/pattern_helpful_actions_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Pattern reinforcement stays observational and user owned',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PatternHelpfulActionsCard(
              actionCounts: <String, int>{
                'Leave the room': 2,
                'Text someone safe': 1,
                'Take a short walk': 3,
                'Put the phone down': 4,
              },
            ),
          ),
        ),
      );

      expect(find.text('Actions you recorded as helpful'), findsOneWidget);
      expect(find.text('From confirmed victories'), findsOneWidget);
      expect(find.text('Leave the room'), findsOneWidget);
      expect(find.text('Text someone safe'), findsOneWidget);
      expect(find.text('Take a short walk'), findsOneWidget);
      expect(find.text('Put the phone down'), findsNothing);
      expect(find.text('Recorded as helpful in 2 victories.'), findsOneWidget);
      expect(find.text('Recorded as helpful in 1 victory.'), findsOneWidget);
      expect(
        find.textContaining('do not prove what caused the outcome'),
        findsOneWidget,
      );
      expect(
        find.textContaining('predict what will work next'),
        findsOneWidget,
      );
      expect(
        find.text('You decide whether any of these fit a future wave.'),
        findsOneWidget,
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Pattern reinforcement disappears without confirmed helpful evidence',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PatternHelpfulActionsCard(
              actionCounts: <String, int>{},
            ),
          ),
        ),
      );

      expect(find.text('Actions you recorded as helpful'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
