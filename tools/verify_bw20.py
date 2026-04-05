from pathlib import Path
import sys

checks = [
    ("lib/features/insights/presentation/simple_insights_card.dart", [
        "class SimpleInsightsCard",
        "Simple insights",
        "Recent entries:",
        "Intensity trend:",
        "Rescue follow-through:",
        "Watch pattern:",
        "Daily contact:",
        "TriggersStore.loadSelection()",
        "DailyCheckInStore.loadEntries()",
        "_repository.loadEntries()",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

home_path = Path("lib/features/home/presentation/home_screen.dart")
if not home_path.exists():
    print("FAIL missing file: lib/features/home/presentation/home_screen.dart")
    failed = True
else:
    home_text = home_path.read_text(encoding="utf-8")
    if "SimpleInsightsCard" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: SimpleInsightsCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-20 simple insights surface verified.")
