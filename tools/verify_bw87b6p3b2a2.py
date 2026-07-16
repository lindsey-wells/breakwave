from pathlib import Path
import re
import sys

flow_path = Path(
    "lib/features/onboarding/presentation/onboarding_flow_screen.dart"
)

details_path = Path(
    "lib/features/onboarding/presentation/onboarding_reasons_step_details.dart"
)

test_path = Path(
    "test/onboarding_reasons_step_test.dart"
)

contract_path = Path(
    "docs/BW_87B6P_ONBOARDING_DATA_CONTRACT.md"
)

for path in [
    flow_path,
    details_path,
    test_path,
    contract_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P3B2A2 missing file: {path}"
        )
        sys.exit(1)

flow = flow_path.read_text(
    encoding="utf-8"
)

details = details_path.read_text(
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

semantic_details = re.sub(
    r"\s+",
    " ",
    re.sub(
        r"'\s*'",
        "",
        details,
    ),
).strip()

for needle in [
    "OnboardingReasonsStepDetails",
    "_setReasons",
    "_setWhyText",
    "_isCurrentFocusValid",
    "case 4:",
    "_draft.reasons.isNotEmpty",
    "await OnboardingDraftStore.save",
    "await OnboardingStateStore.saveProgress",
]:
    if needle not in flow:
        print(
            "FAIL BW-87B6P3B2A2 flow "
            f"missing: {needle}"
        )
        sys.exit(1)

draft_save = flow.find(
    "await OnboardingDraftStore.save"
)

progress_save = flow.find(
    "await OnboardingStateStore.saveProgress"
)

if (
    draft_save < 0 or
    progress_save < 0 or
    draft_save > progress_save
):
    print(
        "FAIL BW-87B6P3B2A2 draft must be "
        "saved before onboarding progress."
    )
    sys.exit(1)

for needle in [
    "class OnboardingReasonsStepDetails",
    "I want mental clarity.",
    "I want to stop feeding shame and secrecy.",
    "I want to protect my relationships.",
    "I want to break the habit loop.",
    "I want to use my time better.",
    "I want to live with integrity.",
    "Choose what you are protecting",
    "Add your own reason",
    "Current focus",
    "Write your own Why",
    "This is optional and stays private on your device.",
    "onboarding-custom-reason-field",
    "onboarding-add-custom-reason",
    "onboarding-why-field",
]:
    if needle not in semantic_details:
        print(
            "FAIL BW-87B6P3B2A2 details "
            f"missing: {needle}"
        )
        sys.exit(1)

combined = flow + details

for forbidden in [
    "ReasonsStore.saveSelection",
    "CustomWhyStore.save",
    "PremiumStateStore",
    "setPlusUnlocked",
    "RecoveryModeStore.saveMode",
    "purchaseStream",
    "in_app_purchase",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B6P3B2A2 premature "
            f"live-store or billing write: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "Step 5 requires a reason and saves focus only to draft",
    "custom reason and written Why survive navigation and reload",
    "ReasonsStore.storageKey",
    "CustomWhyStore.storageKey",
    "isFalse",
    "Step 6 of 10",
    "OnboardingDraftStore.load",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3B2A2 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "At least one reason and a valid current focus are required",
    "written Why is optional",
    "remain in OnboardingDraftStore",
    "saves the current draft before saving the next onboarding step",
    "must not write ReasonsStore",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P3B2A2 contract "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2A2 draft-backed reasons, "
    "current focus, custom reason, and Why verified."
)
