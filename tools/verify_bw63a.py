from pathlib import Path
import sys

checks = [
    ("lib/features/recovery_mode/recovery_mode_screen.dart", [
        "_selectedModeExplanation",
        "RecoveryMode.secular",
        "Secular mode is intentionally practical",
        "without religious language",
        "RecoveryMode.christian",
        "Christian mode is intentionally Christian",
        "not generic wellness language",
    ]),
    ("launch/replacement_action_design_note.md", [
        "Healthy Replacement Action Design Note",
        "single-select for MVP",
        "one primary next move",
        "Healthy replacement action = the main intended replacement move",
        "Action taken = what actually happened",
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

screen = Path("lib/features/recovery_mode/recovery_mode_screen.dart").read_text(encoding="utf-8")

if "const Text(\n                _selectedModeExplanation" in screen:
    print("FAIL selected explanation Text cannot be const")
    failed = True

if screen.count("Christian mode is intentionally Christian") < 1:
    print("FAIL Christian explanation copy disappeared")
    failed = True

if screen.count("Secular mode is intentionally practical") < 1:
    print("FAIL Secular explanation copy missing")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-63A recovery mode explanation fix verified.")
