from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/app/breakwave_app.dart",
    "lib/features/shell/presentation/breakwave_shell.dart",
    "lib/features/home/presentation/home_screen.dart",
    "lib/features/home/presentation/widgets/fast_urge_entry_card.dart",
    "lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart",
    "lib/features/home/presentation/widgets/daily_encouragement_card.dart",
]

HEADER_TOKEN = "Cube23 Collaboration Header"

STRING_PATTERNS = {
    "lib/app/breakwave_app.dart": [
        "class BreakWaveApp",
        "BreakWaveTheme.dark()",
        "themeMode: ThemeMode.dark",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        "class HomeScreen",
        "final VoidCallback onOpenRescue;",
        "final VoidCallback onOpenRescue;",
        "FastUrgeEntryCard(",
        "RecoveryCyclePreviewCard()",
        "DailyEncouragementCard()",
        "SingleChildScrollView(",
    ],
    "lib/features/home/presentation/widgets/fast_urge_entry_card.dart": [
        "class FastUrgeEntryCard",
        "Log the wave fast and move straight into Rescue.",
        "I feel the wave now",
        "Log urge and open Rescue",
    ],
    "lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart": [
        "class RecoveryCyclePreviewCard",
        "Recovery cycle wheel",
        "Trigger",
        "Urge",
        "Trigger → Urge → Escalation → Action → Regret / Recovery",
    ],
    "lib/features/home/presentation/widgets/daily_encouragement_card.dart": [
        "class DailyEncouragementCard",
        "Daily Encouragement",
        "An urge is a wave, not a command.",
    ],
}

REGEX_PATTERNS = {
    "lib/features/shell/presentation/breakwave_shell.dart": [
        r"class\s+BreakWaveShell",
        r"HomeScreen\s*\(",
        r"onOpenRescue\s*:",
        r"_onDestinationSelected\s*\(\s*1\s*\)",
        r"onOpenRescue\s*:",
        r"_onDestinationSelected\s*\(\s*2\s*\)",
        r"IndexedStack\s*\(",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        r"onOpenRescue\s*:\s*(widget\.)?onOpenRescue",
        r"onOpenRescue\s*:\s*(widget\.)?onOpenRescue",
    ],
}


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

        for pattern in STRING_PATTERNS.get(rel_path, []):
            if pattern not in content:
                fail(f"missing pattern in {rel_path}: {pattern}")

        for pattern in REGEX_PATTERNS.get(rel_path, []):
            if not re.search(pattern, content, flags=re.MULTILINE | re.DOTALL):
                fail(f"missing regex pattern in {rel_path}: {pattern}")

    print("PASS: BW-02 home structure and dark theme verified.")


if __name__ == "__main__":
    main()
