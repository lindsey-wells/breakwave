import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/reasons/reasons_selection.dart';
import 'package:breakwave/core/reasons/reasons_store.dart';
import 'package:breakwave/features/reasons/presentation/reasons_focus_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{
        ReasonsStore.storageKey:
            const ReasonsSelection(
          selectedReasons: <String>[
            'Time with family',
          ],
          currentFocus: 'Time with family',
        ).toJsonString(),
      },
    );
  });

  testWidgets(
    'Home labels the selected reason as Current focus',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReasonsFocusCard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Current focus'),
        findsOneWidget,
      );

      expect(
        find.text('Time with family'),
        findsOneWidget,
      );

      expect(
        find.text('Your why right now'),
        findsNothing,
      );
    },
  );
}
