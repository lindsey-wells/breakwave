from pathlib import Path
import sys

checks = [
    ("lib/features/log/domain/log_entry.dart", [
        "Purpose: BW-63 CBT-informed log entry model.",
        "final String thought;",
        "final String actionTaken;",
        "final String consequence;",
        "final String betterPlan;",
        "final String replacementAction;",
        "'thought': thought",
        "'actionTaken': actionTaken",
        "'consequence': consequence",
        "'betterPlan': betterPlan",
        "'replacementAction': replacementAction",
        "thought: _stringValue(map, 'thought')",
        "actionTaken: _stringValue(map, 'actionTaken')",
        "consequence: _stringValue(map, 'consequence')",
        "betterPlan: _stringValue(map, 'betterPlan')",
        "replacementAction: _stringValue(map, 'replacementAction')",
    ]),
    ("lib/features/log/presentation/widgets/log_cbt_reflection_card.dart", [
        "class LogCbtReflectionCard",
        "Trigger → Thought → Urge → Action",
        "Thought before the urge",
        "Healthy replacement action",
        "Action taken",
        "Consequence / what happened next",
        "Better plan for next time",
        "ChoiceChip",
    ]),
    ("lib/features/log/presentation/log_screen.dart", [
        "LogCbtReflectionCard",
        "_thoughtController",
        "_actionTakenController",
        "_consequenceController",
        "_betterPlanController",
        "_selectedReplacementAction",
        "_healthyReplacementActions",
        "thought: _thoughtController.text.trim()",
        "actionTaken: _actionTakenController.text.trim()",
        "consequence: _consequenceController.text.trim()",
        "betterPlan: _betterPlanController.text.trim()",
        "replacementAction: replacementActionForSave",
    ]),
    ("lib/features/log/presentation/widgets/recent_log_entries_card.dart", [
        "Thought: ${entry.thought.trim()}",
        "Replacement action: ${entry.replacementAction.trim()}",
        "Action: ${entry.actionTaken.trim()}",
        "Consequence: ${entry.consequence.trim()}",
        "Better plan: ${entry.betterPlan.trim()}",
    ]),
    ("launch/cbt_log_upgrade.md", [
        "CBT-Informed Log Upgrade",
        "Trigger → Thought → Urge → Action → Consequence → Better Plan",
        "Thought before the urge",
        "Healthy replacement action",
        "not therapy",
        "fast honesty",
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

# Make sure older required constructor calls will still compile.
entry_text = Path("lib/features/log/domain/log_entry.dart").read_text(encoding="utf-8")
for optional_field in [
    "this.thought = ''",
    "this.actionTaken = ''",
    "this.consequence = ''",
    "this.betterPlan = ''",
    "this.replacementAction = ''",
]:
    if optional_field not in entry_text:
        print(f"FAIL LogEntry field is not backward-compatible optional: {optional_field}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-63 CBT-informed log upgrade verified.")
