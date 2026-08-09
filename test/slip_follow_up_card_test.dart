import 'package:breakwave/features/log/domain/log_entry.dart';
import 'package:breakwave/features/log/presentation/log_screen.dart';
import 'package:breakwave/features/log/presentation/widgets/slip_follow_up_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Slip LogEntry is recognized without changing storage shape', () {
    final LogEntry entry = LogEntry.fromMap(<String, dynamic>{
      'id': 'slip-1',
      'entryType': 'Slip',
      'intensity': 4,
      'triggers': <String>['Stress'],
      'notes': '',
      'createdAtIso': '2026-08-09T00:00:00.000',
    });

    expect(entry.isSlip, isTrue);
    expect(entry.entryType, LogEntry.slipEntryType);
    expect(entry.toMap()['entryType'], 'Slip');
  });

  testWidgets(
    'choosing Slip opens dedicated follow-up instead of generic reflection',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        MaterialApp(
          home: LogScreen(
            onReturnHome: () {},
            onOpenRescue: () {},
            onOpenSupport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const ValueKey<String>('log-entry-type-Slip'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('slip-follow-up-card'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('What was happening just before?'),
        findsWidgets,
      );
      expect(
        find.text('What could you notice earlier next time?'),
        findsWidgets,
      );
      expect(
        find.text('What will you do next?'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'You came back and looked at what happened.',
        ),
        findsOneWidget,
      );
      expect(find.text('Next better move'), findsNothing);
    },
  );

  testWidgets(
    'Slip follow-up keeps Rescue directly available',
    (WidgetTester tester) async {
      int rescueCount = 0;
      String? selectedAction;

      final TextEditingController thought = TextEditingController();
      final TextEditingController notice = TextEditingController();
      final TextEditingController other = TextEditingController();

      Widget buildCard() {
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlipFollowUpCard(
                thoughtController: thought,
                betterPlanController: notice,
                replacementActions: const <String>[
                  'Open Rescue',
                  'Leave the room',
                  'Other',
                ],
                selectedReplacementAction: selectedAction,
                onReplacementSelected: (String? value) {
                  selectedAction = value;
                },
                otherReplacementActionController: other,
                showOtherReplacementField: false,
                onOpenRescue: () {
                  rescueCount++;
                },
                onOpenSupport: () {},
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildCard());

      await tester.tap(
        find.byKey(
          const ValueKey<String>('slip-next-action-Open Rescue'),
        ),
      );
      await tester.pumpWidget(buildCard());
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey<String>('slip-open-rescue-now'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>('slip-open-rescue-now'),
        ),
      );
      expect(rescueCount, 1);

      thought.dispose();
      notice.dispose();
      other.dispose();
    },
  );
}
