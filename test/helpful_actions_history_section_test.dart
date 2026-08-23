import 'package:breakwave/features/insights/domain/recovery_insights_snapshot.dart';
import 'package:breakwave/features/insights/presentation/widgets/helpful_actions_history_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'helpful-action history shows raw overlapping-window counts only',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HelpfulActionsHistorySection(
              actions: <HelpfulActionInsight>[
                HelpfulActionInsight(
                  action: 'Take a short walk',
                  victoryCount30Days: 2,
                  victoryCount90Days: 3,
                ),
                HelpfulActionInsight(
                  action: 'Put the phone down',
                  victoryCount30Days: 1,
                  victoryCount90Days: 2,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Helpful actions over time'), findsOneWidget);
      expect(find.text('From victories you recorded'), findsOneWidget);
      expect(find.text('Take a short walk'), findsOneWidget);
      expect(find.text('Put the phone down'), findsOneWidget);
      expect(
        find.text('30 days: 2 victories • 90 days: 3 victories'),
        findsOneWidget,
      );
      expect(
        find.text('30 days: 1 victory • 90 days: 2 victories'),
        findsOneWidget,
      );
      expect(
        find.textContaining('30-day window is part of the 90-day window'),
        findsOneWidget,
      );
      expect(
        find.textContaining('do not prove what caused an outcome'),
        findsOneWidget,
      );
      expect(
        find.textContaining('predict what will work next'),
        findsOneWidget,
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'helpful-action history has an honest empty state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HelpfulActionsHistorySection(
              actions: <HelpfulActionInsight>[],
            ),
          ),
        ),
      );

      expect(find.text('Helpful actions over time'), findsOneWidget);
      expect(
        find.text(
          'No helpful actions were recorded after victories '
          'in the last 90 days.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
