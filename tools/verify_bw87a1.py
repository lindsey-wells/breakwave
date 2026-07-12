from pathlib import Path
import sys

text = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
).read_text(encoding="utf-8")

required = [
    "class BreakWavePlusScreen extends StatelessWidget",
    "BreakWave Plus is in development.",
    "What Plus must deliver before paid launch",
    "Subscriptions and purchases are not enabled.",
    "No charge can occur from this screen.",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-87A1 public Plus safety missing: {needle}")
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
    "Explore BreakWave Plus",
]:
    if forbidden in text:
        print(f"FAIL BW-87A1 internal Plus control remains: {forbidden}")
        sys.exit(1)

print("PASS: BW-87A1 public BreakWave Plus cleanup verified.")
