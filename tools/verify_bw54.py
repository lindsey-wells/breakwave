from pathlib import Path
import sys

checks = [
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "Free immediate relief. Paid ongoing transformation.",
        "BreakWave Plus is for users who want deeper insight",
        "Free vs Plus",
        "BreakWave Plus includes",
        "Deep Insights",
        "Custom Rescue Plan",
        "Guided Recovery Routines",
        "Accountability Tools",
        "Premium Christian Depth",
        "Advanced Privacy and Exports",
        "BreakWave Plus Annual",
        "$59.99/year",
        "BreakWave Plus Monthly",
        "$8.99/month",
        "No weekly plan. No lifetime plan at launch.",
        "Enable Plus preview for testing",
        "Real purchases require the Google Play Developer account",
    ]),
    ("launch/breakwave_plus_value_wall.md", [
        "BreakWave Plus — Value Wall and Feature Map",
        "Free = help me right now.",
        "BreakWave Plus = help me understand the pattern",
        "Deep Insights",
        "Custom Rescue Plan",
        "Guided Recovery Routines",
        "Accountability Tools",
        "Premium Christian Depth",
        "Do not charge for BreakWave Plus until the paid section contains enough real value",
    ]),
    ("tools/verify_bw25.py", [
        "Enable Plus preview for testing",
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

blocked = [
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", "Debug unlock BreakWave Plus"),
]

for rel_path, needle in blocked:
    text = Path(rel_path).read_text(encoding="utf-8")
    if needle in text:
        print(f"FAIL {rel_path} still contains old debug copy: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-54 BreakWave Plus value wall verified.")
