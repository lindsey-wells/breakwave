import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_configuration_store.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrivacyLockConfigurationStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('missing configuration loads defaults', () async {
      final PrivacyLockConfiguration loaded =
          await PrivacyLockConfigurationStore().load();

      expect(loaded.isEnabled, isFalse);
      expect(loaded.mode, PrivacyLockMode.none);
    });

    test('configuration survives a new store instance', () async {
      const PrivacyLockConfiguration source = PrivacyLockConfiguration(
        mode: PrivacyLockMode.fullApp,
        biometricEnabled: true,
        credentialConfigured: true,
      );

      await PrivacyLockConfigurationStore().save(source);
      final PrivacyLockConfiguration loaded =
          await PrivacyLockConfigurationStore().load();

      expect(loaded.mode, PrivacyLockMode.fullApp);
      expect(loaded.biometricEnabled, isTrue);
      expect(loaded.credentialConfigured, isTrue);
    });

    test('configuration payload contains only approved metadata', () async {
      const PrivacyLockConfiguration source = PrivacyLockConfiguration(
        mode: PrivacyLockMode.sensitiveSections,
        biometricEnabled: false,
        credentialConfigured: true,
      );

      await PrivacyLockConfigurationStore().save(source);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String raw =
          prefs.getString(PrivacyLockConfigurationStore.storageKey)!;
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;

      expect(
        decoded.keys.toSet(),
        <String>{
          'mode',
          'biometricEnabled',
          'credentialConfigured',
          'schemaVersion',
        },
      );
      expect(raw.toLowerCase(), isNot(contains('passcode')));
      expect(raw.toLowerCase(), isNot(contains('verifier')));
      expect(raw.toLowerCase(), isNot(contains('salt')));
    });


    test('incomplete existing configuration also fails closed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrivacyLockConfigurationStore.storageKey: '{}',
      });

      final PrivacyLockConfiguration loaded =
          await PrivacyLockConfigurationStore().load();

      expect(loaded.mode, PrivacyLockMode.fullApp);
      expect(loaded.credentialConfigured, isTrue);
      expect(loaded.isEnabled, isTrue);
    });
    test('malformed existing configuration fails closed', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrivacyLockConfigurationStore.storageKey: '{not-json',
      });

      final PrivacyLockConfiguration loaded =
          await PrivacyLockConfigurationStore().load();

      expect(loaded.mode, PrivacyLockMode.fullApp);
      expect(loaded.credentialConfigured, isTrue);
      expect(loaded.isEnabled, isTrue);
    });
  });
}
