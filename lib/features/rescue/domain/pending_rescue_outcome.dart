// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pending_rescue_outcome.dart
// Purpose: IOS-G2H data-minimized pending event created while Rescue-safe remains locked.
// ------------------------------------------------------------

class PendingRescueOutcome {
  const PendingRescueOutcome({required this.id, required this.entryType, required this.intensity, required this.genericOutcomeTag, required this.genericAction, required this.createdAtIso});

  static const Set<String> allowedEntryTypes = <String>{'Victory', 'Urge'};
  static const Set<String> allowedOutcomeTags = <String>{'lower_now', 'still_strong'};

  final String id;
  final String entryType;
  final int intensity;
  final String genericOutcomeTag;
  final String genericAction;
  final String createdAtIso;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'entryType': entryType,
    'intensity': intensity,
    'genericOutcomeTag': genericOutcomeTag,
    'genericAction': genericAction,
    'createdAtIso': createdAtIso,
  };

  factory PendingRescueOutcome.fromMap(Map<String, dynamic> map) {
    const Set<String> allowedKeys = <String>{'id','entryType','intensity','genericOutcomeTag','genericAction','createdAtIso'};
    final Set<String> unexpected = map.keys.where((String k) => !allowedKeys.contains(k)).toSet();
    if (unexpected.isNotEmpty) throw FormatException('Unexpected pending Rescue fields: $unexpected');
    final String id = (map['id'] ?? '').toString().trim();
    final String entryType = (map['entryType'] ?? '').toString().trim();
    final dynamic rawIntensity = map['intensity'];
    final int? intensity = rawIntensity is int ? rawIntensity : int.tryParse((rawIntensity ?? '').toString());
    final String outcome = (map['genericOutcomeTag'] ?? '').toString().trim();
    final String action = (map['genericAction'] ?? '').toString().trim();
    final String created = (map['createdAtIso'] ?? '').toString().trim();
    if (id.isEmpty || !allowedEntryTypes.contains(entryType) || intensity == null || intensity < 1 || intensity > 5 || !allowedOutcomeTags.contains(outcome) || DateTime.tryParse(created) == null) {
      throw const FormatException('Invalid pending Rescue outcome.');
    }
    return PendingRescueOutcome(id: id, entryType: entryType, intensity: intensity, genericOutcomeTag: outcome, genericAction: action, createdAtIso: created);
  }
}
