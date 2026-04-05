from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/support_screen.dart", [
        "class SupportScreen",
        "Support Harbor",
        "Support makes the wave smaller.",
    ]),
    ("lib/features/support/presentation/widgets/support_categories_card.dart", [
        "class SupportCategoriesCard",
    ]),
    ("lib/features/support/presentation/widgets/emergency_help_card.dart", [
        "class EmergencyHelpCard",
        "Emergency Help",
        "Call emergency services",
        "Text trusted contact now",
    ]),
    ("lib/features/support/presentation/widgets/trusted_accountability_card.dart", [
        "class TrustedAccountabilityCard",
        "Trusted Person and Accountability",
        "Text trusted contact",
    ]),
    ("lib/features/support/presentation/widgets/education_resources_card.dart", [
        "class EducationResourcesCard",
        "Education and resources",
        "Open Educate Me",
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
