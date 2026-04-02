from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/main.dart",
    "lib/app/breakwave_app.dart",
    "lib/features/shell/presentation/breakwave_shell.dart",
    "lib/features/home/presentation/home_screen.dart",
    "lib/features/rescue/presentation/rescue_screen.dart",
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/support/presentation/support_screen.dart",
]

EXPECTED_PATTERNS = {
    "lib/main.dart": [
        "BreakWaveApp",
        "runApp(const BreakWaveApp());",
    ],
    "lib/app/breakwave_app.dart": [
        "class BreakWaveApp",
        "MaterialApp(",
        "title: 'BreakWave'",
        "home: const BreakWaveShell()",
    ],
    "lib/features/shell/presentation/breakwave_shell.dart": [
        "class BreakWaveShell",
        "IndexedStack(",
        "NavigationBar(",
        "label: 'Home'",
        "label: 'Rescue'",
        "label: 'Log'",
        "label: 'Support'",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        "class HomeScreen",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "class RescueScreen",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "class LogScreen",
    ],
    "lib/features/support/presentation/support_screen.dart": [
        "class SupportScreen",
        "SupportCategoriesCard()",
        "EmergencyHelpCard()",
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

    print("PASS: BW-01 shell foundation verified.")


if __name__ == "__main__":
    main()
