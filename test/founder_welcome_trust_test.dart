import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/support/presentation/widgets/who_we_are_card.dart';

void main() {
  testWidgets(
    'Who We Are introduces the people and purpose without shame or promises',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WhoWeAreCard(),
            ),
          ),
        ),
      );

      expect(find.text('Who We Are'), findsOneWidget);
      expect(
        find.textContaining('shake your hand and congratulate you'),
        findsOneWidget,
      );
      expect(
        find.textContaining('We did not build BreakWave to judge or shame you'),
        findsOneWidget,
      );
      expect(
        find.textContaining('not therapy, medical treatment, a diagnosis'),
        findsOneWidget,
      );
      expect(
        find.text("Let's break the wave, one choice at a time."),
        findsOneWidget,
      );
    },
  );
}
