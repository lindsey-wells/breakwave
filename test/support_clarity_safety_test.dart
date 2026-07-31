// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_clarity_safety_test.dart
// Purpose: BW-SUPPORT-01B clarity and safety widget coverage.
// ------------------------------------------------------------

import 'package:breakwave/features/support/presentation/widgets/cbt_informed_support_card.dart';
import 'package:breakwave/features/support/presentation/widgets/emergency_help_card.dart';
import 'package:breakwave/features/support/presentation/widgets/professional_help_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'emergency guidance clearly labels U.S. 911 and outside-U.S. use',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(const EmergencyHelpCard()));

      expect(find.text('Immediate danger'), findsOneWidget);
      expect(find.text('Call 911 (U.S.)'), findsOneWidget);
      expect(
        find.text(
          'In the United States, this button calls 911. Outside the United States, use your local emergency number.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('not an immediate emergency'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'professional-help guidance opens independently',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(const ProfessionalHelpCard()));

      expect(find.text('When to seek professional help'), findsOneWidget);
      expect(
        find.textContaining('seek emergency help immediately'),
        findsNothing,
      );

      await tester.tap(find.text('When to seek professional help'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('seek emergency help immediately'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CBT detail is progressively disclosed',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(const CbtInformedSupportCard()));

      expect(find.text('Cognitive behavioral tools'), findsOneWidget);
      expect(find.textContaining('CBT means'), findsNothing);

      await tester.tap(find.text('Cognitive behavioral tools'));
      await tester.pumpAndSettle();

      expect(find.textContaining('CBT means'), findsOneWidget);
      expect(find.text('Important safety note'), findsOneWidget);
    },
  );
}
