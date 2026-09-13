import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/platform/legacy_android_privacy_lock_configuration_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_settings.dart';

void main() {
  group('LegacyAndroidPrivacyLockConfigurationStore', () {
    late PrivacyLockSettings stored;
    late LegacyAndroidPrivacyLockConfigurationStore store;

    setUp(() {
      stored = const PrivacyLockSettings(
        mode: PrivacyLockMode.fullApp,
        passcode: '123456',
      );
      store = LegacyAndroidPrivacyLockConfigurationStore(
        loadSettings: () async => stored,
        saveSettings: (PrivacyLockSettings next) async {
          stored = next;
        },
        clearSettings: () async {
          stored = PrivacyLockSettings.defaults;
        },
      );
    });

    test('maps released full-app lock into v2 non-secret configuration', () async {
      final PrivacyLockConfiguration configuration = await store.load();

      expect(configuration.mode, PrivacyLockMode.fullApp);
      expect(configuration.credentialConfigured, isTrue);
      expect(configuration.biometricEnabled, isFalse);
      expect(configuration.toMap().containsKey('passcode'), isFalse);
    });

    test('maps released sensitive-sections lock without changing credential', () async {
      stored = const PrivacyLockSettings(
        mode: PrivacyLockMode.sensitiveSections,
        passcode: '654321',
      );

      final PrivacyLockConfiguration configuration = await store.load();

      expect(configuration.mode, PrivacyLockMode.sensitiveSections);
      expect(configuration.credentialConfigured, isTrue);
      expect(stored.passcode, '654321');
    });

    test('disabled or incomplete legacy lock remains disabled', () async {
      stored = const PrivacyLockSettings(
        mode: PrivacyLockMode.fullApp,
        passcode: '12345',
      );

      final PrivacyLockConfiguration configuration = await store.load();

      expect(configuration.mode, PrivacyLockMode.none);
      expect(configuration.credentialConfigured, isFalse);
      expect(configuration.isEnabled, isFalse);
    });

    test('saving mode metadata preserves an existing Android credential', () async {
      await store.save(
        const PrivacyLockConfiguration(
          mode: PrivacyLockMode.sensitiveSections,
          biometricEnabled: false,
          credentialConfigured: true,
        ),
      );

      expect(stored.mode, PrivacyLockMode.sensitiveSections);
      expect(stored.passcode, '123456');
    });

    test('cannot invent a legacy credential from non-secret metadata', () async {
      stored = PrivacyLockSettings.defaults;

      await expectLater(
        store.save(
          const PrivacyLockConfiguration(
            mode: PrivacyLockMode.fullApp,
            biometricEnabled: false,
            credentialConfigured: true,
          ),
        ),
        throwsStateError,
      );
      expect(stored.passcode, isEmpty);
    });

    test('clear delegates to released Android lock storage', () async {
      await store.clear();

      expect(stored.mode, PrivacyLockMode.none);
      expect(stored.passcode, isEmpty);
    });
  });
}
