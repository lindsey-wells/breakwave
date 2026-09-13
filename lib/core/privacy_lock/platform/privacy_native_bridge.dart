// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_native_bridge.dart
// Purpose: IOS-G2D bounded Flutter-to-native privacy auth channel.
// Notes: Raw PIN is sent only for configure/verify and is never logged.
// ------------------------------------------------------------

import 'package:flutter/services.dart';

import '../privacy_auth_result.dart';
import '../privacy_biometric_status.dart';

abstract interface class PrivacyNativeBridgeApi {
  Future<bool> isCredentialConfigured();

  Future<void> configurePin(String pin);

  Future<PrivacyAuthResult> verifyPin(String pin);

  Future<void> clearCredential();

  Future<PrivacyBiometricStatus> biometricStatus();

  Future<PrivacyAuthResult> authenticateBiometric();
}

class PrivacyNativeBridge implements PrivacyNativeBridgeApi {
  PrivacyNativeBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'breakwave/privacy_auth';

  final MethodChannel _channel;

  @override
  Future<bool> isCredentialConfigured() async {
    final String status = await _invokeString('credentialStatus');
    switch (status) {
      case 'configured':
        return true;
      case 'notConfigured':
        return false;
      default:
        return false;
    }
  }

  @override
  Future<void> configurePin(String pin) async {
    final String status = await _invokeString(
      'configurePin',
      <String, Object?>{'pin': pin},
    );
    if (status != 'success') {
      throw StateError('Native credential configuration failed.');
    }
  }

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    final String status = await _invokeString(
      'verifyPin',
      <String, Object?>{'pin': pin},
    );
    return _authResult(status);
  }

  @override
  Future<void> clearCredential() async {
    final String status = await _invokeString('clearCredential');
    if (status != 'success') {
      throw StateError('Native credential clear failed.');
    }
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async {
    final String status = await _invokeString('biometricStatus');
    switch (status) {
      case 'available':
        return PrivacyBiometricStatus.available;
      case 'notEnrolled':
        return PrivacyBiometricStatus.notEnrolled;
      case 'notAvailable':
        return PrivacyBiometricStatus.notAvailable;
      case 'lockedOut':
        return PrivacyBiometricStatus.lockedOut;
      default:
        return PrivacyBiometricStatus.unknown;
    }
  }

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    return _authResult(
      await _invokeString('authenticateBiometric'),
    );
  }

  Future<String> _invokeString(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      final String? value = await _channel.invokeMethod<String>(
        method,
        arguments,
      );
      return value ?? 'error';
    } on MissingPluginException {
      return 'error';
    } on PlatformException {
      return 'error';
    } catch (_) {
      return 'error';
    }
  }

  PrivacyAuthResult _authResult(String value) {
    switch (value) {
      case 'success':
        return PrivacyAuthResult.success;
      case 'cancelled':
        return PrivacyAuthResult.cancelled;
      case 'failed':
        return PrivacyAuthResult.failed;
      case 'cooldown':
        return PrivacyAuthResult.cooldown;
      case 'unavailable':
        return PrivacyAuthResult.unavailable;
      default:
        return PrivacyAuthResult.error;
    }
  }
}
