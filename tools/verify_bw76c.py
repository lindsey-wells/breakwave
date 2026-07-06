from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/log_screen.dart", [
        "BW-76C adds undo for accidental recent-log deletion.",
        "Future<void> _undoDeleteEntry(LogEntry entry) async",
        "await _repository.saveEntry(entry);",
        "Restored log entry.",
        "Future<void> _deleteEntry(LogEntry entry) async",
        "await _repository.deleteEntry(entry.id);",
        "hideCurrentSnackBar()",
        "Deleted log entry. Undo available briefly.",
        "duration: const Duration(seconds: 4)",
        "SnackBarAction(",
        "label: 'Undo'",
        "onPressed: () => _undoDeleteEntry(entry)",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "final ValueChanged<LogEntry> onDelete;",
        "onDelete: () => onDelete(entry)",
        "Delete",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-76C log delete undo verified.")
