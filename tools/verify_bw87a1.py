from pathlib import Path
import sys

text = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
).read_text(encoding="utf-8")

required = [
    "Notes: BW-87A1 removes preview unlock and offer-testing controls.",
    "Immediate support stays free. Plus builds the longer plan.",
    "Free vs Plus",
    "What Plus is built to provide",
    "Deeper patterns and summaries",
    "Your personal recovery plan",
    "Guided recovery routines",
    "Stronger accountability",
    "Christian recovery depth",
    "Expanded privacy and exports",
    "Expected launch pricing",
    r"\$59.99/year",
    r"\$8.99/month",
    "Subscriptions are not enabled in this testing build.",
    "No charge can occur from this screen.",
    "Core Rescue and support tools remain free.",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-87A1 public Plus screen missing: {needle}")
        sys.exit(1)

for forbidden in [
    "PremiumStateStore",
    "_enablePlusPreview",
    "_setVariant",
    "annual_no_trial",
    "annual_trial",
    "Select annual no-trial",
    "Select annual 7-day trial",
    "BreakWave Plus unlocked.",
    "Planned Plus options",
    "Planned launch offer",
    "Explore BreakWave Plus",
]:
    if forbidden in text:
        print(f"FAIL BW-87A1 internal Plus control remains: {forbidden}")
        sys.exit(1)

if "class BreakWavePlusScreen extends StatefulWidget" in text:
    print("FAIL BW-87A1 Plus screen still carries internal mutable state")
    sys.exit(1)

print("PASS: BW-87A1 public BreakWave Plus cleanup verified.")
