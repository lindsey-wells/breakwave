from pathlib import Path
import sys

plus_path = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
)
support_path = Path(
    "lib/features/support/presentation/support_screen.dart"
)
learn_path = Path(
    "lib/features/learn/presentation/educate_me_screen.dart"
)
gate_path = Path("launch/breakwave_plus_paid_launch_gate.md")

plus = plus_path.read_text(encoding="utf-8")
support = support_path.read_text(encoding="utf-8")
learn = learn_path.read_text(encoding="utf-8")
gate = gate_path.read_text(encoding="utf-8")

required_plus = [
    "Notes: BW-87B1 removes pricing and unavailable-feature sales claims.",
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
]

for needle in required_plus:
    if needle not in plus:
        print(f"FAIL BW-87B1 Plus roadmap missing: {needle}")
        sys.exit(1)

for forbidden in [
    "$59.99/year",
    "$8.99/month",
    "Subscription pricing preview",
    "Expected launch pricing",
    "Pricing shown is the intended launch pricing",
    "Explore BreakWave Plus",
    "Select annual no-trial",
    "Select annual 7-day trial",
]:
    if forbidden in plus:
        print(f"FAIL BW-87B1 paid or internal wording remains: {forbidden}")
        sys.exit(1)

for forbidden in [
    "title: 'Deeper insights and exports'",
    "title: 'Faith depth pack'",
    "PremiumGateTile(",
]:
    if forbidden in support:
        print(f"FAIL BW-87B1 dead Support gate remains: {forbidden}")
        sys.exit(1)

if "Preview Plus roadmap" not in support:
    print("FAIL BW-87B1 Support roadmap button missing")
    sys.exit(1)

if "Guided learning and routines" in learn:
    print("FAIL BW-87B1 dead Educate Me Plus gate remains")
    sys.exit(1)

required_gate = [
    "BreakWave Plus — Paid Launch Gate",
    "30-day and 90-day recovery history",
    "Personal recovery plan",
    "At least five complete routines",
    "Christian depth must be more than static reading cards.",
    "Paid exports must include selected recovery information",
    "Google Play Billing must be implemented and tested",
    "Monthly and annual plans must include the same core recovery features",
    "Static copy, placeholder gates, future-feature promises",
]

for needle in required_gate:
    if needle not in gate:
        print(f"FAIL BW-87B1 paid launch gate missing: {needle}")
        sys.exit(1)

print("PASS: BW-87B1 Plus honesty and paid-launch safety verified.")
