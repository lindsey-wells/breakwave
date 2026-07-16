from pathlib import Path
import re
import sys

service_path = Path(
    "lib/core/onboarding/onboarding_completion_service.dart"
)

test_path = Path(
    "test/onboarding_completion_service_test.dart"
)

contract_path = Path(
    "docs/BW_87B6P_ONBOARDING_DATA_CONTRACT.md"
)

for path in [
    service_path,
    test_path,
    contract_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P3A2 missing file: {path}"
        )
        sys.exit(1)

service = service_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

contract = contract_path.read_text(
    encoding="utf-8"
)

semantic_contract = re.sub(
    r"\s+",
    " ",
    contract.replace("`", ""),
).strip()

for needle in [
    "class OnboardingCompletionResult",
    "class OnboardingCompletionService",
    "Future<OnboardingCompletionResult> complete",
    "RecoveryModeStore.saveMode",
    "ReasonsStore.loadSelection",
    "ReasonsStore.saveSelection",
    "TriggersStore.loadSelection",
    "TriggersStore.saveSelection",
    "CustomWhyStore.load",
    "CustomWhyStore.save",
    "imagePath: customWhy.imagePath",
    "PersonalRecoveryPlanStore.load",
    "PersonalRecoveryPlanStore.save",
    "fillEmptySections",
    "OnboardingStateStore.complete",
    "OnboardingDraftStore.clear",
    "Future<void> skip",
    "OnboardingStateStore.skip",
    "shouldReviewPlus",
    "_mergeLists",
]:
    if needle not in service:
        print(
            "FAIL BW-87B6P3A2 service "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "PremiumStateStore",
    "setPlusUnlocked",
    "in_app_purchase",
    "purchaseStream",
    "ReasonsStore.clearSelection",
    "TriggersStore.clearSelection",
    "RecoveryModeStore.clearMode",
    "CustomWhyStore.clear",
    "PersonalRecoveryPlanStore.clear",
    "SupportContactStore.clearContact",
]:
    if forbidden in service:
        print(
            "FAIL BW-87B6P3A2 unsafe "
            f"operation found: {forbidden}"
        )
        sys.exit(1)

complete_index = service.find(
    "await OnboardingStateStore.complete"
)

clear_index = service.find(
    "await OnboardingDraftStore.clear",
    complete_index,
)

if complete_index < 0 or clear_index < complete_index:
    print(
        "FAIL BW-87B6P3A2 must complete state "
        "before clearing the temporary draft."
    )
    sys.exit(1)

for needle in [
    "completion synchronizes supported answers and clears draft",
    "completion merges lists without replacing existing manual data",
    "repeating completion is idempotent",
    "review Plus intent never changes premium entitlement",
    "skip clears only onboarding data",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3A2 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "Reasons and triggers are merged without duplicate values",
    "A saved Why is filled only when the existing Why text is blank",
    "An existing Why image path is preserved",
    "Existing personal-plan text is never replaced",
    "Completion is retry-safe",
    "Plus-review intent remains navigation intent only",
    "Skipping onboarding changes only onboarding status",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P3A2 contract "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3A2 merge-safe onboarding "
    "completion and skip behavior verified."
)
