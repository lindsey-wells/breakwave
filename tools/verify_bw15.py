from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/widgets/wave_timer_card.dart", [
        "class WaveTimerCard",
        "_totalSeconds = 90",
        "Wave Timer",
        "Start 90-second timer",
        "Lower now",
        "Still strong",
        "I slipped",
        "entryType: 'Victory'",
        "entryType: 'Urge'",
        "entryType: 'Slip'",
        "'Wave Timer'",
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

rescue_path = Path("lib/features/rescue/presentation/rescue_screen.dart")
if not rescue_path.exists():
    print("FAIL missing file: lib/features/rescue/presentation/rescue_screen.dart")
    failed = True
else:
    rescue_text = rescue_path.read_text(encoding="utf-8")
    if "WaveTimerCard" not in rescue_text:
        print("FAIL lib/features/rescue/presentation/rescue_screen.dart missing: WaveTimerCard")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-15 wave timer verified.")
