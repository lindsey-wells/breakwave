from pathlib import Path
import sys

checks = [
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "BreakWave Plus is in development.",
        "Available free in this testing build",
        "What Plus must deliver before paid launch",
        "Meaningful insights",
        "A saved personal recovery plan",
        "Guided recovery routines",
        "Useful accountability tools",
        "Substantial Christian depth",
        "Meaningful recovery exports",
        "Our paid-launch standard",
        "Current testing status",
        "Subscriptions and purchases are not enabled.",
        "No charge can occur from this screen.",
    ]),
    ("launch/breakwave_plus_value_wall.md", [
        "Beta status:",
        "product concept",
        "BreakWave Plus — Value Wall and Feature Map",
        "Do not charge for BreakWave Plus until the paid section contains enough real value",
        "breakwave_plus_paid_launch_gate.md",
    ]),
    ("launch/breakwave_plus_paid_launch_gate.md", [
        "BreakWave Plus — Paid Launch Gate",
        "30-day and 90-day recovery history",
        "Personal recovery plan",
        "At least five complete routines",
        "Christian depth must be more than static reading cards.",
        "Google Play Billing must be implemented and tested",
    ]),
    ("tools/verify_bw25.py", [
        "BreakWave Plus is in development.",
        "Preview Plus roadmap",
    ]),
]

blocked = [
    "Debug unlock BreakWave Plus",
    "_enablePlusPreview",
    "_setVariant",
    "Select annual no-trial",
    "Select annual 7-day trial",
    "Explore BreakWave Plus",
    "Subscription pricing preview",
    "$59.99/year",
    "$8.99/month",
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
        print(f"FAIL Plus screen contains blocked paid/internal wording: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-54 BreakWave Plus honest value wall verified.")
