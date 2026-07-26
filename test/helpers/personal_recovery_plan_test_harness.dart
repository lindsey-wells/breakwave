// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_test_harness.dart
// Purpose: Shared widget-test helpers for BW-MOD-01A characterization.
// ------------------------------------------------------------

import 'package:breakwave/features/personal_plan/presentation/personal_recovery_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetPersonalPlanTestStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
}

Widget buildPersonalPlanSubject() {
  return const MaterialApp(
    home: PersonalRecoveryPlanScreen(),
  );
}

Future<void> pumpPersonalPlan(
  WidgetTester tester,
) async {
  await tester.pumpWidget(buildPersonalPlanSubject());
  await tester.pumpAndSettle();
}


Future<void> pumpPersonalPlanOnPushedRoute(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const PersonalRecoveryPlanScreen(),
                    ),
                  );
                },
                child: const Text('Open recovery plan'),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('Open recovery plan'));
  await tester.pumpAndSettle();
}

Finder personalPlanTextField(String label) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is TextField &&
        widget.decoration?.labelText == label,
    description: 'TextField with label "$label"',
  );
}

Finder filledButtonWithText(String text) {
  return find.ancestor(
    of: find.text(text),
    matching: find.byType(FilledButton),
  );
}

Future<void> scrollToPlanText(
  WidgetTester tester,
  String text,
) async {
  await tester.scrollUntilVisible(
    find.text(text),
    320,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> tapPlanText(
  WidgetTester tester,
  String text,
) async {
  await scrollToPlanText(tester, text);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}
