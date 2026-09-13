import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/privacy_attempt_state.dart';
import 'package:breakwave/core/privacy_lock/privacy_attempt_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_auth_result.dart';
import 'package:breakwave/core/privacy_lock/privacy_biometric_status.dart';
import 'package:breakwave/core/privacy_lock/privacy_credential_gateway.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_session_controller.dart';
import 'package:breakwave/features/privacy_lock/presentation/privacy_unlock_screen.dart';

class _Gateway implements PrivacyCredentialGateway {
  _Gateway(this.pinResult);

  PrivacyAuthResult pinResult;
  String? lastPin;

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async =>
      PrivacyAuthResult.unavailable;

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async =>
      PrivacyBiometricStatus.notAvailable;

  @override
  Future<void> clearCredential() async {}

  @override
  Future<void> configurePin(String pin) async {}

  @override
  Future<bool> isCredentialConfigured() async => true;

  @override
  Future<PrivacyAuthResult> verifyPin(String pin) async {
    lastPin = pin;
    return pinResult;
  }
}

class _ConfigStore implements PrivacyLockConfigurationStoreApi {
  PrivacyLockConfiguration configuration = const PrivacyLockConfiguration(
    mode: PrivacyLockMode.fullApp,
    biometricEnabled: false,
    credentialConfigured: true,
  );

  @override
  Future<void> clear() async {}

  @override
  Future<PrivacyLockConfiguration> load() async => configuration;

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {
    this.configuration = configuration;
  }
}

class _AttemptStore implements PrivacyAttemptStoreApi {
  PrivacyAttemptState state = PrivacyAttemptState.empty;

  @override
  Future<void> clear() async {
    state = PrivacyAttemptState.empty;
  }

  @override
  Future<PrivacyAttemptState> load() async => state;

  @override
  Future<void> save(PrivacyAttemptState state) async {
    this.state = state;
  }
}

Future<PrivacySessionController> _controller(_Gateway gateway) async {
  final PrivacySessionController controller = PrivacySessionController(
    credentialGateway: gateway,
    configurationStore: _ConfigStore(),
    attemptStore: _AttemptStore(),
    now: () => DateTime.utc(2026, 9, 13, 16),
  );
  await controller.initialize();
  return controller;
}

void main() {
  testWidgets('unlock presentation delegates PIN verification to controller',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(PrivacyAuthResult.success);
    final PrivacySessionController controller = await _controller(gateway);
    int unlocked = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyUnlockScreen(
            controller: controller,
            onUnlocked: () => unlocked += 1,
            onCancelled: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(gateway.lastPin, '123456');
    expect(unlocked, 1);
    expect(controller.attemptState.failedAttemptCount, 0);
  });

  testWidgets('wrong PIN copy comes from persistent controller attempt state',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(PrivacyAuthResult.failed);
    final PrivacySessionController controller = await _controller(gateway);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyUnlockScreen(
            controller: controller,
            onUnlocked: () {},
            onCancelled: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '654321');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(controller.attemptState.failedAttemptCount, 1);
    expect(
      find.text('Wrong PIN. 9 tries left before cooldown.'),
      findsOneWidget,
    );
  });

  testWidgets('cancel never authenticates or exposes stored credential material',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(PrivacyAuthResult.success);
    final PrivacySessionController controller = await _controller(gateway);
    int cancellations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrivacyUnlockScreen(
            controller: controller,
            onUnlocked: () {},
            onCancelled: () => cancellations += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancellations, 1);
    expect(gateway.lastPin, isNull);
  });
}
