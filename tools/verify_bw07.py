from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "pubspec.yaml",
    "lib/core/storage/storage_keys.dart",
    "lib/features/log/domain/log_entry.dart",
    "lib/features/log/data/log_repository.dart",
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/log/presentation/widgets/log_save_card.dart",
]

EXPECTED_PATTERNS = {
    "pubspec.yaml": [
        "shared_preferences:",
    ],
    "lib/core/storage/storage_keys.dart": [
        "class BreakWaveStorageKeys",
        "logEntries",
    ],
    "lib/features/log/domain/log_entry.dart": [
        "class LogEntry",
        "toMap()",
        "factory LogEntry.fromMap",
        "createdAtIso",
    ],
    "lib/features/log/data/log_repository.dart": [
        "class LogRepository",
        "SharedPreferences.getInstance()",
        "loadEntries()",
        "saveEntry(LogEntry entry)",
        "entryCount()",
        "BreakWaveStorageKeys.logEntries",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "final LogRepository _repository = const LogRepository();",
        "Future<void> _refreshFromStorage() async",
        "Future<void> _saveEntry() async",
        "LogEntry(",
        "await _repository.saveEntry(entry);",
        "Saved locally on this device:",
    ],
    "lib/features/log/presentation/widgets/log_save_card.dart": [
        "savedEntryCount",
        "isSaving",
        "Saving...",
        "Save log entry",
        "Saved locally on this device:",
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

        if rel_path.endswith(".dart") and HEADER_TOKEN not in content:
            fail(f"missing Cube23 header in: {rel_path}")

        for pattern in EXPECTED_PATTERNS.get(rel_path, []):
            if pattern not in content:
                fail(f"missing pattern in {rel_path}: {pattern}")

    print("PASS: BW-07 persistence foundation verified.")


if __name__ == "__main__":
    main()
