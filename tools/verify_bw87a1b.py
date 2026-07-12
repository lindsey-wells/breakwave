from pathlib import Path
import sys

text = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
).read_text(encoding="utf-8")

required = [
    "BreakWave Plus is in development.",
    "Current testing status",
    "Subscriptions and purchases are not enabled.",
    "No charge can occur from this screen.",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-87A1B current testing wording missing: {needle}")
        sys.exit(1)

for forbidden in [
    "Expected launch pricing",
    "Subscription pricing preview",
    "These are the prices currently planned for launch.",
    "$59.99/year",
    "$8.99/month",
]:
    if forbidden in text:
        print(f"FAIL BW-87A1B obsolete pricing preview remains: {forbidden}")
        sys.exit(1)

print("PASS: BW-87A1B obsolete beta pricing removed.")
