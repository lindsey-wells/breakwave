from pathlib import Path
import sys

checks = [
    ("lib/core/premium/premium_state.dart", [
        "class PremiumState",
        "isPlusUnlocked",
        "offerVariant",
        "defaults",
    ]),
    ("lib/core/premium/premium_state_store.dart", [
        "class PremiumStateStore",
        "bw_premium_state_v1",
        "ValueNotifier<int>",
        "changes",
        "setPlusUnlocked",
        "setOfferVariant",
    ]),
    ("lib/features/premium/presentation/breakwave_plus_screen.dart", [
        "class BreakWavePlusScreen",
        "BreakWave Plus is in development.",
        "Available free in this testing build",
        "What Plus must deliver before paid launch",
        "Our paid-launch standard",
        "Subscriptions and purchases are not enabled.",
        "No charge can occur from this screen.",
    ]),
    ("lib/features/premium/presentation/premium_gate_tile.dart", [
        "class PremiumGateTile",
        "BreakWavePlusScreen",
        "Unlocked",
        "Available in BreakWave Plus",
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

    if "Preview Plus roadmap" not in support_text:
        print("FAIL Support screen missing Plus roadmap action")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-25 premium scaffolding verified.")
