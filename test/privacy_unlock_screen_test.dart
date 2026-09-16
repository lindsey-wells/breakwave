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
  _Gateway(
    this.pinResult, {
    this.biometricResult = PrivacyAuthResult.unavailable,
    this.status = PrivacyBiometricStatus.notAvailable,
  });

  PrivacyAuthResult pinResult;
  PrivacyAuthResult biometricResult;
  PrivacyBiometricStatus status;
  String? lastPin;
  int biometricCalls = 0;

  @override
  Future<PrivacyAuthResult> authenticateBiometric() async {
    biometricCalls += 1;
    return biometricResult;
  }

  @override
  Future<PrivacyBiometricStatus> biometricStatus() async => status;

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
  _ConfigStore({this.biometricEnabled = false});

  final bool biometricEnabled;

  @override
  Future<void> clear() async {}

  @override
  Future<PrivacyLockConfiguration> load() async => PrivacyLockConfiguration(
        mode: PrivacyLockMode.fullApp,
        biometricEnabled: biometricEnabled,
        credentialConfigured: true,
      );

  @override
  Future<void> save(PrivacyLockConfiguration configuration) async {}
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

Future<PrivacySessionController> _controller(
  _Gateway gateway, {
  bool biometricEnabled = false,
}) async {
  final PrivacySessionController controller = PrivacySessionController(
    credentialGateway: gateway,
    configurationStore: _ConfigStore(biometricEnabled: biometricEnabled),
    attemptStore: _AttemptStore(),
    now: () => DateTime.utc(2026, 9, 15, 20),
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

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () => unlocked += 1,
      onCancelled: () {},
    ))));
    await tester.pumpAndSettle();

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

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () {},
      onCancelled: () {},
    ))));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '654321');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(controller.attemptState.failedAttemptCount, 1);
    expect(find.text('Wrong PIN. 9 tries left before cooldown.'), findsOneWidget);
  });

  testWidgets('cancel never authenticates or exposes stored credential material',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(PrivacyAuthResult.success);
    final PrivacySessionController controller = await _controller(gateway);
    int cancellations = 0;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () {},
      onCancelled: () => cancellations += 1,
    ))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancellations, 1);
    expect(gateway.lastPin, isNull);
  });

  testWidgets('available enabled biometrics unlock without removing PIN fallback',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(
      PrivacyAuthResult.failed,
      biometricResult: PrivacyAuthResult.success,
      status: PrivacyBiometricStatus.available,
    );
    final PrivacySessionController controller = await _controller(
      gateway,
      biometricEnabled: true,
    );
    int unlocked = 0;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () => unlocked += 1,
      onCancelled: () {},
    ))));
    await tester.pumpAndSettle();

    expect(find.text('Use Face ID / Touch ID'), findsOneWidget);
    expect(find.text('6-digit PIN'), findsOneWidget);

    await tester.tap(find.text('Use Face ID / Touch ID'));
    await tester.pumpAndSettle();

    expect(gateway.biometricCalls, 1);
    expect(unlocked, 1);
    expect(gateway.lastPin, isNull);
    expect(controller.attemptState.failedAttemptCount, 0);
  });

  testWidgets('unavailable biometrics remain hidden and PIN stays available',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(
      PrivacyAuthResult.success,
      status: PrivacyBiometricStatus.notEnrolled,
    );
    final PrivacySessionController controller = await _controller(
      gateway,
      biometricEnabled: true,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () {},
      onCancelled: () {},
    ))));
    await tester.pumpAndSettle();

    expect(find.text('Use Face ID / Touch ID'), findsNothing);
    expect(find.text('6-digit PIN'), findsOneWidget);
  });

  testWidgets('biometric failure does not increment PIN failure counter',
      (WidgetTester tester) async {
    final _Gateway gateway = _Gateway(
      PrivacyAuthResult.failed,
      biometricResult: PrivacyAuthResult.failed,
      status: PrivacyBiometricStatus.available,
    );
    final PrivacySessionController controller = await _controller(
      gateway,
      biometricEnabled: true,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyUnlockScreen(
      controller: controller,
      onUnlocked: () {},
      onCancelled: () {},
    ))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use Face ID / Touch ID'));
    await tester.pumpAndSettle();

    expect(controller.attemptState.failedAttemptCount, 0);
    expect(
      find.text('Biometric unlock did not match. Try again or use your PIN.'),
      findsOneWidget,
    );
    expect(find.text('6-digit PIN'), findsOneWidget);
  });
}
