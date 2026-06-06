// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry.dart
// Purpose: BW-63 CBT-informed log entry model.
// Notes: Backward-compatible with older BW-07/BW-10 saved entries.
// ------------------------------------------------------------

class LogEntry {
  final String id;
  final String entryType;
  final int intensity;
  final List<String> triggers;
  final String thought;
  final String actionTaken;
  final String consequence;
  final String betterPlan;
  final String replacementAction;
  final String notes;
  final String createdAtIso;

  const LogEntry({
    required this.id,
    required this.entryType,
    required this.intensity,
    required this.triggers,
    this.thought = '',
    this.actionTaken = '',
    this.consequence = '',
    this.betterPlan = '',
    this.replacementAction = '',
    required this.notes,
    required this.createdAtIso,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'entryType': entryType,
      'intensity': intensity,
      'triggers': triggers,
      'thought': thought,
      'actionTaken': actionTaken,
      'consequence': consequence,
      'betterPlan': betterPlan,
      'replacementAction': replacementAction,
      'notes': notes,
      'createdAtIso': createdAtIso,
    };
  }

  static String _stringValue(Map<String, dynamic> map, String key) {
    return (map[key] ?? '').toString();
  }

  static int _intValue(Map<String, dynamic> map, String key, int fallback) {
    final dynamic value = map[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }

    return fallback;
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawTriggers =
        (map['triggers'] as List<dynamic>? ?? <dynamic>[]);

    return LogEntry(
      id: _stringValue(map, 'id'),
      entryType: _stringValue(map, 'entryType').isEmpty
          ? 'Urge'
          : _stringValue(map, 'entryType'),
      intensity: _intValue(map, 'intensity', 3),
      triggers: rawTriggers.map((dynamic item) => item.toString()).toList(),
      thought: _stringValue(map, 'thought'),
      actionTaken: _stringValue(map, 'actionTaken'),
      consequence: _stringValue(map, 'consequence'),
      betterPlan: _stringValue(map, 'betterPlan'),
      replacementAction: _stringValue(map, 'replacementAction'),
      notes: _stringValue(map, 'notes'),
      createdAtIso: _stringValue(map, 'createdAtIso'),
    );
  }
}
