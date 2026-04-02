from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/support/presentation/support_screen.dart",
    "lib/features/support/presentation/widgets/support_categories_card.dart",
    "lib/features/support/presentation/widgets/emergency_help_card.dart",
    "lib/features/support/presentation/widgets/trusted_accountability_card.dart",
    "lib/features/support/presentation/widgets/education_resources_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/support/presentation/support_screen.dart": [
        "class SupportScreen",
        "SupportCategoriesCard()",
        "EmergencyHelpCard()",
        "TrustedAccountabilityCard()",
        "EducationResourcesCard()",
        "Support makes the wave smaller.",
    ],
    "lib/features/support/presentation/widgets/support_categories_card.dart": [
        "class SupportCategoriesCard",
        "Support Categories",
        "Immediate Support",
        "Accountability",
        "Education",
    ],
    "lib/features/support/presentation/widgets/emergency_help_card.dart": [
        "class EmergencyHelpCard",
        "Emergency Help",
        "Call emergency services",
        "Emergency tools placeholder",
    ],
    "lib/features/support/presentation/widgets/trusted_accountability_card.dart": [
        "class TrustedAccountabilityCard",
        "Trusted Person and Accountability",
        "quick contact",
        "Accountability tools placeholder",
    ],
    "lib/features/support/presentation/widgets/education_resources_card.dart": [
        "class EducationResourcesCard",
        "Education and Resources",
        "urge-surfing guidance",
        "Resource library placeholder",
    ],
}

HEADER_TOKEN = "Cube23 Collaboration Header"


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def main() -> None:
    for rel_path in EXPECTED_FILES:
        path = ROOT / rel_path
        if not path.exists():
            fail(f"missing file: {rel_path}")

        content = path.read_text(encoding="utf-8")

        if HEADER_TOKEN not in content:
            fail(f"missing Cube23 header in: {rel_path}")

        for pattern in EXPECTED_PATTERNS.get(rel_path, []):
            if pattern not in content:
                fail(f"missing pattern in {rel_path}: {pattern}")

    print("PASS: BW-05 support foundation verified.")


if __name__ == "__main__":
    main()
