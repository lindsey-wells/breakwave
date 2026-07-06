from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/log_screen.dart", [
        "Notes: BW-84A improves Log review scope, edit clarity, and delete undo timing.",
        "bool _showAllEntries = false;",
        "List<LogEntry> _visibleEntries(List<LogEntry> entries)",
        "Future<void> _toggleShowAllEntries() async",
        "void _cancelEdit()",
        "Widget _buildEditingStatusBanner(BuildContext context)",
        "Editing saved entry",
        "Changes will update this saved log entry instead of creating a new one.",
        "Cancel edit",
        "Deleted log entry. Undo available briefly.",
        "duration: const Duration(seconds: 4)",
        "totalEntryCount: _savedEntryCount",
        "showAllEntries: _showAllEntries",
        "onToggleShowAll: _toggleShowAllEntries",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "Notes: BW-84A adds Show all / Show latest review controls.",
        "final int totalEntryCount;",
        "final bool showAllEntries;",
        "final VoidCallback onToggleShowAll;",
        "Showing all $totalEntryCount saved entries.",
        "Showing latest $visibleCount of $totalEntryCount saved entries.",
        "Show latest 5",
        "Show all entries",
    ]),
]

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL BW-84A missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-84A {rel_path} missing: {needle}")
            sys.exit(1)

log_text = Path("lib/features/log/presentation/log_screen.dart").read_text(encoding="utf-8")
recent_text = Path("lib/features/log/presentation/widgets/recent_log_entries_card.dart").read_text(encoding="utf-8")

if "duration: const Duration(seconds: 5)" in log_text:
    print("FAIL BW-84A old delete undo duration remains")
    sys.exit(1)

if "Editing a saved entry'," in log_text and "Editing saved entry" not in log_text:
    print("FAIL BW-84A weak edit indicator remains without banner")
    sys.exit(1)

if "onPressed: () {}" in log_text or "onPressed: () {}" in recent_text:
    print("FAIL BW-84A introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-84A Log review/edit clarity verified.")
