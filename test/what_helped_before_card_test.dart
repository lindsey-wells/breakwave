import 'package:breakwave/features/home/presentation/widgets/what_helped_before_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'What helped before stays observational and user owned',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WhatHelpedBeforeCard(
              actions: <String>[
                'Leave the room',
                'Text someone safe',
              ],
            ),
          ),
        ),
      );

      expect(find.text('What helped before'), findsOneWidget);
      expect(find.text('Leave the room'), findsOneWidget);
      expect(find.text('Text someone safe'), findsOneWidget);
      expect(
        find.textContaining('not predicting what will work next'),
        findsOneWidget,
      );
      expect(
        find.text('You decide whether any of these fit today.'),
        findsOneWidget,
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'What helped before disappears when there is no saved evidence',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WhatHelpedBeforeCard(
              actions: <String>[],
            ),
          ),
        ),
      );

      expect(find.text('What helped before'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
