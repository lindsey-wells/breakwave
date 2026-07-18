from pathlib import Path
import sys

actions_path = Path(
    "lib/features/onboarding/presentation/"
    "onboarding_actions_step_details.dart"
)

test_path = Path(
    "test/onboarding_plan_steps_test.dart"
)

b2c_path = Path(
    "tools/verify_bw87b6p3b2c.py"
)

for path in [
    actions_path,
    test_path,
    b2c_path,
]:
    if not path.exists():
        print(
            "FAIL BW-87B6P3B2C1 missing: "
            f"{path}"
        )
        sys.exit(1)

actions = actions_path.read_text(
    encoding="utf-8",
)

tests = test_path.read_text(
    encoding="utf-8",
)

b2c = b2c_path.read_text(
    encoding="utf-8",
)

base_start = actions.find(
    "static const List<String> _baseActions"
)

base_end = actions.find(
    "];",
    base_start,
)

if base_start < 0 or base_end < 0:
    print(
        "FAIL BW-87B6P3B2C1 could not inspect "
        "the preset-action catalog."
    )
    sys.exit(1)

base_actions = actions[
    base_start:base_end
]

if "_otherLabel" in base_actions:
    print(
        "FAIL BW-87B6P3B2C1 Other remains a "
        "visible preset action."
    )
    sys.exit(1)

for needle in [
    "static const String _otherLabel = 'Other';",
    "static const String _otherPrefix = 'Other: ';",
    "if (!_hasCustomOther || _editingOther)",
    "Add your own interruption action",
    "Tap Add custom action.",
    "onboarding-add-custom-action",
    "onboarding-edit-custom-action",
    "onboarding-custom-action-",
    ".add('$_otherPrefix$custom')",
]:
    if needle not in actions:
        print(
            "FAIL BW-87B6P3B2C1 actions missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "'Name your other interruption action'",
    "'Tap Add custom action before continuing.'",
    "onChanged: _setOtherText",
    "PremiumStateStore",
    "SupportContactStore",
    "TriggersStore",
]:
    if forbidden in actions:
        print(
            "FAIL BW-87B6P3B2C1 retired or unsafe "
            f"behavior remains: {forbidden}"
        )
        sys.exit(1)

required_test_sequence = [
    "'onboarding-action-Other'",
    "findsNothing",
    "'onboarding-other-action-field'",
    "findsOneWidget",
    "'Step outside for fresh air'",
    "'onboarding-add-custom-action'",
    "'onboarding-custom-action-Step outside for fresh air'",
    "'Other: Step outside for fresh air'",
    "'onboarding-edit-custom-action'",
]

position = -1

for needle in required_test_sequence:
    next_position = tests.find(
        needle,
        position + 1,
    )

    if next_position < 0:
        print(
            "FAIL BW-87B6P3B2C1 test sequence "
            f"missing: {needle}"
        )
        sys.exit(1)

    position = next_position

if "await tester.tap(other);" in tests:
    print(
        "FAIL BW-87B6P3B2C1 test still requires "
        "a preliminary Other-chip tap."
    )
    sys.exit(1)

if '"Tap Add custom action",' not in b2c:
    print(
        "FAIL BW-87B6P3B2C1 historical B2C "
        "verifier was not generalized."
    )
    sys.exit(1)

if (
    '"Tap Add custom action before continuing.",'
    in b2c
):
    print(
        "FAIL BW-87B6P3B2C1 historical B2C "
        "verifier still freezes retired copy."
    )
    sys.exit(1)

print(
    "PASS: BW-87B6P3B2C1 direct custom-entry "
    "parity and historical verifier compatibility verified."
)
