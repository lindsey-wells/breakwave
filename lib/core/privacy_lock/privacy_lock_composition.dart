// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_composition.dart
// Purpose: IOS-G2C staged credential composition boundary.
// Notes:
// - Not wired into production UI yet.
// - Android resolves to the legacy compatibility adapter.
// - iOS must receive the real native gateway from IOS-G2D.
// - Missing iOS wiring fails closed as unsupported.
// ------------------------------------------------------------

import 'platform/legacy_android_privacy_credential_gateway.dart';
import 'platform/unsupported_privacy_credential_gateway.dart';
import 'privacy_credential_gateway.dart';

enum PrivacyCredentialPlatform {
  android,
  ios,
  unsupported,
}

class PrivacyLockComposition {
  const PrivacyLockComposition._();

  static PrivacyCredentialGateway credentialGatewayFor({
    required PrivacyCredentialPlatform platform,
    PrivacyCredentialGateway? androidGateway,
    PrivacyCredentialGateway? iosGateway,
  }) {
    switch (platform) {
      case PrivacyCredentialPlatform.android:
        return androidGateway ??
            LegacyAndroidPrivacyCredentialGateway();

      case PrivacyCredentialPlatform.ios:
        return iosGateway ??
            const UnsupportedPrivacyCredentialGateway(
              reason:
                  'IOS-G2D native privacy credential bridge is not installed.',
            );

      case PrivacyCredentialPlatform.unsupported:
        return const UnsupportedPrivacyCredentialGateway(
          reason: 'Privacy credentials are unsupported on this platform.',
        );
    }
  }
}
