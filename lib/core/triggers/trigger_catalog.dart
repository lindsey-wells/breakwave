// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: trigger_catalog.dart
// Purpose: Shared trigger and risky-time vocabulary.
// Notes: Keeps onboarding, Home, and live trigger editing aligned.
// ------------------------------------------------------------

class BreakWaveTriggerCatalog {
  const BreakWaveTriggerCatalog._();

  static const List<String> triggers = <String>[
    'Stress',
    'Conflict',
    'Loneliness',
    'Boredom',
    'Scrolling',
    'Fatigue',
    'Shame spiral',
  ];

  static const List<String> riskyTimes = <String>[
    'Late night',
    'When alone',
    'After stress',
    'After conflict',
    'Bored and scrolling',
  ];
}
