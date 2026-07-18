from pathlib import Path
import sys

paths = {
    "actions": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_actions_step_details.dart"
    ),
    "tests": Path(
        "test/onboarding_plan_steps_test.dart"
    ),
    "b2c1": Path(
        "tools/verify_bw87b6p3b2c1.py"
    ),
    "b2c1a": Path(
        "tools/verify_bw87b6p3b2c1a.py"
    ),
}

for label, path in paths.items():
    if not path.exists():
        print(
            f"FAIL BW-87B6P3B2C1B missing {label}: "
            f"{path}"
        )
        sys.exit(1)

text = {
    label: path.read_text(encoding="utf-8")
    for label, path in paths.items()
}

for needle in [
    "? 'Tap Update custom action.'",
    ": 'Tap Add custom action.'",
    "? 'Update custom action'",
    ": 'Add custom action'",
]:
    if needle not in text["actions"]:
        print(
            "FAIL BW-87B6P3B2C1B actions missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "find.text('Tap Add custom action.')",
    "'Tap Update custom action.'",
    "'Add custom action'",
    "'Update custom action'",
    "findsNothing",
]:
    if needle not in text["tests"]:
        print(
            "FAIL BW-87B6P3B2C1B tests missing: "
            f"{needle}"
        )
        sys.exit(1)

if "Tap Add custom action." not in text["b2c1"]:
    print(
        "FAIL BW-87B6P3B2C1B B2C1 verifier "
        "missing short Add helper."
    )
    sys.exit(1)

for needle in [
    "Tap Add custom action.",
    "Tap Update custom action.",
]:
    if needle not in text["b2c1a"]:
        print(
            "FAIL BW-87B6P3B2C1B B2C1A verifier "
            f"missing: {needle}"
        )
        sys.exit(1)

for retired in [
    "Tap Update custom action to save your changes.",
    "Tap Add custom action to save it.",
]:
    for label, content in text.items():
        if retired in content:
            print(
                "FAIL BW-87B6P3B2C1B retired long "
                f"copy remains in {label}: {retired}"
            )
            sys.exit(1)

for unsafe in [
    "PremiumStateStore",
    "SupportContactStore",
    "TriggersStore",
]:
    if unsafe in text["actions"]:
        print(
            "FAIL BW-87B6P3B2C1B unsafe behavior "
            f"appeared in actions: {unsafe}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2C1B short Add and Update "
    "helper copy and regression coverage verified."
)
