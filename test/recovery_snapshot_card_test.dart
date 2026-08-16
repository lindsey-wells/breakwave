import 'package:breakwave/features/home/presentation/widgets/recovery_snapshot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Recovery Snapshot shows reflections and reconciles all saved entry categories',
    (WidgetTester tester) async {
      int openLogCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoverySnapshotCard(
              totalEntries: 8,
              urgeCount: 1,
              slipCount: 4,
              victoryCount: 2,
              reflectionCount: 1,
              onOpenLog: () {
                openLogCount += 1;
              },
            ),
          ),
        ),
      );

      expect(find.text('Saved entries'), findsOneWidget);
      expect(find.text('Urges'), findsOneWidget);
      expect(find.text('Slips'), findsOneWidget);
      expect(find.text('Victories'), findsOneWidget);
      expect(find.text('Reflections'), findsOneWidget);

      expect(find.text('8'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Reflections'));
      await tester.pump();

      expect(openLogCount, 1);
    },
  );
}
