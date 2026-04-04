import 'dart:convert';

class TriggersSelection {
  const TriggersSelection({
    required this.selectedTriggers,
    required this.selectedRiskyTimes,
  });

  final List<String> selectedTriggers;
  final List<String> selectedRiskyTimes;

  static const TriggersSelection empty = TriggersSelection(
    selectedTriggers: <String>[],
    selectedRiskyTimes: <String>[],
  );

  bool get hasAnySelection =>
      selectedTriggers.isNotEmpty || selectedRiskyTimes.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'selectedTriggers': selectedTriggers,
      'selectedRiskyTimes': selectedRiskyTimes,
    };
  }

  String toJsonString() => jsonEncode(toMap());

  factory TriggersSelection.fromMap(Map<String, dynamic> map) {
    List<String> normalizeList(dynamic raw) {
      final values = (raw as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final deduped = <String>[];
      for (final value in values) {
        if (!deduped.contains(value)) {
          deduped.add(value);
        }
      }
      return deduped;
    }

    return TriggersSelection(
      selectedTriggers: normalizeList(map['selectedTriggers']),
      selectedRiskyTimes: normalizeList(map['selectedRiskyTimes']),
    );
  }

  factory TriggersSelection.fromJsonString(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return TriggersSelection.fromMap(decoded);
  }
}
