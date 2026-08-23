import 'package:breakwave/features/personal_plan/presentation/widgets/confirmed_helpful_actions_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'confirmed helpful actions require an explicit user choice',
    (WidgetTester tester) async {
      String? chosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmedHelpfulActionsPicker(
              actions: const <String>[
                'Leave the room',
                'Text someone safe',
              ],
              selectedAction: '',
              onUseAction: (String action) {
                chosen = action;
              },
            ),
          ),
        ),
      );

      expect(chosen, isNull);
      expect(find.text('Helpful actions you confirmed'), findsOneWidget);
      expect(
        find.textContaining('not recommending what you should do next'),
        findsOneWidget,
      );
      expect(
        find.text('Use Leave the room in my plan'),
        findsOneWidget,
      );
      expect(
        find.text('Use Text someone safe in my plan'),
        findsOneWidget,
      );
      expect(
        find.textContaining('not saved until you save your recovery plan'),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Use Leave the room in my plan'),
      );
      await tester.pump();

      expect(chosen, 'Leave the room');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'picker disappears when there is no confirmed helpful evidence',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmedHelpfulActionsPicker(
              actions: const <String>[],
              selectedAction: '',
              onUseAction: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Helpful actions you confirmed'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
