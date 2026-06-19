from pathlib import Path
import sys

checks = [
    ("lib/features/log/presentation/widgets/log_cbt_reflection_card.dart", [
        "BW-72C keeps the replacement action visible",
        "Next better move",
        "Choose the clean action you want to take next.",
        "Healthy replacement action",
        "Other replacement action",
        "ExpansionTile",
        "Add reflection details",
        "Optional: Trigger → Thought → Urge → Action",
        "Name the thought, then choose the next better move.",
        "Thought before the urge",
        "Action taken",
        "Consequence / what happened next",
        "Better plan for next time",
    ]),
    ("lib/features/log/presentation/widgets/log_notes_card.dart", [
        "BW-72C collapses optional notes",
        "ExpansionTile",
        "Optional notes",
        "Add a few honest words only if they help.",
        "Add a few honest words about what happened",
        "Example: hit a rough patch after work",
    ]),
    ("launch/log_optional_details_collapse.md", [
        "BW-72C Log Optional Details Collapse",
        "deeper reflection optional",
        "Healthy Replacement Action visible",
        "Add reflection details",
        "fast truth capture first",
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

cbt = Path("lib/features/log/presentation/widgets/log_cbt_reflection_card.dart").read_text(encoding="utf-8")
healthy_index = cbt.find("Healthy replacement action")
reflection_index = cbt.find("Add reflection details")
thought_index = cbt.find("Thought before the urge")

if healthy_index == -1 or reflection_index == -1 or thought_index == -1:
    print("FAIL order anchors missing in LogCbtReflectionCard")
    failed = True
elif not (healthy_index < reflection_index < thought_index):
    print("FAIL Healthy replacement action should stay visible before optional reflection fields")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-72C Log optional details collapse verified.")
