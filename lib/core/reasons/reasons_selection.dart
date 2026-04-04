import 'dart:convert';

class ReasonsSelection {
  const ReasonsSelection({
    required this.selectedReasons,
    required this.currentFocus,
  });

  final List<String> selectedReasons;
  final String? currentFocus;

  static const ReasonsSelection empty = ReasonsSelection(
    selectedReasons: <String>[],
    currentFocus: null,
  );

  bool get hasReasons => selectedReasons.isNotEmpty;

  ReasonsSelection copyWith({
    List<String>? selectedReasons,
    String? currentFocus,
    bool clearCurrentFocus = false,
  }) {
    return ReasonsSelection(
      selectedReasons: selectedReasons ?? this.selectedReasons,
      currentFocus: clearCurrentFocus ? null : (currentFocus ?? this.currentFocus),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedReasons': selectedReasons,
      'currentFocus': currentFocus,
    };
  }

  String toJsonString() => jsonEncode(toMap());

  factory ReasonsSelection.fromMap(Map<String, dynamic> map) {
    final rawReasons = (map['selectedReasons'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final selectedReasons = <String>[];
    for (final reason in rawReasons) {
      if (!selectedReasons.contains(reason)) {
        selectedReasons.add(reason);
      }
    }

    final rawFocus = map['currentFocus']?.toString().trim();
    final currentFocus = (rawFocus != null &&
            rawFocus.isNotEmpty &&
            selectedReasons.contains(rawFocus))
        ? rawFocus
        : (selectedReasons.isNotEmpty ? selectedReasons.first : null);

    return ReasonsSelection(
      selectedReasons: selectedReasons,
      currentFocus: currentFocus,
    );
  }

  factory ReasonsSelection.fromJsonString(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return ReasonsSelection.fromMap(decoded);
  }
}
