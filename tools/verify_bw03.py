from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/rescue/presentation/rescue_screen.dart",
    "lib/features/rescue/presentation/widgets/urge_intensity_section.dart",
    "lib/features/rescue/presentation/widgets/calm_reset_card.dart",
    "lib/features/rescue/presentation/widgets/redirect_actions_card.dart",
    "lib/features/rescue/presentation/widgets/wave_completion_card.dart",
    "lib/features/rescue/presentation/widgets/support_escalation_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "class RescueScreen",
        "StatefulWidget",
        "UrgeIntensitySection(",
        "CalmResetCard()",
        "RedirectActionsCard()",
        "WaveCompletionCard(",
        "SupportEscalationCard()",
        "Current intensity:",
    ],
    "lib/features/rescue/presentation/widgets/urge_intensity_section.dart": [
        "class UrgeIntensitySection",
        "Urge Intensity",
        "1 Low",
        "5 Critical",
    ],
    "lib/features/rescue/presentation/widgets/calm_reset_card.dart": [
        "class CalmResetCard",
        "Calm Reset",
        "Start reset",
    ],
    "lib/features/rescue/presentation/widgets/redirect_actions_card.dart": [
        "class RedirectActionsCard",
        "Fast Redirect Actions",
        "Put the phone down",
        "Leave the room",
    ],
    "lib/features/rescue/presentation/widgets/wave_completion_card.dart": [
        "class WaveCompletionCard",
        "Wave Completion",
        "I made it through this wave",
    ],
    "lib/features/rescue/presentation/widgets/support_escalation_card.dart": [
        "class SupportEscalationCard",
        "Support and Escalation",
        "trusted person",
        "Support tools expanding soon",
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

    print("PASS: BW-03 rescue foundation verified.")


if __name__ == "__main__":
    main()
