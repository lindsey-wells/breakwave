from pathlib import Path
import re
import sys

model_path = Path(
    "lib/core/onboarding/onboarding_draft.dart"
)

store_path = Path(
    "lib/core/onboarding/onboarding_draft_store.dart"
)

test_path = Path(
    "test/onboarding_draft_store_test.dart"
)

contract_path = Path(
    "docs/BW_87B6P_ONBOARDING_DATA_CONTRACT.md"
)

for path in [
    model_path,
    store_path,
    test_path,
    contract_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P3A1 missing file: {path}"
        )
        sys.exit(1)

model = model_path.read_text(
    encoding="utf-8"
)

store = store_path.read_text(
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
    "enum OnboardingAccessChoice",
    "continueFree",
    "reviewPlus",
    "class OnboardingDraft",
    "currentSchemaVersion = 1",
    "RecoveryMode? recoveryMode",
    "supportNeeds",
    "reasons",
    "currentFocus",
    "whyText",
    "triggers",
    "riskyTimes",
    "interruptionActions",
    "accessChoice",
    "preparedForSave",
    "hasAnyAnswer",
]:
    if needle not in model:
        print(
            "FAIL BW-87B6P3A1 model "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "phoneNumber",
    "emailAddress",
    "imagePath",
    "trustedContact",
    "passcode",
    "thought",
    "consequence",
    "notes",
]:
    if forbidden in model:
        print(
            "FAIL BW-87B6P3A1 sensitive "
            f"draft field found: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "bw_onboarding_draft_v1",
    "OnboardingDraft.empty",
    "preparedForSave",
    "currentSchemaVersion",
    "Future<void> clear",
    "jsonEncode",
    "jsonDecode",
]:
    if needle not in store:
        print(
            "FAIL BW-87B6P3A1 store "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "RecoveryModeStore",
    "ReasonsStore",
    "TriggersStore",
    "CustomWhyStore",
    "PersonalRecoveryPlanStore",
    "PremiumStateStore",
    "in_app_purchase",
    "purchaseStream",
]:
    if forbidden in store:
        print(
            "FAIL BW-87B6P3A1 draft store "
            f"writes outside its scope: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "missing draft loads as empty",
    "save normalizes duplicate and blank answers",
    "draft round trip preserves supported answers",
    "corrupt draft fails safely as empty",
    "older schema upgrades without losing answers",
    "review Plus choice does not alter premium state",
    "clearing draft leaves real recovery data untouched",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3A1 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "The draft must not contain",
    "Phone numbers",
    "Email addresses",
    "Why image paths",
    "CBT reflection text",
    "does not unlock Plus",
    "Skipping onboarding",
    "never erase previously saved recovery data",
]:
    if needle not in semantic_contract:
        print(
            "FAIL BW-87B6P3A1 contract "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3A1 safe versioned "
    "onboarding draft persistence verified."
)
