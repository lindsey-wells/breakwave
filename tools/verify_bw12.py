from pathlib import Path
import sys

checks = [
    ("lib/core/reasons/reasons_selection.dart", [
        "class ReasonsSelection",
        "selectedReasons",
        "currentFocus",
        "toJsonString",
        "fromJsonString",
    ]),
    ("lib/core/reasons/reasons_store.dart", [
        "class ReasonsStore",
        "bw_reasons_selection_v1",
        "loadSelection",
        "saveSelection",
    ]),
    ("lib/features/reasons/presentation/reasons_to_change_screen.dart", [
        "class ReasonsToChangeScreen",
        "Reasons to change",
        "Current focus",
        "Save reasons",
        "FilterChip",
        "RadioListTile",
    ]),
    ("lib/features/reasons/presentation/reasons_focus_card.dart", [
        "class ReasonsFocusCard",
        "Current focus",
        "ReasonsToChangeScreen",
        "Set reasons",
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
    if "ReasonsFocusCard" not in home_text:
        print("FAIL lib/features/home/presentation/home_screen.dart missing: ReasonsFocusCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-12 reasons to change verified.")
