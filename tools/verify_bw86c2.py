from pathlib import Path
import sys

cycle = Path(
    "lib/features/support/presentation/widgets/education_resources_card.dart"
).read_text(encoding="utf-8")

educate = Path(
    "lib/features/support/presentation/widgets/educate_me_entry_card.dart"
).read_text(encoding="utf-8")

for name, text, label in [
    ("Recovery Cycle Wheel", cycle, "Open Recovery Cycle Wheel"),
    ("Educate Me", educate, "Open Educate Me"),
]:
    for needle in [
        "FilledButton(",
        "width: double.infinity",
        "padding: EdgeInsets.symmetric(vertical: 14)",
        label,
    ]:
        if needle not in text:
            print(f"FAIL BW-86C2 {name} standard button missing: {needle}")
            sys.exit(1)

if cycle.count("FilledButton(") != 1:
    print("FAIL BW-86C2 Recovery Cycle Wheel should have one filled button")
    sys.exit(1)

if educate.count("FilledButton(") != 1:
    print("FAIL BW-86C2 Educate Me should have one filled button")
    sys.exit(1)

print("PASS: BW-86C2 matching BreakWave learning buttons verified.")
