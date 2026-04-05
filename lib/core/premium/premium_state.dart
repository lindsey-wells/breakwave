// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: premium_state.dart
// Purpose: BW-25 premium entitlement model.
// Notes: Local-only premium scaffold for BreakWave Plus.
// ------------------------------------------------------------

class PremiumState {
  const PremiumState({
    required this.isPlusUnlocked,
    required this.offerVariant,
  });

  final bool isPlusUnlocked;
  final String offerVariant;

  static const PremiumState defaults = PremiumState(
    isPlusUnlocked: false,
    offerVariant: 'annual_no_trial',
  );

  PremiumState copyWith({
    bool? isPlusUnlocked,
    String? offerVariant,
  }) {
    return PremiumState(
      isPlusUnlocked: isPlusUnlocked ?? this.isPlusUnlocked,
      offerVariant: offerVariant ?? this.offerVariant,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isPlusUnlocked': isPlusUnlocked,
      'offerVariant': offerVariant,
    };
  }

  factory PremiumState.fromMap(Map<String, dynamic> map) {
    return PremiumState(
      isPlusUnlocked: map['isPlusUnlocked'] == true,
      offerVariant: (map['offerVariant'] ?? 'annual_no_trial').toString(),
    );
  }
}
