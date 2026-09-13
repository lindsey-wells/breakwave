// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_lock_composition.dart
// Purpose: IOS-G2F runtime privacy-lock composition boundary.
// Notes:
// - Android keeps the released legacy credential/configuration compatibility adapters.
// - iOS resolves to the native-bound Keychain/auth gateway plus v2 non-secret metadata.
// ------------------------------------------------------------

import 'platform/ios_privacy_credential_gateway.dart';
import 'platform/legacy_android_privacy_credential_gateway.dart';
import 'platform/legacy_android_privacy_lock_configuration_store.dart';
import 'platform/unsupported_privacy_credential_gateway.dart';
import 'privacy_attempt_store.dart';
import 'privacy_credential_gateway.dart';
import 'privacy_lock_configuration_store.dart';
import 'privacy_session_controller.dart';

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
        return androidGateway ?? LegacyAndroidPrivacyCredentialGateway();

      case PrivacyCredentialPlatform.ios:
        return iosGateway ?? IosPrivacyCredentialGateway();

      case PrivacyCredentialPlatform.unsupported:
        return const UnsupportedPrivacyCredentialGateway(
          reason: 'Privacy credentials are unsupported on this platform.',
        );
    }
  }

  static PrivacyLockConfigurationStoreApi configurationStoreFor({
    required PrivacyCredentialPlatform platform,
  }) {
    switch (platform) {
      case PrivacyCredentialPlatform.android:
        return LegacyAndroidPrivacyLockConfigurationStore();
      case PrivacyCredentialPlatform.ios:
      case PrivacyCredentialPlatform.unsupported:
        return PrivacyLockConfigurationStore();
    }
  }

  static PrivacySessionController sessionControllerFor({
    required PrivacyCredentialPlatform platform,
    PrivacyCredentialGateway? credentialGateway,
    PrivacyLockConfigurationStoreApi? configurationStore,
    PrivacyAttemptStoreApi? attemptStore,
    PrivacyClock? now,
  }) {
    final PrivacyCredentialGateway resolvedGateway = credentialGateway ??
        credentialGatewayFor(platform: platform);
    final PrivacyLockConfigurationStoreApi resolvedConfigurationStore =
        configurationStore ?? configurationStoreFor(platform: platform);

    return PrivacySessionController(
      credentialGateway: resolvedGateway,
      configurationStore: resolvedConfigurationStore,
      attemptStore: attemptStore,
      now: now,
    );
  }
}
