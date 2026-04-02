from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/core/theme/breakwave_colors.dart",
    "lib/core/theme/breakwave_theme.dart",
    "lib/features/rescue/presentation/widgets/urge_intensity_section.dart",
    "lib/features/log/presentation/widgets/log_entry_type_section.dart",
    "lib/features/log/presentation/widgets/log_intensity_section.dart",
    "lib/features/log/presentation/widgets/log_trigger_chips_section.dart",
]

EXPECTED_PATTERNS = {
    "lib/core/theme/breakwave_colors.dart": [
        "chipIdle",
        "chipSelected",
        "chipSelectedBorder",
        "chipSelectedGlow",
        "navIndicator",
        "navIndicatorBorder",
    ],
    "lib/core/theme/breakwave_theme.dart": [
        "BreakWaveColors.chipSelected",
        "BreakWaveColors.navIndicator",
        "FontWeight.w800",
        "IconThemeData(",
    ],
    "lib/features/rescue/presentation/widgets/urge_intensity_section.dart": [
        "BreakWaveColors.chipSelected",
        "BreakWaveColors.chipSelectedBorder",
        "showCheckmark: true",
        "elevation: isSelected ? 3 : 0",
    ],
    "lib/features/log/presentation/widgets/log_entry_type_section.dart": [
        "BreakWaveColors.chipSelected",
        "BreakWaveColors.chipSelectedBorder",
        "showCheckmark: true",
        "FontWeight.w800",
    ],
    "lib/features/log/presentation/widgets/log_intensity_section.dart": [
        "BreakWaveColors.chipSelected",
        "BreakWaveColors.chipSelectedBorder",
        "showCheckmark: true",
        "FontWeight.w800",
    ],
    "lib/features/log/presentation/widgets/log_trigger_chips_section.dart": [
        "BreakWaveColors.chipSelected",
        "BreakWaveColors.chipSelectedBorder",
        "showCheckmark: true",
        "FontWeight.w800",
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

    print("PASS: BW-06A selected-state contrast polish verified.")


if __name__ == "__main__":
    main()
