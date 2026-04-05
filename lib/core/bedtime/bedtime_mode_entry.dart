// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_mode_entry.dart
// Purpose: BW-23 bedtime danger mode entry model.
// Notes: Stores one local bedtime state for the current date.
// ------------------------------------------------------------

class BedtimeModeEntry {
  const BedtimeModeEntry({
    required this.dateKey,
    required this.isRisky,
    required this.savedAtIso,
  });

  final String dateKey;
  final bool isRisky;
  final String savedAtIso;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'isRisky': isRisky,
      'savedAtIso': savedAtIso,
    };
  }

  factory BedtimeModeEntry.fromMap(Map<String, dynamic> map) {
    return BedtimeModeEntry(
      dateKey: (map['dateKey'] ?? '').toString(),
      isRisky: map['isRisky'] == true,
      savedAtIso: (map['savedAtIso'] ?? '').toString(),
    );
  }
}
