import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/core/access/breakwave_access_class.dart';
import 'package:breakwave/core/access/breakwave_access_decision.dart';
import 'package:breakwave/core/access/breakwave_access_service.dart';
import 'package:breakwave/core/access/breakwave_entitlement_source.dart';
import 'package:breakwave/core/access/breakwave_feature.dart';

void main() {
  group('BreakWaveAccessService Free safety', () {
    test(
      'never-paywalled access bypasses entitlement storage',
      () async {
        final _FakeEntitlementSource source =
            _FakeEntitlementSource(
          isPlusUnlocked: false,
          error: StateError('storage unavailable'),
        );

        addTearDown(source.dispose);

        final BreakWaveAccessService service =
            BreakWaveAccessService(
          entitlementSource: source,
        );

        final BreakWaveAccessDecision decision =
            await service.decisionFor(
          BreakWaveFeature.rescueNow,
        );

        expect(decision.isAvailable, isTrue);
        expect(decision.isLocked, isFalse);
        expect(
          decision.accessClass,
          BreakWaveAccessClass.neverPaywalled,
        );
        expect(
          decision.minimumTier,
          BreakWaveAccessTier.free,
        );
        expect(source.readCount, 0);
      },
    );

    test(
      'protected Free core bypasses entitlement storage',
      () async {
        final _FakeEntitlementSource source =
            _FakeEntitlementSource(
          isPlusUnlocked: false,
          error: StateError('storage unavailable'),
        );

        addTearDown(source.dispose);

        final BreakWaveAccessService service =
            BreakWaveAccessService(
          entitlementSource: source,
        );

        final BreakWaveAccessDecision decision =
            await service.decisionFor(
          BreakWaveFeature.starterRecoveryPlan,
        );

        expect(decision.isAvailable, isTrue);
        expect(
          decision.accessClass,
          BreakWaveAccessClass.protectedFreeCore,
        );
        expect(source.readCount, 0);
      },
    );
  });

  group('BreakWaveAccessService Plus decisions', () {
    test(
      'Plus candidate is locked without entitlement',
      () async {
        final _FakeEntitlementSource source =
            _FakeEntitlementSource(
          isPlusUnlocked: false,
        );

        addTearDown(source.dispose);

        final BreakWaveAccessService service =
            BreakWaveAccessService(
          entitlementSource: source,
        );

        final BreakWaveAccessDecision decision =
            await service.decisionFor(
          BreakWaveFeature.extendedChristianDepth,
        );

        expect(decision.isAvailable, isFalse);
        expect(decision.isLocked, isTrue);
        expect(
          decision.accessClass,
          BreakWaveAccessClass.plusCandidate,
        );
        expect(
          decision.minimumTier,
          BreakWaveAccessTier.plus,
        );
        expect(source.readCount, 1);
      },
    );

    test(
      'Plus candidate opens with entitlement',
      () async {
        final _FakeEntitlementSource source =
            _FakeEntitlementSource(
          isPlusUnlocked: true,
        );

        addTearDown(source.dispose);

        final BreakWaveAccessService service =
            BreakWaveAccessService(
          entitlementSource: source,
        );

        expect(
          await service.isAvailable(
            BreakWaveFeature.extendedChristianDepth,
          ),
          isTrue,
        );

        expect(source.readCount, 1);
      },
    );

    test(
      'Plus source failure fails closed without affecting Free',
      () async {
        final _FakeEntitlementSource source =
            _FakeEntitlementSource(
          isPlusUnlocked: true,
          error: StateError('storage unavailable'),
        );

        addTearDown(source.dispose);

        final BreakWaveAccessService service =
            BreakWaveAccessService(
          entitlementSource: source,
        );

        expect(
          await service.isAvailable(
            BreakWaveFeature.guidedRoutines,
          ),
          isFalse,
        );

        expect(
          await service.isAvailable(
            BreakWaveFeature.rescueActions,
          ),
          isTrue,
        );

        expect(source.readCount, 1);
      },
    );
  });

  test(
    'service exposes entitlement-change notifications',
    () {
      final _FakeEntitlementSource source =
          _FakeEntitlementSource(
        isPlusUnlocked: false,
      );

      addTearDown(source.dispose);

      final BreakWaveAccessService service =
          BreakWaveAccessService(
        entitlementSource: source,
      );

      expect(
        identical(service.changes, source.changes),
        isTrue,
      );
    },
  );
}

class _FakeEntitlementSource
    extends BreakWaveEntitlementSource {
  _FakeEntitlementSource({
    required bool isPlusUnlocked,
    this.error,
  }) : _isPlusUnlocked = isPlusUnlocked;

  final ValueNotifier<int> _changes =
      ValueNotifier<int>(0);

  bool _isPlusUnlocked;
  final Object? error;
  int readCount = 0;

  @override
  ValueListenable<int> get changes => _changes;

  @override
  Future<bool> isPlusUnlocked() async {
    readCount += 1;

    if (error != null) {
      throw error!;
    }

    return _isPlusUnlocked;
  }

  void setPlusUnlocked(bool value) {
    _isPlusUnlocked = value;
    _changes.value += 1;
  }

  void dispose() {
    _changes.dispose();
  }
}
