// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry.dart
// Purpose: Log entry model for BreakWave persistence.
// Notes: BW-07 persistence foundation.
// ------------------------------------------------------------

class LogEntry {
  final String id;
  final String entryType;
  final int intensity;
  final List<String> triggers;
  final String notes;
  final String createdAtIso;

  const LogEntry({
    required this.id,
    required this.entryType,
    required this.intensity,
    required this.triggers,
    required this.notes,
    required this.createdAtIso,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'entryType': entryType,
      'intensity': intensity,
      'triggers': triggers,
      'notes': notes,
      'createdAtIso': createdAtIso,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawTriggers = (map['triggers'] as List<dynamic>? ?? <dynamic>[]);

    return LogEntry(
      id: map['id'] as String? ?? '',
      entryType: map['entryType'] as String? ?? 'Urge',
      intensity: map['intensity'] as int? ?? 3,
      triggers: rawTriggers.map((dynamic item) => item.toString()).toList(),
      notes: map['notes'] as String? ?? '',
      createdAtIso: map['createdAtIso'] as String? ?? '',
    );
  }
}
