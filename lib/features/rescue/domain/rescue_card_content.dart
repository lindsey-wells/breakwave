// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_card_content.dart
// Purpose: BW-16 rescue card content model.
// Notes: Data model for reusable rescue card rendering.
// ------------------------------------------------------------

class RescueCardContent {
  const RescueCardContent({
    required this.id,
    required this.title,
    required this.calmLine,
    required this.reframe,
    required this.immediateAction,
    required this.nextStep,
  });

  final String id;
  final String title;
  final String calmLine;
  final String reframe;
  final String immediateAction;
  final String nextStep;
}
