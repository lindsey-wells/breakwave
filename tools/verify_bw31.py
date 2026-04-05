from pathlib import Path
import sys

checks = [
    ("lib/core/recovery/recovery_mode.dart", [
        "Practical support without religious language.",
        "Recovery support with prayer, Scripture, and clearly Christian language rooted in grace and truth.",
    ]),
    ("lib/features/recovery_mode/recovery_mode_screen.dart", [
        "Choose how BreakWave should speak to you when the wave rises.",
        "grace, truth, prayer, and Scripture",
    ]),
    ("lib/features/home/presentation/widgets/bedtime_danger_mode_card.dart", [
        "Bring the wave into the open early instead of facing it alone in the dark.",
        "Reduce isolation, reduce privacy, and interrupt the pattern before it gains momentum.",
    ]),
    ("lib/features/faith/presentation/faith_depth_pack_screen.dart", [
        "grace-forward Christian reflection",
        "deeper transformation layer inside BreakWave Plus",
        "Switch BreakWave to the Christian recovery path to use the full content as written.",
    ]),
    ("lib/features/learn/presentation/educate_me_screen.dart", [
        "Keep this short and useful.",
        "understand the pattern sooner so you can interrupt it faster in real life.",
    ]),
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "does not gate immediate relief",
        "deeper tools for planning, insight, accountability, and long-term growth",
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

print("PASS: BW-31 copy and theology audit verified.")
