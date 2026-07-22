// BreakWave
// Created in collaboration with Cube23 Holdings LLC.

import 'package:flutter_test/flutter_test.dart';
import 'package:breakwave/app/app.dart';

void main() {
  testWidgets('BreakWave renders home shell', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(const BreakWaveApp());
    await tester.pump();

    expect(
      find.bySemanticsLabel('BreakWave brand wordmark'),
      findsOneWidget,
    );
    expect(find.text('Open Rescue'), findsOneWidget);
  });
}
