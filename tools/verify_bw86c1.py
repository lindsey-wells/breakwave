from pathlib import Path
import sys

support = Path(
    "lib/features/support/presentation/support_screen.dart"
).read_text(encoding="utf-8")

education = Path(
    "lib/features/support/presentation/widgets/education_resources_card.dart"
).read_text(encoding="utf-8")

educate_me = Path(
    "lib/features/support/presentation/widgets/educate_me_entry_card.dart"
).read_text(encoding="utf-8")

start = support.find("eyebrow: 'Recovery model'")
end = support.find("eyebrow: 'Get help now'")

if start == -1 or end == -1:
    print("FAIL BW-86C1 could not locate Recovery model group")
    sys.exit(1)

group = support[start:end]

if "initiallyExpanded: false" not in group:
    print("FAIL BW-86C1 Recovery model is not collapsed by default")
    sys.exit(1)

if "initiallyExpanded: true" in group:
    print("FAIL BW-86C1 Recovery model still opens automatically")
    sys.exit(1)

for needle in [
    "Notes: BW-86C1 matches the Recovery Cycle Wheel and Educate Me card layouts.",
    "InkWell(",
    "RecoveryCycleWheelScreen",
    "Recovery Cycle Wheel",
    "Tap to open Recovery Cycle Wheel",
    "triggers, thoughts, urges, actions, and consequences",
]:
    if needle not in education:
        print(f"FAIL BW-86C1 Recovery Cycle card missing: {needle}")
        sys.exit(1)

for needle in [
    "InkWell(",
    "Educate Me",
    "Tap to open Educate Me",
]:
    if needle not in educate_me:
        print(f"FAIL BW-86C1 Educate Me card missing: {needle}")
        sys.exit(1)

if "OutlinedButton(" in education:
    print("FAIL BW-86C1 old Recovery Cycle button layout remains")
    sys.exit(1)

print("PASS: BW-86C1 Support interaction consistency verified.")
