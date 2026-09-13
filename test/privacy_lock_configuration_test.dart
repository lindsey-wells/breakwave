import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/privacy_lock/privacy_lock_configuration.dart';
import 'package:breakwave/core/privacy_lock/privacy_lock_mode.dart';

void main() {
  group('PrivacyLockConfiguration', () {
    test('defaults contain no enabled privacy credential state', () {
      expect(
        PrivacyLockConfiguration.defaults.mode,
        PrivacyLockMode.none,
      );
      expect(
        PrivacyLockConfiguration.defaults.biometricEnabled,
        isFalse,
      );
      expect(
        PrivacyLockConfiguration.defaults.credentialConfigured,
        isFalse,
      );
      expect(
        PrivacyLockConfiguration.defaults.schemaVersion,
        PrivacyLockConfiguration.currentSchemaVersion,
      );
      expect(
        PrivacyLockConfiguration.defaults.isEnabled,
        isFalse,
      );
    });

    test('enabled requires both a lock mode and configured credential', () {
      for (final PrivacyLockMode mode in PrivacyLockMode.values) {
        final PrivacyLockConfiguration configuration =
            PrivacyLockConfiguration(
          mode: mode,
          biometricEnabled: false,
          credentialConfigured: true,
        );

        expect(
          configuration.isEnabled,
          mode != PrivacyLockMode.none,
        );
      }

      const PrivacyLockConfiguration missingCredential =
          PrivacyLockConfiguration(
        mode: PrivacyLockMode.fullApp,
        biometricEnabled: false,
        credentialConfigured: false,
      );

      expect(missingCredential.isEnabled, isFalse);
    });

    test('serializes only the approved non-secret metadata keys', () {
      const PrivacyLockConfiguration configuration =
          PrivacyLockConfiguration(
        mode: PrivacyLockMode.fullApp,
        biometricEnabled: true,
        credentialConfigured: true,
      );

      final Map<String, dynamic> encoded = configuration.toMap();

      expect(
        encoded.keys.toSet(),
        <String>{
          'mode',
          'biometricEnabled',
          'credentialConfigured',
          'schemaVersion',
        },
      );
      expect(encoded['mode'], 'fullApp');
      expect(encoded['biometricEnabled'], isTrue);
      expect(encoded['credentialConfigured'], isTrue);
      expect(
        encoded['schemaVersion'],
        PrivacyLockConfiguration.currentSchemaVersion,
      );
    });

    test('round-trips every lock mode without secret material', () {
      for (final PrivacyLockMode mode in PrivacyLockMode.values) {
        final PrivacyLockConfiguration source =
            PrivacyLockConfiguration(
          mode: mode,
          biometricEnabled: true,
          credentialConfigured: true,
        );

        final PrivacyLockConfiguration decoded =
            PrivacyLockConfiguration.fromMap(source.toMap());

        expect(decoded.mode, mode);
        expect(decoded.biometricEnabled, isTrue);
        expect(decoded.credentialConfigured, isTrue);
        expect(
          decoded.schemaVersion,
          PrivacyLockConfiguration.currentSchemaVersion,
        );
      }
    });

    test('biometrics cannot remain enabled without a credential', () {
      final PrivacyLockConfiguration decoded =
          PrivacyLockConfiguration.fromMap(
        <String, dynamic>{
          'mode': 'fullApp',
          'biometricEnabled': true,
          'credentialConfigured': false,
          'schemaVersion': 2,
        },
      );

      expect(decoded.credentialConfigured, isFalse);
      expect(decoded.biometricEnabled, isFalse);

      const PrivacyLockConfiguration source =
          PrivacyLockConfiguration(
        mode: PrivacyLockMode.fullApp,
        biometricEnabled: true,
        credentialConfigured: true,
      );

      final PrivacyLockConfiguration cleared =
          source.copyWith(credentialConfigured: false);

      expect(cleared.credentialConfigured, isFalse);
      expect(cleared.biometricEnabled, isFalse);
    });

    test('missing schema version resolves to the current schema', () {
      final PrivacyLockConfiguration decoded =
          PrivacyLockConfiguration.fromMap(
        <String, dynamic>{
          'mode': 'sensitiveSections',
          'biometricEnabled': false,
          'credentialConfigured': true,
        },
      );

      expect(
        decoded.schemaVersion,
        PrivacyLockConfiguration.currentSchemaVersion,
      );
    });

    test('unknown configured lock mode fails closed to full-app lock', () {
      final PrivacyLockConfiguration decoded =
          PrivacyLockConfiguration.fromMap(
        <String, dynamic>{
          'mode': 'not-a-real-mode',
          'biometricEnabled': false,
          'credentialConfigured': true,
          'schemaVersion': 2,
        },
      );

      expect(decoded.mode, PrivacyLockMode.fullApp);
      expect(decoded.isEnabled, isTrue);
    });

    test('unknown unconfigured lock mode resolves to no lock', () {
      final PrivacyLockConfiguration decoded =
          PrivacyLockConfiguration.fromMap(
        <String, dynamic>{
          'mode': 'not-a-real-mode',
          'biometricEnabled': false,
          'credentialConfigured': false,
          'schemaVersion': 2,
        },
      );

      expect(decoded.mode, PrivacyLockMode.none);
      expect(decoded.isEnabled, isFalse);
    });
  });
}
