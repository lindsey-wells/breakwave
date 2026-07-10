from pathlib import Path
import sys

support = Path(
    "lib/features/support/presentation/support_screen.dart"
).read_text(encoding="utf-8")

cycle = Path(
    "lib/features/support/presentation/widgets/education_resources_card.dart"
).read_text(encoding="utf-8")

educate = Path(
    "lib/features/support/presentation/widgets/educate_me_entry_card.dart"
).read_text(encoding="utf-8")

start = support.find("eyebrow: 'Recovery model'")
end = support.find("eyebrow: 'Get help now'")

if start == -1 or end == -1:
    print("FAIL BW-86C1 could not locate Recovery model group")
    sys.exit(1)

group = support[start:end]

if "initiallyExpanded: false" not in group:
    print("FAIL BW-86C1 Recovery model is not collapsed by default")
    sys.exit(1)

for name, text, label, destination in [
    (
        "Recovery Cycle Wheel",
        cycle,
        "Open Recovery Cycle Wheel",
        "RecoveryCycleWheelScreen",
    ),
    (
        "Educate Me",
        educate,
        "Open Educate Me",
        "EducateMeScreen",
    ),
]:
    required = [
        "Container(",
        "SizedBox(",
        "width: double.infinity",
        "FilledButton(",
        label,
        destination,
        "padding: EdgeInsets.symmetric(vertical: 14)",
    ]

    for needle in required:
        if needle not in text:
            print(f"FAIL BW-86C1 {name} card missing: {needle}")
            sys.exit(1)

    if "InkWell(" in text:
        print(f"FAIL BW-86C1 {name} still uses whole-card InkWell")
        sys.exit(1)

print("PASS: BW-86C1 Support learning cards and buttons verified.")
