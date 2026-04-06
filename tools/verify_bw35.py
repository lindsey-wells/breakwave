from pathlib import Path
import sys

checks = [
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "int _homeRefreshTick = 0;",
        "int _logRefreshTick = 0;",
        "if (_selectedIndex == index && index != 0 && index != 2) return;",
        "if (index == 0) {",
        "_homeRefreshTick += 1;",
        "if (index == 2) {",
        "_logRefreshTick += 1;",
        "key: ValueKey<int>(_homeRefreshTick),",
        "key: ValueKey<int>(_logRefreshTick),",
        "void _returnHome() {",
        "_selectedIndex = 0;",
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

print("PASS: BW-35 home refresh hardening verified.")
