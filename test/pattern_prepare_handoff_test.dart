import 'package:breakwave/features/home/presentation/widgets/pattern_prepare_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Prepare handoff is explicit and user controlled',
    (WidgetTester tester) async {
      bool requested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternPrepareCard(
              onPrepare: () {
                requested = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Prepare for the next wave'), findsOneWidget);
      expect(
        find.textContaining('choose what you want ready'),
        findsOneWidget,
      );
      expect(requested, isFalse);

      await tester.tap(find.text('Prepare for the next wave'));
      await tester.pump();

      expect(requested, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
