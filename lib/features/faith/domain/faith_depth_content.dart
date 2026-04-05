// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: faith_depth_content.dart
// Purpose: BW-26 faith depth content model.
// Notes: Data model for premium Christian depth reflections.
// ------------------------------------------------------------

class FaithDepthContent {
  const FaithDepthContent({
    required this.id,
    required this.title,
    required this.anchor,
    required this.reflection,
    required this.practice,
    required this.prayer,
  });

  final String id;
  final String title;
  final String anchor;
  final String reflection;
  final String practice;
  final String prayer;
}
