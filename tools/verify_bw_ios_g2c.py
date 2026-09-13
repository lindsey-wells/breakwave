#!/usr/bin/env python3
from pathlib import Path
import sys

failed = False

paths = {
    'auth_result': Path('lib/core/privacy_lock/privacy_auth_result.dart'),
    'biometric_status': Path('lib/core/privacy_lock/privacy_biometric_status.dart'),
    'gateway': Path('lib/core/privacy_lock/privacy_credential_gateway.dart'),
    'composition': Path('lib/core/privacy_lock/privacy_lock_composition.dart'),
    'legacy_adapter': Path(
        'lib/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart'
    ),
    'unsupported_adapter': Path(
        'lib/core/privacy_lock/platform/unsupported_privacy_credential_gateway.dart'
    ),
    'gateway_test': Path('test/privacy_credential_gateway_test.dart'),
    'composition_test': Path('test/privacy_lock_composition_test.dart'),
    'legacy_settings': Path('lib/core/privacy_lock/privacy_lock_settings.dart'),
    'legacy_store': Path('lib/core/privacy_lock/privacy_lock_store.dart'),
    'g2b_policy': Path('lib/core/privacy_lock/privacy_route_policy.dart'),
    'g2a_plan': Path('docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md'),
}

for name, path in paths.items():
    if not path.is_file():
        print(f'FAIL missing {name}: {path}')
        failed = True

if failed:
    sys.exit(1)

texts = {name: path.read_text(encoding='utf-8') for name, path in paths.items()}

def require(name: str, needle: str) -> None:
    global failed
    if needle not in texts[name]:
        print(f'FAIL {name} missing: {needle}')
        failed = True

for value in ['success', 'cancelled', 'failed', 'cooldown', 'unavailable', 'error']:
    require('auth_result', value)

for value in ['available', 'notEnrolled', 'notAvailable', 'lockedOut', 'unknown']:
    require('biometric_status', value)

for signature in [
    'Future<bool> isCredentialConfigured();',
    'Future<void> configurePin(String pin);',
    'Future<PrivacyAuthResult> verifyPin(String pin);',
    'Future<void> clearCredential();',
    'Future<PrivacyBiometricStatus> biometricStatus();',
    'Future<PrivacyAuthResult> authenticateBiometric();',
]:
    require('gateway', signature)

for forbidden in [
    'PrivacyLockSettings', 'PrivacyLockStore', 'SharedPreferences',
    'MethodChannel', 'passcode', 'Keychain', 'LocalAuthentication',
]:
    if forbidden in texts['gateway']:
        print('FAIL platform-neutral gateway leaks implementation detail: ' + forbidden)
        failed = True

for needle in [
    'LegacyAndroidPrivacyCredentialGateway',
    'PrivacyLockStore.load',
    'PrivacyLockStore.save',
    'settings.passcode.length == 6',
    'settings.passcode == pin',
    'settings.copyWith(passcode: pin)',
    "settings.copyWith(passcode: '')",
    'PrivacyBiometricStatus.notAvailable',
    'PrivacyAuthResult.unavailable',
    'TEMPORARY migration boundary',
]:
    require('legacy_adapter', needle)

for forbidden in ['MethodChannel', 'Keychain', 'LocalAuthentication']:
    if forbidden in texts['legacy_adapter']:
        print('FAIL legacy Android adapter contains future iOS/native detail: ' + forbidden)
        failed = True

for needle in [
    'PrivacyCredentialPlatform.android',
    'PrivacyCredentialPlatform.ios',
    'PrivacyCredentialPlatform.unsupported',
    'LegacyAndroidPrivacyCredentialGateway()',
    'IOS-G2D native privacy credential bridge is not installed.',
    'UnsupportedPrivacyCredentialGateway',
]:
    require('composition', needle)

for forbidden in ['dart:io', 'Platform.isAndroid', 'Platform.isIOS', 'defaultTargetPlatform']:
    if forbidden in texts['composition']:
        print('FAIL G2C composition is already wired to runtime platform: ' + forbidden)
        failed = True

for needle in [
    'fails closed without inventing a credential',
    'configurePin preserves the existing lock mode',
    'clearCredential preserves mode but removes legacy PIN',
    'legacy Android adapter does not claim biometric support',
    'without echoing the PIN',
]:
    require('gateway_test', needle)

for needle in [
    'Android defaults to the legacy compatibility adapter',
    'iOS fails closed until IOS-G2D injects the native gateway',
    'iOS returns the injected native-bound gateway unchanged',
    'unsupported platforms always fail closed',
]:
    require('composition_test', needle)

for needle in ['final String passcode;', "'passcode': passcode"]:
    require('legacy_settings', needle)

for needle in [
    "static const String storageKey = 'bw_privacy_lock_v1';",
    'SharedPreferences',
    'PrivacyLockSettings.fromMap',
]:
    require('legacy_store', needle)

require('g2b_policy', 'class PrivacyRoutePolicy')
require(
    'g2a_plan',
    'IOS-G2C — Credential Interfaces + Android Compatibility Adapter',
)

if failed:
    sys.exit(1)

print(
    'PASS: IOS-G2C adds a bounded platform-neutral credential gateway, '
    'preserves released Android behavior behind a temporary compatibility '
    'adapter, keeps biometrics unavailable on that adapter, and leaves iOS '
    'fail-closed until IOS-G2D injects the native credential bridge.'
)
