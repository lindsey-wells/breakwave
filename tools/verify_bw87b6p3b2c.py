from pathlib import Path
import sys

paths = {
    "flow": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_flow_screen.dart"
    ),
    "actions": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_actions_step_details.dart"
    ),
    "summary": Path(
        "lib/features/onboarding/presentation/"
        "onboarding_summary_step_details.dart"
    ),
    "tests": Path(
        "test/onboarding_plan_steps_test.dart"
    ),
}

for label, path in paths.items():
    if not path.exists():
        print(
            f"FAIL BW-87B6P3B2C missing {label}: {path}"
        )
        sys.exit(1)

text = {
    label: path.read_text(encoding="utf-8")
    for label, path in paths.items()
}

for needle in [
    "ScrollController _contentScrollController",
    "onboarding-content-list",
    "controller:",
    "_contentScrollController",
    "void _resetContentScroll()",
    "_contentScrollController.jumpTo(0)",
    "_resetContentScroll();",
]:
    if needle not in text["flow"]:
        print(
            "FAIL BW-87B6P3B2C flow missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "bool _editingOther = false",
    "String? get _customOtherLabel",
    "onboarding-add-custom-action",
    "onboarding-edit-custom-action",
    "onboarding-custom-action-",
    "Add custom action",
    "Update custom action",
    "Edit custom action",
    "Tap Add custom action before continuing.",
    "Other: ",
]:
    if needle not in text["actions"]:
        print(
            "FAIL BW-87B6P3B2C actions missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "onChanged: _setOtherText",
    "PremiumStateStore",
    "SupportContactStore",
    "TriggersStore",
]:
    if forbidden in text["actions"]:
        print(
            "FAIL BW-87B6P3B2C unsafe or retired "
            f"action behavior remains: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "_displayInterruptionAction",
    "value.startsWith(otherPrefix)",
    ".map(_displayInterruptionAction)",
]:
    if needle not in text["summary"]:
        print(
            "FAIL BW-87B6P3B2C summary missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "changing onboarding steps resets content scroll to the top",
    "greaterThan(0)",
    "moreOrLessEquals(0, epsilon: 0.1)",
    "onboarding-add-custom-action",
    "onboarding-edit-custom-action",
    "onboarding-custom-action-Step outside for fresh air",
    "Other: Step outside for fresh air",
    "findsNothing",
]:
    if needle not in text["tests"]:
        print(
            "FAIL BW-87B6P3B2C tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2C onboarding scroll reset, "
    "explicit custom-action confirmation, clean summary "
    "display, and regression coverage verified."
)
