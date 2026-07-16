from pathlib import Path
import re
import sys

flow_path = Path(
    "lib/features/onboarding/presentation/onboarding_flow_screen.dart"
)

details_path = Path(
    "lib/features/onboarding/presentation/onboarding_intro_step_details.dart"
)

test_path = Path(
    "test/onboarding_intro_steps_test.dart"
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
            f"FAIL BW-87B6P3B2A1 missing file: {path}"
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
    "OnboardingDraft _draft",
    "_draftLoading",
    "_loadDraft",
    "OnboardingDraftStore.load",
    "_replaceDraft",
    "OnboardingDraftStore.save",
    "_setRecoveryMode",
    "_setSupportNeed",
    "_canContinueCurrentStep",
    "OnboardingIntroStepDetails",
    "_draft.recoveryMode != null",
    "_draft.supportNeeds.isNotEmpty",
]:
    if needle not in flow:
        print(
            "FAIL BW-87B6P3B2A1 flow "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "class OnboardingIntroStepDetails",
    "onboarding-welcome-details",
    "Why this exists",
    "help should be within reach",
    "not therapy, medical treatment, or a cure",
    "onboarding-privacy-details",
    "What stays private",
    "Local by default",
    "No automatic sharing",
    "Preview before sharing",
    "onboarding-recovery-mode-details",
    "Choose the voice that fits you",
    "RecoveryMode.values",
    "RecoveryMode.christian",
    "onboarding-support-needs-details",
    "Select everything that would help",
    "Interrupt urges quickly",
    "Understand my patterns",
    "Prepare for risky times",
    "Build a practical recovery plan",
    "Stay encouraged after setbacks",
    "Choose at least one area to continue",
]:
    if needle not in semantic_details:
        print(
            "FAIL BW-87B6P3B2A1 details "
            f"missing: {needle}"
        )
        sys.exit(1)

combined = flow + details

for forbidden in [
    "RecoveryModeStore.saveMode",
    "PremiumStateStore",
    "setPlusUnlocked",
    "ReasonsStore.saveSelection",
    "TriggersStore.saveSelection",
    "CustomWhyStore.save",
    "PersonalRecoveryPlanStore.save",
    "purchaseStream",
    "in_app_purchase",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B6P3B2A1 live-store "
            f"or billing write found: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "welcome and privacy explain purpose and local control",
    "recovery mode is required and saved only to draft",
    "support need is required and survives draft reload",
    "bw_recovery_mode_v1",
    "isFalse",
    "OnboardingDraftStore.load",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3B2A1 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "first four onboarding screens provide real setup content",
    "saved only to the temporary onboarding draft",
    "both paths retain access to Rescue",
    "Christian mode is explicit and optional",
    "does not diagnose the user",
    "A recovery mode and at least one support need are required",
    "do not write RecoveryModeStore",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P3B2A1 contract "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2A1 real welcome, privacy, "
    "mode, and support-needs setup verified."
)
