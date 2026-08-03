// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_state_store_test.dart
// Purpose: BW-ONBOARD-01B1 local tutorial-state coverage.
// ------------------------------------------------------------

import 'package:breakwave/core/tutorial/breakwave_tutorial_state.dart';
import 'package:breakwave/core/tutorial/breakwave_tutorial_state_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('tutorial state starts locally without changing onboarding', () async {
    final BreakWaveTutorialState state =
        await BreakWaveTutorialStateStore.load(
      now: DateTime.utc(2026, 8, 2),
    );

    expect(state.currentStep, 0);
    expect(state.completed, isFalse);
  });

  test('tutorial progress and completion are replay-safe', () async {
    await BreakWaveTutorialStateStore.saveProgress(
      step: 3,
      now: DateTime.utc(2026, 8, 2, 1),
    );

    BreakWaveTutorialState state =
        await BreakWaveTutorialStateStore.load();
    expect(state.currentStep, 3);
    expect(state.completed, isFalse);

    await BreakWaveTutorialStateStore.complete(
      now: DateTime.utc(2026, 8, 2, 2),
    );

    state = await BreakWaveTutorialStateStore.load();
    expect(
      state.currentStep,
      BreakWaveTutorialState.totalSteps - 1,
    );
    expect(state.completed, isTrue);
    expect(state.completedAtIso, isNotNull);
  });
}
