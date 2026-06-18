from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/log_screen.dart", [
        "BW-72B declutters Log capture",
        "late final TextEditingController _otherTriggerController;",
        "late final TextEditingController _otherReplacementActionController;",
        "static const String _otherLabel = 'Other';",
        "'Move to public space'",
        "'Charge phone away from bed'",
        "'Journal one line'",
        "'Pray for one minute'",
        "List<String> _resolvedTriggers()",
        "String _resolvedReplacementAction()",
        "Other: $customTrigger",
        "replacementActionForSave",
        "showOtherTriggerField:",
        "showOtherReplacementField:",
    ]),
    ("lib/features/log/presentation/widgets/log_entry_type_section.dart", [
        "BW-72B shortens Log copy",
        "What happened?",
        "Pick the closest match.",
        "Urge",
        "Slip",
        "Victory",
    ]),
    ("lib/features/log/presentation/widgets/log_intensity_section.dart", [
        "BW-72B shortens intensity copy",
        "How strong was it?",
        "1 Light",
        "5 Extreme",
    ]),
    ("lib/features/log/presentation/widgets/log_trigger_chips_section.dart", [
        "BW-72B adds lightweight Other trigger capture",
        "otherTriggerController",
        "showOtherTriggerField",
        "Other trigger",
        "What was happening?",
    ]),
    ("lib/features/log/presentation/widgets/log_cbt_reflection_card.dart", [
        "BW-72B keeps CBT logging lightweight",
        "Name the thought, then choose the next better move.",
        "Other replacement action",
        "otherReplacementActionController",
        "showOtherReplacementField",
        "Healthy replacement action",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "BW-72B makes recent entries compact",
        "Newest saved moments. Open details only when you need them.",
        "ExpansionTile",
        "Show details",
        "Replacement action: ${entry.replacementAction.trim()}",
        "Thought: ${entry.thought.trim()}",
        "Action: ${entry.actionTaken.trim()}",
        "Better plan: ${entry.betterPlan.trim()}",
    ]),
    ("launch/log_declutter_other_capture.md", [
        "BW-72B Log Declutter + Other Capture",
        "Adds Other trigger capture",
        "Adds Other replacement action capture",
        "Compacts Recent Entries",
        "fast truth capture",
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

screen = Path("lib/features/log/presentation/log_screen.dart").read_text(encoding="utf-8")
order = [
    ("LogEntryTypeSection", screen.find("LogEntryTypeSection(")),
    ("LogIntensitySection", screen.find("LogIntensitySection(")),
    ("LogTriggerChipsSection", screen.find("LogTriggerChipsSection(")),
    ("LogCbtReflectionCard", screen.find("LogCbtReflectionCard(")),
    ("LogNotesCard", screen.find("LogNotesCard(")),
    ("LogSaveCard", screen.find("LogSaveCard(")),
    ("RecentLogEntriesCard", screen.find("RecentLogEntriesCard(")),
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

if failed:
    sys.exit(1)

print("PASS: BW-72B Log declutter and Other capture verified.")
