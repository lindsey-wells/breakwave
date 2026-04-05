// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_settings.dart
// Purpose: BW-24 privacy settings model.
// Notes: Stores local privacy controls for discreet notifications and reduced UI detail.
// ------------------------------------------------------------

class PrivacySettings {
  const PrivacySettings({
    required this.discreetNotifications,
    required this.hideHomeInsights,
    required this.hideLatestLoggedMoment,
    required this.preferRescueAsSafePath,
  });

  final bool discreetNotifications;
  final bool hideHomeInsights;
  final bool hideLatestLoggedMoment;
  final bool preferRescueAsSafePath;

  static const PrivacySettings defaults = PrivacySettings(
    discreetNotifications: false,
    hideHomeInsights: false,
    hideLatestLoggedMoment: false,
    preferRescueAsSafePath: true,
  );

  PrivacySettings copyWith({
    bool? discreetNotifications,
    bool? hideHomeInsights,
    bool? hideLatestLoggedMoment,
    bool? preferRescueAsSafePath,
  }) {
    return PrivacySettings(
      discreetNotifications:
          discreetNotifications ?? this.discreetNotifications,
      hideHomeInsights: hideHomeInsights ?? this.hideHomeInsights,
      hideLatestLoggedMoment:
          hideLatestLoggedMoment ?? this.hideLatestLoggedMoment,
      preferRescueAsSafePath:
          preferRescueAsSafePath ?? this.preferRescueAsSafePath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'discreetNotifications': discreetNotifications,
      'hideHomeInsights': hideHomeInsights,
      'hideLatestLoggedMoment': hideLatestLoggedMoment,
      'preferRescueAsSafePath': preferRescueAsSafePath,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      discreetNotifications: map['discreetNotifications'] == true,
      hideHomeInsights: map['hideHomeInsights'] == true,
      hideLatestLoggedMoment: map['hideLatestLoggedMoment'] == true,
      preferRescueAsSafePath: map['preferRescueAsSafePath'] != false,
    );
  }
}
