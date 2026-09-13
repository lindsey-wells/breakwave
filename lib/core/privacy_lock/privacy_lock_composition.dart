// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_composition.dart
// Purpose: IOS-G2D staged credential composition boundary.
// Notes:
// - Not wired into production UI yet.
// - Android keeps the released legacy compatibility adapter.
// - iOS now resolves to the native-bound Keychain/auth gateway.
// ------------------------------------------------------------

import 'platform/ios_privacy_credential_gateway.dart';
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
        return iosGateway ?? IosPrivacyCredentialGateway();

      case PrivacyCredentialPlatform.unsupported:
        return const UnsupportedPrivacyCredentialGateway(
          reason: 'Privacy credentials are unsupported on this platform.',
        );
    }
  }
}
