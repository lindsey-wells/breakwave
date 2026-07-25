from pathlib import Path
import sys


feature_path = Path(
    "lib/core/access/breakwave_feature.dart"
)

access_class_path = Path(
    "lib/core/access/breakwave_access_class.dart"
)

policy_path = Path(
    "lib/core/access/breakwave_access_policy.dart"
)

test_path = Path(
    "test/breakwave_access_policy_test.dart"
)

contract_path = Path(
    "docs/BW_87B6P_PRODUCT_ACCESS_CONTRACT.md"
)

for path in [
    feature_path,
    access_class_path,
    policy_path,
    test_path,
    contract_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P1 missing file: {path}"
        )
        sys.exit(1)

feature = feature_path.read_text(
    encoding="utf-8"
)

access_class = access_class_path.read_text(
    encoding="utf-8"
)

policy = policy_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

contract = contract_path.read_text(
    encoding="utf-8"
)

# Validate human-readable Markdown wording rather than
# failing because a product name uses code styling.
semantic_contract = contract.replace("`", "")

for needle in [
    "enum BreakWaveFeature",
    "rescueNow",
    "rescueActions",
    "onboarding",
    "basicLogging",
    "privacySettings",
    "privacyPolicy",
    "emergencyHelp",
    "humanSupportActions",
    "basicSecularSupport",
    "basicChristianSupport",
    "personalDataControl",
    "basicRecoverySnapshot",
    "advancedRecoveryInsights",
    "starterRecoveryPlan",
    "savedPersonalRecoveryPlan",
    "guidedRoutines",
    "christianJourneys",
    "enhancedRecoveryReports",
    "extendedChristianDepth",
]:
    if needle not in feature:
        print(
            "FAIL BW-87B6P1 feature model "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "enum BreakWaveAccessTier",
    "enum BreakWaveAccessClass",
    "BreakWaveAccessTier.free",
    "BreakWaveAccessTier.plus",
    "BreakWaveAccessClass.neverPaywalled",
    "BreakWaveAccessClass.protectedFreeCore",
    "BreakWaveAccessClass.freeSupport",
    "BreakWaveAccessClass.plusCandidate",
]:
    if needle not in access_class:
        print(
            "FAIL BW-87B6P1 access classification "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "class BreakWaveAccessPolicy",
    "BreakWaveFeature.rescueNow",
    "BreakWaveFeature.rescueActions",
    "BreakWaveFeature.onboarding",
    "BreakWaveFeature.basicLogging",
    "BreakWaveFeature.logHistory",
    "BreakWaveFeature.privacySettings",
    "BreakWaveFeature.privacyPolicy",
    "BreakWaveFeature.emergencyHelp",
    "BreakWaveFeature.humanSupportActions",
    "BreakWaveFeature.basicSecularSupport",
    "BreakWaveFeature.basicChristianSupport",
    "BreakWaveFeature.personalDataControl",
    "BreakWaveAccessClass.neverPaywalled",
    "BreakWaveAccessClass.protectedFreeCore",
    "BreakWaveAccessClass.freeSupport",
    "BreakWaveAccessClass.plusCandidate",
    "accessClassFor",
    "minimumTierFor",
    "required bool isPlusUnlocked",
    "plusCandidates",
]:
    if needle not in policy:
        print(
            "FAIL BW-87B6P1 access policy "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "every feature has exactly one classification",
    "required protections are explicitly never paywalled",
    "Rescue screen and Rescue actions are separately protected",
    "protected Free core remains available without Plus",
    "Free support remains available without Plus",
    "starter plan is Free and saved deeper plan is Plus",
    "personal-data control is Free and reports are Plus",
    "basic Christian support is Free and depth is Plus",
    "approved Plus candidates require entitlement",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P1 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "Rescue must remain reachable from onboarding",
    "Completing or skipping setup",
    "Existing installations",
    "Restore Purchases",
    "PremiumStateStore is a local testing scaffold",
    "No billing dependency",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P1 contract missing: "
            f"{needle}"
        )
        sys.exit(1)

combined = "\n".join(
    [
        feature,
        access_class,
        policy,
        tests,
        contract,
    ]
)

for forbidden in [
    "in_app_purchase",
    "purchaseStream",
    "buyNonConsumable",
    "buyConsumable",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B6P1 prematurely adds "
            f"billing behavior: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P1 modular Free-versus-Plus "
    "product and safety contract verified."
)
