from pathlib import Path
import sys

checks = [
    ("lib/core/privacy_lock/privacy_lock_mode.dart", [
        "return 'Lock Log & Support';",
        "Keep Home and Rescue reachable, but require a passcode for Log and Support.",
    ]),
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", [
        "Lock Log & Support keeps Home and Rescue reachable while protecting the most sensitive screens.",
    ]),
    ("lib/features/support/presentation/widgets/privacy_settings_card.dart", [
        "Reduce visible detail on Home, use neutral notification text, and add screenshot protection when your device supports it.",
        "Recommended when using Lock Log & Support so Home reveals less recovery detail.",
        "Prevents recent log details from appearing on Home while the app is unlocked.",
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

print("PASS: BW-49B sensitive lock and Home privacy copy verified.")
