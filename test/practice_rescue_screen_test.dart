import 'dart:convert';

import 'package:breakwave/core/recovery/recovery_mode_store.dart';
import 'package:breakwave/core/why/custom_why_store.dart';
import 'package:breakwave/features/tutorial/presentation/practice_rescue_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, Object?>> _snapshotPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return <String, Object?>{
    for (final String key in prefs.getKeys()) key: prefs.get(key),
  };
}

Widget _host() {
  return MaterialApp(
    home: Builder(
      builder: (BuildContext context) {
        return Scaffold(
          body: FilledButton(
            onPressed: () {
              Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const PracticeRescueScreen(),
                ),
              );
            },
            child: const Text('Open practice'),
          ),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      RecoveryModeStore.storageKey: 'secular',
      CustomWhyStore.storageKey: jsonEncode(<String, dynamic>{
        'whyText': 'Protect my peace and future.',
        'imagePath': '',
      }),
      'bw_log_entries_v1': '[{"sentinel":true}]',
      'bw_tutorial_state_v1': '{"sentinel":true}',
      'bw_personal_recovery_plan_v1': '{"sentinel":true}',
    });
  });

  testWidgets('practice is labeled, interactive, and writes nothing', (
    WidgetTester tester,
  ) async {
    final Map<String, Object?> before = await _snapshotPreferences();

    await tester.pumpWidget(_host());
    await tester.tap(find.text('Open practice'));
    await tester.pumpAndSettle();

    expect(find.text('Practice Rescue — No Save'), findsOneWidget);
    expect(find.text('PRACTICE MODE'), findsOneWidget);
    expect(find.textContaining('No Log entry'), findsOneWidget);

    await tester.tap(find.text('4 High Risk'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Text someone safe'),
      300,
      scrollable: find.byKey(const Key('practice-rescue-scroll')),
    );
    await tester.tap(find.text('Text someone safe'));
    await tester.pump();

    expect(
      find.text('Practice only. No message was opened.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('practice-rescue-finish')),
      300,
      scrollable: find.byKey(const Key('practice-rescue-scroll')),
    );
    await tester.tap(find.byKey(const Key('practice-rescue-finish')));
    await tester.pumpAndSettle();

    expect(find.text('Open practice'), findsOneWidget);
    expect(await _snapshotPreferences(), before);
  });

  testWidgets('Exit practice leaves immediately without writes', (
    WidgetTester tester,
  ) async {
    final Map<String, Object?> before = await _snapshotPreferences();

    await tester.pumpWidget(_host());
    await tester.tap(find.text('Open practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('practice-rescue-exit')));
    await tester.pumpAndSettle();

    expect(find.text('Open practice'), findsOneWidget);
    expect(await _snapshotPreferences(), before);
  });
}
