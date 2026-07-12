from pathlib import Path
import sys

checks = [
    ("lib/features/faith/domain/faith_depth_content.dart", [
        "class FaithDepthContent",
        "anchor",
        "reflection",
        "practice",
        "prayer",
    ]),
    ("lib/features/faith/domain/faith_depth_pack.dart", [
        "class FaithDepthPack",
        "Shame",
        "Secrecy",
        "Loneliness",
        "Rebuilding integrity",
    ]),
    ("lib/features/faith/presentation/faith_depth_pack_screen.dart", [
        "class FaithDepthPackScreen",
        "BreakWave Plus Christian depth",
        "Locked in BreakWave Plus",
        "Christian mode required",
        "BreakWavePlusScreen",
        "RecoveryMode.christian",
        "Anchor",
        "Reflection",
        "Practice",
        "Prayer",
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

support_path = Path(
    "lib/features/support/presentation/support_screen.dart"
)

if not support_path.exists():
    print("FAIL missing Support screen")
    failed = True
else:
    support_text = support_path.read_text(encoding="utf-8")

    for forbidden in [
        "title: 'Faith depth pack'",
        "FaithDepthPackScreen",
    ]:
        if forbidden in support_text:
            print(f"FAIL Support still advertises thin paid faith content: {forbidden}")
            failed = True

if failed:
    sys.exit(1)

print("PASS: BW-26 faith depth foundation verified.")
