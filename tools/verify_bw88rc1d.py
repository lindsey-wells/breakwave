#!/usr/bin/env python3
"""Verify centralized, modular BreakWave access decisions."""

from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

FILES = {
    "source": ROOT / (
        "lib/core/access/"
        "breakwave_entitlement_source.dart"
    ),
    "adapter": ROOT / (
        "lib/core/access/"
        "local_premium_entitlement_source.dart"
    ),
    "decision": ROOT / (
        "lib/core/access/"
        "breakwave_access_decision.dart"
    ),
    "service": ROOT / (
        "lib/core/access/"
        "breakwave_access_service.dart"
    ),
    "gate": ROOT / (
        "lib/features/premium/presentation/"
        "premium_gate_tile.dart"
    ),
    "faith": ROOT / (
        "lib/features/faith/presentation/"
        "faith_depth_pack_screen.dart"
    ),
    "test": ROOT / (
        "test/breakwave_access_service_test.dart"
    ),
    "contract": ROOT / (
        "docs/BW_87B6P_PRODUCT_ACCESS_CONTRACT.md"
    ),
}


def fail(message: str) -> None:
    print(f"BW-88RC1D VERIFY: FAIL — {message}")
    raise SystemExit(1)


for name, path in FILES.items():
    if not path.is_file():
        fail(
            f"missing {name}: "
            f"{path.relative_to(ROOT)}"
        )

texts = {
    name: path.read_text(encoding="utf-8")
    for name, path in FILES.items()
}

for needle in (
    "abstract class BreakWaveEntitlementSource",
    "ValueListenable<int> get changes",
    "Future<bool> isPlusUnlocked()",
):
    if needle not in texts["source"]:
        fail(f"entitlement source missing: {needle}")

for needle in (
    "class LocalPremiumEntitlementSource",
    "extends BreakWaveEntitlementSource",
    "PremiumStateStore.changes",
    "PremiumStateStore.load()",
):
    if needle not in texts["adapter"]:
        fail(f"local adapter missing: {needle}")

for needle in (
    "class BreakWaveAccessDecision",
    "final BreakWaveFeature feature",
    "final BreakWaveAccessClass accessClass",
    "final BreakWaveAccessTier minimumTier",
    "final bool isAvailable",
    "bool get isLocked",
):
    if needle not in texts["decision"]:
        fail(f"access decision missing: {needle}")

for needle in (
    "class BreakWaveAccessService",
    "static const BreakWaveAccessService localTesting",
    "final BreakWaveEntitlementSource entitlementSource",
    "Future<BreakWaveAccessDecision> decisionFor",
    "BreakWaveAccessPolicy.accessClassFor",
    "BreakWaveAccessPolicy.minimumTierFor",
    "if (!accessClass.requiresPlus)",
    "await entitlementSource.isPlusUnlocked()",
    "Future<bool> isAvailable",
):
    if needle not in texts["service"]:
        fail(f"access service missing: {needle}")

for forbidden in (
    "PremiumStateStore",
    "PremiumState",
    "SharedPreferences",
    "RecoveryModeStore",
    "LogRepository",
):
    if forbidden in texts["service"]:
        fail(
            "central service directly depends on "
            f"forbidden implementation/data: {forbidden}"
        )

for needle in (
    "required this.feature",
    "final BreakWaveFeature feature",
    "final BreakWaveAccessService accessService",
    "widget.accessService.decisionFor",
    "widget.feature",
):
    if needle not in texts["gate"]:
        fail(f"premium gate missing: {needle}")

for needle in (
    "final BreakWaveAccessService accessService",
    "widget.accessService.decisionFor",
    "BreakWaveFeature.extendedChristianDepth",
    "_hasFeatureAccess",
):
    if needle not in texts["faith"]:
        fail(f"faith depth screen missing: {needle}")

for presentation_name in ("gate", "faith"):
    for forbidden in (
        "PremiumStateStore",
        "PremiumState",
    ):
        if forbidden in texts[presentation_name]:
            fail(
                f"{presentation_name} bypasses central "
                f"access service through {forbidden}"
            )

feature_store_references = []

for path in (ROOT / "lib/features").rglob("*.dart"):
    text = path.read_text(encoding="utf-8")

    if "PremiumStateStore" in text:
        feature_store_references.append(
            str(path.relative_to(ROOT))
        )

if feature_store_references:
    fail(
        "presentation/features still read "
        "PremiumStateStore directly: "
        f"{feature_store_references}"
    )

for needle in (
    "never-paywalled access bypasses entitlement storage",
    "protected Free core bypasses entitlement storage",
    "Plus candidate is locked without entitlement",
    "Plus candidate opens with entitlement",
    "Plus source failure fails closed without affecting Free",
    "service exposes entitlement-change notifications",
    "expect(source.readCount, 0)",
):
    if needle not in texts["test"]:
        fail(f"service test evidence missing: {needle}")

for needle in (
    "BreakWaveAccessService",
    "replaceable entitlement source",
    "testing-build compatibility",
    "Presentation code must not read billing or local",
):
    if needle not in texts["contract"]:
        fail(f"access contract missing: {needle}")

combined = "\n".join(texts.values())

for forbidden in (
    "in_app_purchase",
    "purchaseStream",
    "buyNonConsumable",
    "buyConsumable",
    "purchases_flutter",
    "RevenueCat",
):
    if forbidden in combined:
        fail(
            "centralization pass prematurely adds "
            f"billing behavior: {forbidden}"
        )

print("BW-88RC1D VERIFY: PASS")
print("Central service: BreakWaveAccessService")
print("Entitlement adapter: LocalPremiumEntitlementSource")
print("Direct PremiumStateStore readers in lib/features: 0")
print("Billing dependencies introduced: 0")
