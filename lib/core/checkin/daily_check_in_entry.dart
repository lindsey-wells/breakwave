// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: daily_check_in_entry.dart
// Purpose: BW-19 daily check-in entry model.
// Notes: Stores one daily recovery check-in entry by date.
// ------------------------------------------------------------

class DailyCheckInEntry {
  const DailyCheckInEntry({
    required this.dateKey,
    required this.status,
    required this.savedAtIso,
  });

  final String dateKey;
  final String status;
  final String savedAtIso;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'status': status,
      'savedAtIso': savedAtIso,
    };
  }

  factory DailyCheckInEntry.fromMap(Map<String, dynamic> map) {
    return DailyCheckInEntry(
      dateKey: (map['dateKey'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      savedAtIso: (map['savedAtIso'] ?? '').toString(),
    );
  }
}
