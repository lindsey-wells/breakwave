from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/shell/presentation/breakwave_shell.dart",
    "lib/features/log/data/log_repository.dart",
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart",
    "lib/features/rescue/presentation/rescue_screen.dart",
    "lib/features/rescue/presentation/widgets/wave_completion_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/shell/presentation/breakwave_shell.dart": [
        "void _returnHome()",
        "RescueScreen(",
        "onReturnHome: _returnHome",
        "LogScreen(",
    ],
    "lib/features/log/data/log_repository.dart": [
        "Future<void> updateEntry(LogEntry entry)",
        "Future<void> deleteEntry(String id)",
    ],
    "lib/features/log/presentation/log_screen.dart": [
        "final VoidCallback onReturnHome;",
        "String? _editingEntryId;",
        "void _populateDraftFromEntry(LogEntry entry)",
        "await _repository.updateEntry(entry);",
        "await _repository.deleteEntry(entry.id);",
        "widget.onReturnHome();",
        "Editing a saved entry",
    ],
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart": [
        "final ValueChanged<LogEntry> onEdit;",
        "final ValueChanged<LogEntry> onDelete;",
        "OutlinedButton.icon(",
        "Edit",
        "Delete",
    ],
    "lib/features/rescue/presentation/rescue_screen.dart": [
        "final VoidCallback onReturnHome;",
        "Future<void> _completeWave() async",
        "entryType: 'Victory'",
        "widget.onReturnHome();",
        "WaveCompletionCard(",
    ],
    "lib/features/rescue/presentation/widgets/wave_completion_card.dart": [
        "final Future<void> Function() onComplete;",
        "onPressed: () => onComplete()",
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

    print("PASS: BW-10 edit/delete logs and return-home flow verified.")


if __name__ == "__main__":
    main()
