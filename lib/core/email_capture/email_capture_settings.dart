// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_capture_settings.dart
// Purpose: BW-42 email capture settings model.
// Notes: Stores optional email and separate consent flags.
// ------------------------------------------------------------

class EmailCaptureSettings {
  const EmailCaptureSettings({
    required this.emailAddress,
    required this.marketingOptIn,
    required this.researchOptIn,
  });

  final String emailAddress;
  final bool marketingOptIn;
  final bool researchOptIn;

  bool get hasAnyConsent => marketingOptIn || researchOptIn;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'emailAddress': emailAddress,
      'marketingOptIn': marketingOptIn,
      'researchOptIn': researchOptIn,
    };
  }

  factory EmailCaptureSettings.fromMap(Map<String, dynamic> map) {
    return EmailCaptureSettings(
      emailAddress: (map['emailAddress'] ?? '').toString(),
      marketingOptIn: map['marketingOptIn'] == true,
      researchOptIn: map['researchOptIn'] == true,
    );
  }

  EmailCaptureSettings copyWith({
    String? emailAddress,
    bool? marketingOptIn,
    bool? researchOptIn,
  }) {
    return EmailCaptureSettings(
      emailAddress: emailAddress ?? this.emailAddress,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      researchOptIn: researchOptIn ?? this.researchOptIn,
    );
  }

  static const EmailCaptureSettings defaults = EmailCaptureSettings(
    emailAddress: '',
    marketingOptIn: false,
    researchOptIn: false,
  );
}
