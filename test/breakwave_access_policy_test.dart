import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_access_policy.dart';
import 'package:breakwave/core/access/breakwave_feature.dart';

void main() {
  group('BreakWaveAccessPolicy', () {
    test(
      'every feature is classified exactly once',
      () {
        final List<BreakWaveFeature> free =
            BreakWaveAccessPolicy.featuresFor(
          BreakWaveAccessTier.free,
        );

        final List<BreakWaveFeature> plus =
            BreakWaveAccessPolicy.featuresFor(
          BreakWaveAccessTier.plus,
        );

        expect(
          <BreakWaveFeature>{...free, ...plus},
          BreakWaveFeature.values.toSet(),
        );

        expect(
          free.toSet().intersection(plus.toSet()),
          isEmpty,
        );
      },
    );

    test(
      'protected recovery core always remains free',
      () {
        for (final BreakWaveFeature feature
            in BreakWaveAccessPolicy
                .protectedFreeCore) {
          expect(
            BreakWaveAccessPolicy.minimumTierFor(
              feature,
            ),
            BreakWaveAccessTier.free,
            reason:
                '${feature.label} must not be paywalled.',
          );

          expect(
            BreakWaveAccessPolicy.isAvailable(
              feature,
              isPlusUnlocked: false,
            ),
            isTrue,
          );
        }
      },
    );

    test(
      'Rescue remains available without Plus',
      () {
        expect(
          BreakWaveAccessPolicy.isAvailable(
            BreakWaveFeature.rescueNow,
            isPlusUnlocked: false,
          ),
          isTrue,
        );
      },
    );

    test(
      'Plus tools require a verified entitlement',
      () {
        final List<BreakWaveFeature> plus =
            BreakWaveAccessPolicy.featuresFor(
          BreakWaveAccessTier.plus,
        );

        for (final BreakWaveFeature feature
            in plus) {
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
      },
    );
  });
}
