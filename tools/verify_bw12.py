from pathlib import Path
import sys

checks = [
    ("lib/features/reasons/presentation/reasons_to_change_screen.dart", [
        "class ReasonsToChangeScreen",
        "Current focus",
        "Save reasons",
        "ReasonsStore.saveSelection",
    ]),
    ("lib/features/reasons/presentation/reasons_focus_card.dart", [
        "class ReasonsFocusCard",
        "Your why right now",
        "This keeps Home anchored to something real.",
        "ReasonsStore.loadSelection",
        "Edit reasons",
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

if failed:
    sys.exit(1)

print("PASS: BW-12 reasons to change verified.")
