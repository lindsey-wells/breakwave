from pathlib import Path
import sys

home_files = list(
    Path("lib").rglob("*.dart")
)

all_home_source = "\n".join(
    path.read_text(encoding="utf-8")
    for path in home_files
)

focus_card_path = Path(
    "lib/features/reasons/presentation/reasons_focus_card.dart"
)

rescue_why_path = Path(
    "lib/features/rescue/presentation/widgets/remember_why_card.dart"
)

support_why_path = Path(
    "lib/features/support/presentation/widgets/custom_why_settings_card.dart"
)

completion_path = Path(
    "lib/core/onboarding/onboarding_completion_service.dart"
)

test_path = Path(
    "test/reasons_focus_card_copy_test.dart"
)

for path in [
    focus_card_path,
    rescue_why_path,
    support_why_path,
    completion_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6P3B2A2P1 missing file: {path}"
        )
        sys.exit(1)

focus_card = focus_card_path.read_text(
    encoding="utf-8"
)

rescue_why = rescue_why_path.read_text(
    encoding="utf-8"
)

support_why = support_why_path.read_text(
    encoding="utf-8"
)

completion = completion_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

for forbidden in [
    "Your why and risk signals",
    "Your why right now",
    "This keeps Home anchored to something real.",
]:
    if forbidden in all_home_source:
        print(
            "FAIL BW-87B6P3B2A2P1 old copy "
            f"still present: {forbidden}"
        )
        sys.exit(1)

for required in [
    "Your focus and risk signals",
    "Current focus",
    "Choose the reason that matters most right now.",
]:
    if required not in all_home_source:
        print(
            "FAIL BW-87B6P3B2A2P1 new copy "
            f"missing: {required}"
        )
        sys.exit(1)

for required in [
    "ReasonsStore.loadSelection",
    "selection.currentFocus",
    "Current focus",
    "Edit reasons",
]:
    if required not in focus_card:
        print(
            "FAIL BW-87B6P3B2A2P1 focus card "
            f"missing: {required}"
        )
        sys.exit(1)

if "CustomWhyStore" in focus_card:
    print(
        "FAIL BW-87B6P3B2A2P1 Home focus card "
        "must not read the Personal Why store."
    )
    sys.exit(1)

for source, label in [
    (rescue_why, "Rescue"),
    (support_why, "Support"),
]:
    if "CustomWhyStore" not in source:
        print(
            f"FAIL BW-87B6P3B2A2P1 {label} no longer "
            "uses the Personal Why store."
        )
        sys.exit(1)

for required in [
    "ReasonsStore.saveSelection",
    "CustomWhyStore.save",
]:
    if required not in completion:
        print(
            "FAIL BW-87B6P3B2A2P1 completion service "
            f"missing separate write: {required}"
        )
        sys.exit(1)

for required in [
    "Home labels the selected reason as Current focus",
    "find.text('Current focus')",
    "find.text('Your why right now')",
    "findsNothing",
]:
    if required not in tests:
        print(
            "FAIL BW-87B6P3B2A2P1 test "
            f"missing: {required}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6P3B2A2P1 Home Current Focus "
    "and Rescue Personal Why copy are clearly separated."
)
