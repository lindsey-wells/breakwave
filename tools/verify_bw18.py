from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/domain/secular_rescue_card_pack.dart", [
        "class SecularRescueCardPack",
        "cards = <RescueCardContent>",
        "Slow the first minute",
        "Change the setup",
        "Name the wave clearly",
        "this is an urge, not a decision yet.",
    ]),
    ("lib/features/rescue/presentation/widgets/rescue_card_engine.dart", [
        "RecoveryMode.secular",
        "SecularRescueCardPack.cards",
        "ChristianRescueCardPack.cards",
        "Secular Rescue Card",
        "Show another secular rescue card",
        "Christian Rescue Card",
        "Show another Christian rescue card",
    ]),
    ("lib/features/rescue/domain/christian_rescue_card_pack.dart", [
        "class ChristianRescueCardPack",
        "cards = <RescueCardContent>",
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

if failed:
    sys.exit(1)

print("PASS: BW-18 secular rescue pack verified.")
