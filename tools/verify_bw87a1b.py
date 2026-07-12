from pathlib import Path
import sys

text = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
).read_text(encoding="utf-8")

required = [
    "Notes: BW-87A1B clarifies pricing-preview language.",
    "Subscription pricing preview",
    "These are the prices currently planned for launch.",
    "They may change before subscriptions are enabled.",
    "Testing build status",
    "Subscriptions are not enabled in this testing build.",
    "No charge can occur from this screen.",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-87A1B pricing-preview wording missing: {needle}")
        sys.exit(1)

for forbidden in [
    "Expected launch pricing",
    "Pricing shown is the intended launch pricing",
]:
    if forbidden in text:
        print(f"FAIL BW-87A1B old pricing wording remains: {forbidden}")
        sys.exit(1)

print("PASS: BW-87A1B subscription pricing preview wording verified.")
