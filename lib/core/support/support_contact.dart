// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact.dart
// Purpose: BW-21/BW-37 support contact model.
// Notes: Stores one trusted support contact with direct phone/email actions.
// ------------------------------------------------------------

class SupportContact {
  const SupportContact({
    required this.name,
    required this.phoneNumber,
    required this.emailAddress,
  });

  final String name;
  final String phoneNumber;
  final String emailAddress;

  // Legacy compatibility for earlier passes/verifiers.
  String get contactLine => phoneNumber;

  bool get hasPhone => phoneNumber.trim().isNotEmpty;
  bool get hasEmail => emailAddress.trim().isNotEmpty;

  bool get isComplete =>
      name.trim().isNotEmpty && (hasPhone || hasEmail);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      // Keep legacy key populated for older saved data compatibility.
      'contactLine': phoneNumber,
    };
  }

  factory SupportContact.fromMap(Map<String, dynamic> map) {
    final String legacyContactLine = (map['contactLine'] ?? '').toString();

    return SupportContact(
      name: (map['name'] ?? '').toString(),
      phoneNumber: (map['phoneNumber'] ?? legacyContactLine).toString(),
      emailAddress: (map['emailAddress'] ?? '').toString(),
    );
  }
}
