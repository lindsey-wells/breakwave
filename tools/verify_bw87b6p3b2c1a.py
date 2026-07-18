from pathlib import Path
import sys

actions_path = Path(
    "lib/features/onboarding/presentation/"
    "onboarding_actions_step_details.dart"
)

test_path = Path(
    "test/onboarding_plan_steps_test.dart"
)

for path in [
    actions_path,
    test_path,
]:
    if not path.exists():
        print(
            "FAIL BW-87B6P3B2C1A missing: "
            f"{path}"
        )
        sys.exit(1)

actions = actions_path.read_text(
    encoding="utf-8",
)

tests = test_path.read_text(
    encoding="utf-8",
)

for needle in [
    "decoration: InputDecoration(",
    "? 'Edit your interruption action'",
    ": 'Add your own interruption action'",
    "? 'Tap Update custom action to save your changes.'",
    ": 'Tap Add custom action to save it.'",
    "? 'Update custom action'",
    ": 'Add custom action'",
]:
    if needle not in actions:
        print(
            "FAIL BW-87B6P3B2C1A actions missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "find.text('Add your own interruption action')",
    "find.text('Tap Add custom action to save it.')",
    "'Add custom action'",
    "find.text('Edit your interruption action')",
    "'Tap Update custom action to save your changes.'",
    "'Update custom action'",
    "findsNothing",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6P3B2C1A tests missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "decoration: const InputDecoration(",
    "PremiumStateStore",
    "SupportContactStore",
    "TriggersStore",
]:
    if forbidden in actions:
        print(
            "FAIL BW-87B6P3B2C1A retired or unsafe "
            f"behavior remains: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2C1A custom-action Add and "
    "Update states use consistent copy with regression coverage."
)
