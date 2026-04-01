// BreakWave
// Created in collaboration with Cube23 Holdings LLC.

import 'package:flutter_test/flutter_test.dart';
import 'package:breakwave/app/app.dart';

void main() {
  testWidgets('BreakWave renders home shell', (tester) async {
    await tester.pumpWidget(const BreakWaveApp());

    expect(find.text('BreakWave'), findsOneWidget);
    expect(find.text('Open Rescue'), findsOneWidget);
  });
}
