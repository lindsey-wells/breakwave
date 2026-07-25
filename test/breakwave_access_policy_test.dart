import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_access_class.dart';
import 'package:breakwave/core/access/breakwave_access_policy.dart';
import 'package:breakwave/core/access/breakwave_feature.dart';

void main() {
  group('BreakWaveAccessPolicy classification coverage', () {
    test('every feature has exactly one classification', () {
      final Map<BreakWaveFeature, BreakWaveAccessClass>
          classifications =
          BreakWaveAccessPolicy.classifications;

      expect(
        classifications.length,
        BreakWaveFeature.values.length,
      );

      expect(
        classifications.keys.toSet(),
        BreakWaveFeature.values.toSet(),
      );
    });

    test('only Plus candidates require Plus', () {
      for (final BreakWaveFeature feature
          in BreakWaveFeature.values) {
        final BreakWaveAccessClass accessClass =
            BreakWaveAccessPolicy.accessClassFor(feature);

        expect(
          BreakWaveAccessPolicy.minimumTierFor(feature),
          accessClass == BreakWaveAccessClass.plusCandidate
              ? BreakWaveAccessTier.plus
              : BreakWaveAccessTier.free,
          reason:
              '${feature.label} has an inconsistent tier.',
        );
      }
    });
  });

  group('BreakWave never-paywalled guardrails', () {
    const Set<BreakWaveFeature> requiredNeverPaywalled =
        <BreakWaveFeature>{
      BreakWaveFeature.rescueNow,
      BreakWaveFeature.rescueActions,
      BreakWaveFeature.onboarding,
      BreakWaveFeature.basicLogging,
      BreakWaveFeature.logHistory,
      BreakWaveFeature.editAndDeleteLogs,
      BreakWaveFeature.privacySettings,
      BreakWaveFeature.privacyLock,
      BreakWaveFeature.privacyPolicy,
      BreakWaveFeature.emergencyHelp,
      BreakWaveFeature.humanSupportActions,
      BreakWaveFeature.trustedContactTools,
      BreakWaveFeature.recoveryMode,
      BreakWaveFeature.basicSecularSupport,
      BreakWaveFeature.basicChristianSupport,
      BreakWaveFeature.personalWhy,
      BreakWaveFeature.personalDataControl,
    };

    test('required protections are explicitly never paywalled', () {
      expect(
        BreakWaveAccessPolicy.neverPaywalled,
        containsAll(requiredNeverPaywalled),
      );

      for (final BreakWaveFeature feature
          in requiredNeverPaywalled) {
        expect(
          BreakWaveAccessPolicy.accessClassFor(feature),
          BreakWaveAccessClass.neverPaywalled,
          reason:
              '${feature.label} must be explicitly never paywalled.',
        );
      }
    });

    test('never-paywalled features ignore entitlement state', () {
      for (final BreakWaveFeature feature
          in BreakWaveAccessPolicy.neverPaywalled) {
        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: false,
          ),
          isTrue,
          reason:
              '${feature.label} failed without Plus.',
        );

        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: true,
          ),
          isTrue,
          reason:
              '${feature.label} changed with Plus.',
        );
      }
    });

    test('Rescue screen and Rescue actions are separately protected', () {
      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.rescueNow,
        ),
        BreakWaveAccessClass.neverPaywalled,
      );

      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.rescueActions,
        ),
        BreakWaveAccessClass.neverPaywalled,
      );
    });
  });

  group('BreakWave protected Free experience', () {
    test('protected Free core remains available without Plus', () {
      for (final BreakWaveFeature feature
          in BreakWaveAccessPolicy.protectedFreeCore) {
        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: false,
          ),
          isTrue,
          reason:
              '${feature.label} must remain in the Free core.',
        );
      }
    });

    test('Free support remains available without Plus', () {
      for (final BreakWaveFeature feature
          in BreakWaveAccessPolicy.freeSupport) {
        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: false,
          ),
          isTrue,
          reason:
              '${feature.label} must remain Free support.',
        );
      }
    });
  });

  group('Free foundations versus deeper Plus features', () {
    test('basic snapshot is Free and advanced insights are Plus', () {
      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.basicRecoverySnapshot,
        ),
        BreakWaveAccessClass.freeSupport,
      );

      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.advancedRecoveryInsights,
        ),
        BreakWaveAccessClass.plusCandidate,
      );
    });

    test('starter plan is Free and saved deeper plan is Plus', () {
      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.starterRecoveryPlan,
        ),
        BreakWaveAccessClass.protectedFreeCore,
      );

      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.savedPersonalRecoveryPlan,
        ),
        BreakWaveAccessClass.plusCandidate,
      );
    });

    test('personal-data control is Free and reports are Plus', () {
      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.personalDataControl,
        ),
        BreakWaveAccessClass.neverPaywalled,
      );

      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.enhancedRecoveryReports,
        ),
        BreakWaveAccessClass.plusCandidate,
      );
    });

    test('basic Christian support is Free and depth is Plus', () {
      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.basicChristianSupport,
        ),
        BreakWaveAccessClass.neverPaywalled,
      );

      expect(
        BreakWaveAccessPolicy.accessClassFor(
          BreakWaveFeature.extendedChristianDepth,
        ),
        BreakWaveAccessClass.plusCandidate,
      );
    });
  });

  group('BreakWave Plus candidates', () {
    test('approved Plus candidates require entitlement', () {
      const Set<BreakWaveFeature> expectedPlusCandidates =
          <BreakWaveFeature>{
        BreakWaveFeature.advancedRecoveryInsights,
        BreakWaveFeature.savedPersonalRecoveryPlan,
        BreakWaveFeature.guidedRoutines,
        BreakWaveFeature.christianJourneys,
        BreakWaveFeature.enhancedRecoveryReports,
        BreakWaveFeature.extendedChristianDepth,
      };

      expect(
        BreakWaveAccessPolicy.plusCandidates,
        expectedPlusCandidates,
      );

      for (final BreakWaveFeature feature
          in expectedPlusCandidates) {
        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: false,
          ),
          isFalse,
        );

        expect(
          BreakWaveAccessPolicy.isAvailable(
            feature,
            isPlusUnlocked: true,
          ),
          isTrue,
        );
      }
    });
  });
}
