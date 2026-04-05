from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/domain/christian_rescue_card_pack.dart", [
        "class ChristianRescueCardPack",
        "cards = <RescueCardContent>",
        "Grace first, not panic",
        "Lord, help me obey You in the next minute.",
        "Step into the light",
        "Interrupt the pattern",
    ]),
    ("lib/features/rescue/presentation/widgets/rescue_card_engine.dart", [
        "RecoveryModeStore.loadMode()",
        "RecoveryMode.christian",
        "ChristianRescueCardPack.cards",
        "RescueCardPack.starter",
        "Christian Rescue Card",
        "Show another Christian rescue card",
    ]),
    ("lib/features/rescue/domain/rescue_card_pack.dart", [
        "class RescueCardPack",
        "starter",
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

print("PASS: BW-17 Christian rescue pack verified.")
