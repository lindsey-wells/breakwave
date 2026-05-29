from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", [
        "Example: 123456",
        "Set 6-digit PIN",
        "Confirm 6-digit PIN",
    ]),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", [
        "Wrong PIN. $attemptsRemaining tries left before cooldown.",
        "softWrap: true",
        "color: colorScheme.error",
        "decoration: const InputDecoration",
        "labelText: '6-digit PIN'",
    ]),
    ("tools/verify_bw49c.py", [
        "tries left before cooldown",
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

blocked = [
    ("lib/features/support/presentation/widgets/privacy_lock_settings_card.dart", "hintText: 'Example: 1234',"),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", "errorText: _error"),
    ("lib/features/privacy_lock/presentation/privacy_unlock_screen.dart", "attempts before a temporary cooldown"),
]

for rel_path, needle in blocked:
    text = Path(rel_path).read_text(encoding="utf-8")
    if needle in text:
        print(f"FAIL {rel_path} still contains old UI issue: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-49C1 PIN UI polish verified.")
