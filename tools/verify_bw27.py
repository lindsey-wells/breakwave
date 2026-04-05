from pathlib import Path
import sys

checks = [
    ("lib/features/cycle/domain/recovery_cycle_stage.dart", [
        "class RecoveryCycleStage",
        "class RecoveryCycleStages",
        "Trigger",
        "Urge",
        "Escalation",
        "Action",
        "Regret / Recovery",
    ]),
    ("lib/features/cycle/presentation/recovery_cycle_wheel_screen.dart", [
        "class RecoveryCycleWheelScreen",
        "Recovery Cycle Wheel",
        "Learn the wave earlier",
        "What it is",
        "What usually happens here",
        "Interrupt move",
        "ChoiceChip",
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

preview_path = Path("lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart")
if not preview_path.exists():
    print("FAIL missing file: lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart")
    failed = True
else:
    preview_text = preview_path.read_text(encoding="utf-8")
    if "RecoveryCycleWheelScreen" not in preview_text:
        print("FAIL lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart missing: RecoveryCycleWheelScreen")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-27 recovery cycle wheel verified.")
