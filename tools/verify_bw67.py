from pathlib import Path
import re
import sys

checks = [
    ("lib/features/home/home_screen.dart", [
        "Purpose: Legacy HomeScreen compatibility surface.",
        "BW-67 removes stale bootstrap copy",
        "BreakWave is ready.",
        "Home, Rescue, Log, and Support",
    ]),
    ("lib/features/learn/presentation/educate_me_screen.dart", [
        "Premium guided learning is part of BreakWave Plus.",
    ]),
    ("launch/app_dead_button_audit.md", [
        "BW-67 App-Wide Dead Button Audit",
        "dead actions",
        "Buttons in BreakWave should either perform a real action",
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

dead_patterns = [
    r"onPressed:\s*\(\)\s*\{\s*\}",
    r"onTap:\s*\(\)\s*\{\s*\}",
    r"onLongPress:\s*\(\)\s*\{\s*\}",
    r"onSelected:\s*\(\)\s*\{\s*\}",
]

for path in Path("lib").rglob("*.dart"):
    text = path.read_text(encoding="utf-8")

    for pattern in dead_patterns:
        if re.search(pattern, text):
            print(f"FAIL dead callback in {path}: {pattern}")
            failed = True

    lower = text.lower()
    if "todo" in lower or "fixme" in lower:
        print(f"FAIL unfinished TODO/FIXME marker in {path}")
        failed = True

    if "coming soon" in lower:
        print(f"FAIL coming-soon copy still present in {path}")
        failed = True

clinical = Path("lib/core/clinical/cbt_recovery_foundation.dart")
if clinical.exists():
    clinical_text = clinical.read_text(encoding="utf-8")
    required_safe_copy = "BreakWave is a support tool. It does not provide therapy, diagnosis, medical advice, emergency care, or a cure"
    if required_safe_copy not in clinical_text:
        print("FAIL safe clinical disclaimer is missing")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-67 app-wide dead-button audit verified.")
