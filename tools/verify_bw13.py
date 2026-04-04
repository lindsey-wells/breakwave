from pathlib import Path
import sys

checks = [
    ("lib/core/triggers/triggers_selection.dart", [
        "class TriggersSelection",
        "selectedTriggers",
        "selectedRiskyTimes",
        "toJsonString",
        "fromJsonString",
    ]),
    ("lib/core/triggers/triggers_store.dart", [
        "class TriggersStore",
        "bw_triggers_selection_v1",
        "loadSelection",
        "saveSelection",
    ]),
    ("lib/features/triggers/presentation/triggers_risky_times_screen.dart", [
        "class TriggersRiskyTimesScreen",
        "Triggers and risky times",
        "Common triggers",
        "Risky times",
        "Add custom trigger",
        "Save and return Home",
        "FilterChip",
    ]),
    ("lib/features/triggers/presentation/triggers_watch_card.dart", [
        "class TriggersWatchCard",
        "Watch for",
        "TriggersRiskyTimesScreen",
        "Set triggers",
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
    if "TriggersWatchCard" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: TriggersWatchCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-13 triggers and risky times verified.")
