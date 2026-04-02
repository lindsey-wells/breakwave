from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/log/presentation/widgets/log_entry_type_section.dart",
    "lib/features/log/presentation/widgets/log_intensity_section.dart",
    "lib/features/log/presentation/widgets/log_trigger_chips_section.dart",
    "lib/features/log/presentation/widgets/log_notes_card.dart",
    "lib/features/log/presentation/widgets/log_save_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/log/presentation/log_screen.dart": [
        "class LogScreen",
        "StatefulWidget",
        "LogEntryTypeSection(",
        "LogIntensitySection(",
        "LogTriggerChipsSection(",
        "LogNotesCard(",
        "LogSaveCard(",
        "Saved ",
        "'Stress'",
        "'Environment'",
    ],
    "lib/features/log/presentation/widgets/log_entry_type_section.dart": [
        "class LogEntryTypeSection",
        "Entry Type",
        "Urge",
        "Slip",
        "Victory",
    ],
    "lib/features/log/presentation/widgets/log_intensity_section.dart": [
        "class LogIntensitySection",
        "Intensity",
        "1 Light",
        "5 Extreme",
    ],
    "lib/features/log/presentation/widgets/log_trigger_chips_section.dart": [
        "class LogTriggerChipsSection",
        "Trigger Signals",
        "availableTriggers.map",
        "FilterChip(",
    ],
    "lib/features/log/presentation/widgets/log_notes_card.dart": [
        "class LogNotesCard",
        "Notes",
        "TextField(",
    ],
    "lib/features/log/presentation/widgets/log_save_card.dart": [
        "class LogSaveCard",
        "Save Entry",
        "Save log entry",
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

    print("PASS: BW-04 log foundation verified.")


if __name__ == "__main__":
    main()
