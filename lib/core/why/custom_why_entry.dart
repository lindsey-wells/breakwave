// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_entry.dart
// Purpose: BW-39 custom why model.
// Notes: Stores one short why statement and one optional image path.
// ------------------------------------------------------------

class CustomWhyEntry {
  const CustomWhyEntry({
    required this.whyText,
    required this.imagePath,
  });

  final String whyText;
  final String imagePath;

  bool get hasText => whyText.trim().isNotEmpty;
  bool get hasImage => imagePath.trim().isNotEmpty;
  bool get hasAnyContent => hasText || hasImage;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'whyText': whyText,
      'imagePath': imagePath,
    };
  }

  factory CustomWhyEntry.fromMap(Map<String, dynamic> map) {
    return CustomWhyEntry(
      whyText: (map['whyText'] ?? '').toString(),
      imagePath: (map['imagePath'] ?? '').toString(),
    );
  }

  static const CustomWhyEntry empty = CustomWhyEntry(
    whyText: '',
    imagePath: '',
  );
}
