from pathlib import Path
import sys

checks = [
    ("launch/log_final_qa.md", [
        "BW-85A Log Final QA",
        "Rescue-saved Victory / Urge / Slip entries appear in Log.",
        "Custom Other triggers save inside entries as entry text, not permanent visible buttons.",
        "Users can switch between latest 5 and all saved entries.",
        "Edit opens the main Log form in Update Mode.",
        "Updated entries are highlighted with a blue visual treatment.",
        "Updated entries show the label “Updated just now.”",
        "Delete shows a brief undo snackbar.",
    ]),
    ("lib/features/log/presentation/log_screen.dart", [
        "Notes: BW-84A improves Log review scope, edit clarity, and delete undo timing.",
        "Notes: BW-84C adds a top-of-page Update Mode banner for edit clarity.",
        "Notes: BW-84D highlights the most recently updated log entry.",
        "bool _showAllEntries = false;",
        "int _deleteSnackBarSerial = 0;",
        "String? _recentlyUpdatedEntryId;",
        "final bool nextShowAllEntries = !_showAllEntries;",
        "_recentEntries = nextShowAllEntries ? entries : entries.take(5).toList();",
        "Update Mode",
        "Cancel edit",
        "Deleted log entry. Undo available briefly.",
        "duration: const Duration(seconds: 4)",
        "_recentlyUpdatedEntryId = editingId;",
        "highlightedEntryId: _recentlyUpdatedEntryId,",
    ]),
    ("lib/features/log/presentation/widgets/log_save_card.dart", [
        "Notes: BW-84B makes editing mode visible near the save/update action.",
        "final VoidCallback onCancelEdit;",
        "Update Entry",
        "Editing saved entry",
        "Cancel edit",
        "onPressed: onCancelEdit",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "Notes: BW-84A adds Show all / Show latest review controls.",
        "Notes: BW-84D highlights the most recently updated entry.",
        "final String? highlightedEntryId;",
        "Showing all $totalEntryCount saved entries.",
        "Showing latest $visibleCount of $totalEntryCount saved entries.",
        "Show all entries",
        "Show latest 5",
        "Keep scrolling to review older saved entries.",
        "Updated just now",
        "isHighlighted: entry.id == highlightedEntryId",
    ]),
    ("lib/features/log/data/log_repository.dart", [
        "Future<List<LogEntry>> loadEntries() async",
        "Future<void> saveEntry(LogEntry entry) async",
        "Future<void> updateEntry(LogEntry entry) async",
        "Future<void> deleteEntry(String id) async",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "entryType: 'Victory'",
        "entryType: 'Urge'",
        "entryType: 'Slip'",
        "replacementAction: nextAction ?? ''",
        "Wave saved. You made it through this wave.",
    ]),
]

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL BW-85A missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-85A {rel_path} missing: {needle}")
            sys.exit(1)

for rel_path in [
    "lib/features/log/presentation/log_screen.dart",
    "lib/features/log/presentation/widgets/log_save_card.dart",
    "lib/features/log/presentation/widgets/recent_log_entries_card.dart",
]:
    text = Path(rel_path).read_text(encoding="utf-8")
    if "onPressed: () {}" in text:
        print(f"FAIL BW-85A dead button callback in {rel_path}")
        sys.exit(1)

print("PASS: BW-85A Log final QA marker verified.")
