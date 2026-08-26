import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/recovery_report/domain/accountability_check_in_template.dart';
import 'package:breakwave/features/recovery_report/presentation/widgets/accountability_check_in_card.dart';

void main() {
  testWidgets(
    'A12D template can be selected edited and reset locally',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AccountabilityCheckInCard(),
            ),
          ),
        ),
      );

      expect(
        find.text('Accountability check-in'),
        findsOneWidget,
      );
      expect(
        find.textContaining('nothing is sent automatically'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('accountability-copy-message'),
        ),
        findsOneWidget,
      );

      final Finder editor = find.byKey(
        const Key('accountability-check-in-editor'),
      );

      TextField field = tester.widget<TextField>(editor);
      expect(
        field.controller!.text,
        AccountabilityCheckInTemplate
            .weeklyCheckIn.starterText,
      );

      await tester.tap(
        find.byKey(
          const Key(
            'accountability-template-afterSlipHonesty',
          ),
        ),
      );
      await tester.pump();

      field = tester.widget<TextField>(editor);
      expect(
        field.controller!.text,
        AccountabilityCheckInTemplate
            .afterSlipHonesty.starterText,
      );

      await tester.enterText(
        editor,
        'My edited accountability message.',
      );
      await tester.pump();

      field = tester.widget<TextField>(editor);
      expect(
        field.controller!.text,
        'My edited accountability message.',
      );

      await tester.tap(
        find.byKey(
          const Key('accountability-reset-template'),
        ),
      );
      await tester.pump();

      field = tester.widget<TextField>(editor);
      expect(
        field.controller!.text,
        AccountabilityCheckInTemplate
            .afterSlipHonesty.starterText,
      );
    },
  );
}
