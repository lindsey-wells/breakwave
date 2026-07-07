from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/log_screen.dart", [
        "int _deleteSnackBarSerial = 0;",
        "final bool nextShowAllEntries = !_showAllEntries;",
        "_recentEntries = nextShowAllEntries ? entries : entries.take(5).toList();",
        "final int snackBarSerial = _deleteSnackBarSerial;",
        "Future<void>.delayed(const Duration(seconds: 4), () {",
        "ScaffoldMessenger.of(context).hideCurrentSnackBar();",
        "onCancelEdit: _cancelEdit",
    ]),
    ("lib/features/log/presentation/widgets/log_save_card.dart", [
        "Notes: BW-84B makes editing mode visible near the save/update action.",
        "final VoidCallback onCancelEdit;",
        "Editing saved entry",
        "Changes will update this saved log entry instead of creating a new one.",
        "Cancel edit",
        "onPressed: onCancelEdit",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "Showing all $totalEntryCount saved entries.",
        "Showing latest $visibleCount of $totalEntryCount saved entries.",
        "Keep scrolling to review older saved entries.",
        "Show latest 5",
        "Show all entries",
    ]),
]

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL BW-84B missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-84B {rel_path} missing: {needle}")
            sys.exit(1)

print("PASS: BW-84B Log review controls and edit banner verified.")
