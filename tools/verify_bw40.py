from pathlib import Path
import sys

checks = [
    ("lib/core/ui/section_header.dart", [
        "class SectionHeader",
        "eyebrow",
        "title",
    ]),
    ("lib/features/home/presentation/home_screen.dart", [
        "SectionHeader",
        "Current snapshot",
        "Act now",
        "Pattern awareness",
        "See where you are right now",
        "Use the fastest next step",
        "Learn what keeps the wave going",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "SectionHeader",
        "Ride the wave",
        "Interrupt now",
        "Finish honestly",
        "Slow the surge before it gets louder",
        "Use one immediate redirect",
        "Mark what happened and get support",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "SectionHeader",
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

print("PASS: BW-40 density and information architecture cleanup verified.")
