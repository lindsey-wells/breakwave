from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/core/theme/breakwave_colors.dart",
    "lib/core/theme/breakwave_theme.dart",
    "lib/core/ui/wave_surface.dart",
    "lib/app/breakwave_app.dart",
    "lib/features/home/presentation/home_screen.dart",
    "lib/features/rescue/presentation/rescue_screen.dart",
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/support/presentation/support_screen.dart",
]

EXPECTED_PATTERNS = {
    "lib/core/theme/breakwave_colors.dart": [
        "class BreakWaveColors",
        "navyDeep",
        "oceanDeep",
        "waveBlue",
        "crestBlue",
        "foamBlue",
    ],
    "lib/core/theme/breakwave_theme.dart": [
        "class BreakWaveTheme",
        "ColorScheme.dark(",
        "BreakWaveColors.crestBlue",
        "NavigationBarThemeData(",
        "FilledButtonThemeData(",
    ],
    "lib/core/ui/wave_surface.dart": [
        "class WaveSurface",
        "LinearGradient(",
        "Color(0xFF163F69)",
        "BreakWaveColors.waveBlue",
    ],
    "lib/app/breakwave_app.dart": [
        "BreakWaveTheme.dark()",
        "themeMode: ThemeMode.dark",
    ],
    "lib/features/home/presentation/home_screen.dart": [
        "WaveSurface(",
        "Home Current",
        "Steady water, clear direction.",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "WaveSurface(",
        "Rescue Tide",
        "Slow the surge. Ride the wave.",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "WaveSurface(",
        "Pattern Log",
        "Turn blur into something visible.",
    ],
    "lib/features/support/presentation/support_screen.dart": [
        "WaveSurface(",
        "Support Harbor",
        "Support makes the wave smaller.",
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

    print("PASS: BW-06 blue theme system and wave motif verified.")


if __name__ == "__main__":
    main()
