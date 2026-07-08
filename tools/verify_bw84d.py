from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/log_screen.dart", [
        "Notes: BW-84D highlights the most recently updated log entry.",
        "String? _recentlyUpdatedEntryId;",
        "_recentlyUpdatedEntryId = null;",
        "_recentlyUpdatedEntryId = editingId;",
        "highlightedEntryId: _recentlyUpdatedEntryId,",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "Notes: BW-84D highlights the most recently updated entry.",
        "final String? highlightedEntryId;",
        "required this.highlightedEntryId,",
        "isHighlighted: entry.id == highlightedEntryId",
        "final bool isHighlighted;",
        "color: backgroundColor,",
        "width: isHighlighted ? 1.4 : 1",
        "Updated just now",
        "Icons.check_circle_outline",
        "Show all entries",
        "Show latest 5",
    ]),
]

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL BW-84D missing file: {rel_path}")
        sys.exit(1)

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL BW-84D {rel_path} missing: {needle}")
            sys.exit(1)

screen_text = Path("lib/features/log/presentation/log_screen.dart").read_text(encoding="utf-8")
recent_text = Path("lib/features/log/presentation/widgets/recent_log_entries_card.dart").read_text(encoding="utf-8")

if "onPressed: () {}" in screen_text or "onPressed: () {}" in recent_text:
    print("FAIL BW-84D introduced a dead button callback")
    sys.exit(1)

print("PASS: BW-84D updated Log entry highlight verified.")
