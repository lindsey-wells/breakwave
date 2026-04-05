// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact.dart
// Purpose: BW-21 support contact model.
// Notes: Stores one trusted support contact locally.
// ------------------------------------------------------------

class SupportContact {
  const SupportContact({
    required this.name,
    required this.contactLine,
  });

  final String name;
  final String contactLine;

  bool get isComplete =>
      name.trim().isNotEmpty && contactLine.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'contactLine': contactLine,
    };
  }

  factory SupportContact.fromMap(Map<String, dynamic> map) {
    return SupportContact(
      name: (map['name'] ?? '').toString(),
      contactLine: (map['contactLine'] ?? '').toString(),
    );
  }
}
