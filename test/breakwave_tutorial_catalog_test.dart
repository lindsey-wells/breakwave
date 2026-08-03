// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_catalog_test.dart
// Purpose: BW-ONBOARD-01B1 mode and access-policy copy coverage.
// ------------------------------------------------------------

import 'package:breakwave/core/recovery/recovery_mode.dart';
import 'package:breakwave/features/tutorial/domain/breakwave_tutorial_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tutorial remains compact and secular content stays secular', () {
    final List<BreakWaveTutorialStep> steps =
        BreakWaveTutorialCatalog.build(RecoveryMode.secular);
    final String copy = steps
        .expand((BreakWaveTutorialStep step) => <String>[
              step.summary,
              ...step.points,
            ])
        .join(' ');

    expect(steps.length, 6);
    expect(copy, contains('Always free:'));
    expect(copy, contains('Plus candidates:'));
    expect(copy, isNot(contains('Christian recovery journeys')));
  });

  test('Christian mode includes clearly Christian recovery depth', () {
    final List<BreakWaveTutorialStep> steps =
        BreakWaveTutorialCatalog.build(RecoveryMode.christian);
    final String copy = steps
        .expand((BreakWaveTutorialStep step) => <String>[
              step.summary,
              ...step.points,
            ])
        .join(' ');

    expect(steps.length, 6);
    expect(copy, contains('prayer, Scripture, grace'));
    expect(copy, contains('Christian recovery journeys'));
  });
}
