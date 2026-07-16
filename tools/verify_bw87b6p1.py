from pathlib import Path
import sys

feature_path = Path(
    "lib/core/access/breakwave_feature.dart"
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

policy = policy_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

contract = contract_path.read_text(
    encoding="utf-8"
)

# Validate the human-readable Markdown wording rather
# than failing because a product name uses code styling.
semantic_contract = contract.replace("`", "")

for needle in [
    "enum BreakWaveAccessTier",
    "enum BreakWaveFeature",
    "rescueNow",
    "basicLogging",
    "privacySettings",
    "supportResources",
    "recoveryInsights",
    "personalRecoveryPlan",
    "guidedRoutines",
    "christianJourneys",
    "recoveryReports",
]:
    if needle not in feature:
        print(
            "FAIL BW-87B6P1 feature model "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "protectedFreeCore",
    "BreakWaveFeature.rescueNow",
    "BreakWaveFeature.basicLogging",
    "BreakWaveFeature.logHistory",
    "BreakWaveFeature.privacySettings",
    "BreakWaveFeature.supportResources",
    "BreakWaveAccessTier.free",
    "BreakWaveAccessTier.plus",
    "required bool isPlusUnlocked",
]:
    if needle not in policy:
        print(
            "FAIL BW-87B6P1 access policy "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "every feature is classified exactly once",
    "protected recovery core always remains free",
    "Rescue remains available without Plus",
    "Plus tools require a verified entitlement",
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

for forbidden in [
    "in_app_purchase",
    "purchaseStream",
    "buyNonConsumable",
    "buyConsumable",
]:
    combined = feature + policy + tests + contract

    if forbidden in combined:
        print(
            "FAIL BW-87B6P1 prematurely adds "
            f"billing behavior: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P1 Free-versus-Plus "
    "product and safety contract verified."
)
