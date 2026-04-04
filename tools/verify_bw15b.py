from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/widgets/wave_timer_card.dart", [
        "void _resetTimerState()",
        "_timer?.cancel();",
        "_remainingSeconds = _totalSeconds;",
        "_isRunning = false;",
        "setState(() {",
        "_resetTimerState();",
        "widget.onReturnHome();",
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

print("PASS: BW-15B wave timer reset verified.")
