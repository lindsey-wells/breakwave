from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/log/presentation/log_screen.dart": [
        "List<LogEntry> _recentEntries = const <LogEntry>[];",
        "Future<void> _refreshFromStorage() async",
        "_recentEntries = entries.take(5).toList();",
        "RecentLogEntriesCard(",
        "entries: _recentEntries",
    ],
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart": [
        "class RecentLogEntriesCard",
        "Recent Entries",
        "No saved entries yet.",
        "Intensity ",
        "Triggers: ",
        "_formatTimestamp",
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

    print("PASS: BW-08 recent log history surface verified.")


if __name__ == "__main__":
    main()
