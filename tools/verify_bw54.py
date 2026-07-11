from pathlib import Path
import sys

checks = [
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "Immediate support stays free. Plus builds the longer plan.",
        "Free vs Plus",
        "What Plus is built to provide",
        "Deeper patterns and summaries",
        "Your personal recovery plan",
        "Guided recovery routines",
        "Stronger accountability",
        "Christian recovery depth",
        "Expanded privacy and exports",
        "BreakWave Plus Annual",
        "$59.99/year",
        "BreakWave Plus Monthly",
        "$8.99/month",
        "No weekly plan and no lifetime plan at launch.",
        "Testing build status",
        "Subscriptions are not enabled in this testing build.",
        "No charge can occur from this screen.",
        "Core Rescue and support tools remain free.",
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
        "Immediate support stays free. Plus builds the longer plan.",
        "Subscriptions are not enabled in this testing build.",
    ]),
]

blocked = [
    "Debug unlock BreakWave Plus",
    "_enablePlusPreview",
    "_setVariant",
    "Select annual no-trial",
    "Select annual 7-day trial",
    "Explore BreakWave Plus",
    "Planned Plus options",
    "Planned launch offer",
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

plus_text = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
).read_text(encoding="utf-8")

for needle in blocked:
    if needle in plus_text:
        print(f"FAIL Plus screen still contains internal control: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-54 BreakWave Plus value wall verified.")
