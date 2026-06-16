from pathlib import Path
import sys

path = Path("lib/features/log/presentation/log_screen.dart")
text = path.read_text(encoding="utf-8")

checks = [
    "late final ScrollController _scrollController;",
    "_scrollController = ScrollController();",
    "_scrollController.dispose();",
    "controller: _scrollController",
    "EdgeInsets.fromLTRB(20, 20, 20, 150)",
    "_scrollController.animateTo(",
    "LogEntryTypeSection(",
    "LogIntensitySection(",
    "LogTriggerChipsSection(",
    "LogCbtReflectionCard(",
    "LogNotesCard(",
    "LogSaveCard(",
    "RecentLogEntriesCard(",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL {path} missing: {needle}")
        failed = True

order = [
    ("LogEntryTypeSection", text.find("LogEntryTypeSection(")),
    ("LogIntensitySection", text.find("LogIntensitySection(")),
    ("LogTriggerChipsSection", text.find("LogTriggerChipsSection(")),
    ("LogCbtReflectionCard", text.find("LogCbtReflectionCard(")),
    ("LogNotesCard", text.find("LogNotesCard(")),
    ("LogSaveCard", text.find("LogSaveCard(")),
    ("RecentLogEntriesCard", text.find("RecentLogEntriesCard(")),
]

for label, index in order:
    if index == -1:
        print(f"FAIL order anchor missing: {label}")
        failed = True

if not failed:
    for (left_label, left_index), (right_label, right_index) in zip(order, order[1:]):
        if left_index > right_index:
            print(f"FAIL order issue: {left_label} should appear before {right_label}")
            failed = True

launch = Path("launch/log_capture_order_polish.md")
if not launch.exists():
    print("FAIL missing launch/log_capture_order_polish.md")
    failed = True
else:
    launch_text = launch.read_text(encoding="utf-8")
    for needle in [
        "BW-72A Log Capture Order Polish",
        "prioritize fast truth capture",
        "Moves the manual log form above Recent Entries",
        "Does not change the log data model",
    ]:
        if needle not in launch_text:
            print(f"FAIL launch/log_capture_order_polish.md missing: {needle}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-72A Log capture order polish verified.")
