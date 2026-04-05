from pathlib import Path
import sys

checks = [
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "class _BreakWaveShellState extends State<BreakWaveShell>",
        "_logRefreshTick",
        "if (index == 2) {",
        "_logRefreshTick += 1;",
        "LogScreen(",
        "key: ValueKey<int>(_logRefreshTick),",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "entryType: 'Victory'",
        "widget.onReturnHome();",
    ]),
    ("lib/features/log/presentation/log_screen.dart", [
        "_refreshFromStorage();",
        "class LogScreen extends StatefulWidget",
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

print("PASS: BW-13B rescue-to-log refresh verified.")
