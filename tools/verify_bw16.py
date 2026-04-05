from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/domain/rescue_card_content.dart", [
        "class RescueCardContent",
        "calmLine",
        "reframe",
        "immediateAction",
        "nextStep",
    ]),
    ("lib/features/rescue/domain/rescue_card_pack.dart", [
        "class RescueCardPack",
        "starter",
        "slow-down",
        "change-the-room",
        "name-it-plainly",
    ]),
    ("lib/features/rescue/presentation/widgets/rescue_card_engine.dart", [
        "class RescueCardEngine",
        "Calm line",
        "Reframe",
        "Immediate action",
        "Next step",
        "_nextCard()",
        "FilledButton.tonal(",
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

rescue_path = Path("lib/features/rescue/presentation/rescue_screen.dart")
if not rescue_path.exists():
    print("FAIL missing file: lib/features/rescue/presentation/rescue_screen.dart")
    failed = True
else:
    rescue_text = rescue_path.read_text(encoding="utf-8")
    if "RescueCardEngine" not in rescue_text:
        print("FAIL lib/features/rescue/presentation/rescue_screen.dart missing: RescueCardEngine")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-16 rescue card engine verified.")
