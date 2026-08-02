from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/support_screen.dart", [
        "class SupportScreen",
        "Support Harbor",
        "Find the right support for this moment.",
    ]),
    ("lib/features/support/presentation/widgets/support_categories_card.dart", [
        "class SupportCategoriesCard",
    ]),
    ("lib/features/support/presentation/widgets/emergency_help_card.dart", [
        "class EmergencyHelpCard",
        "Immediate danger",
        "Call 911 (U.S.)",
        "Outside the United States, use your local emergency number.",
    ]),
    ("lib/features/support/presentation/widgets/support_quick_actions_card.dart", [
        "Text ${_contact!.name}: I’m struggling",
        "Email ${_contact!.name} now",
    ]),
    ("lib/features/support/presentation/widgets/trusted_accountability_card.dart", [
        "class TrustedAccountabilityCard",
        "Trusted Person and Accountability",
        "Text trusted contact",
    ]),
    ("lib/features/support/presentation/widgets/education_resources_card.dart", [
        "class EducationResourcesCard",
        "Education and resources",
        "Educate Me",
        "Open Recovery Cycle Wheel",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL: missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL: missing pattern in {rel_path}: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-05 support foundation verified.")
