// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: learning_card_content.dart
// Purpose: BW-28 learning card content model.
// Notes: Short practical recovery lessons for Educate Me.
// ------------------------------------------------------------

class LearningCardContent {
  const LearningCardContent({
    required this.id,
    required this.title,
    required this.meaning,
    required this.whyItMatters,
    required this.nextMove,
  });

  final String id;
  final String title;
  final String meaning;
  final String whyItMatters;
  final String nextMove;
}
