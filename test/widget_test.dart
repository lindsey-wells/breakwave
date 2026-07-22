// BreakWave
// Created in collaboration with Cube23 Holdings LLC.

import 'package:breakwave/app/app.dart' as legacy;
import 'package:breakwave/core/theme/breakwave_theme.dart';
import 'package:breakwave/core/ui/breakwave_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BreakWave renders legacy home shell', (tester) async {
    await tester.pumpWidget(const legacy.BreakWaveApp());

    expect(find.text('BreakWave'), findsOneWidget);
    expect(find.text('Open Rescue'), findsOneWidget);
  });

  testWidgets(
    'BreakWave app bar exposes approved wordmark semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: BreakWaveTheme.dark(),
          home: const Scaffold(
            appBar: BreakWaveAppBar(
              sectionTitle: 'Home',
            ),
            body: SizedBox.shrink(),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byType(BreakWaveAppBar),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('BreakWave brand wordmark'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);
    },
  );
}
