from pathlib import Path
import sys

shell_path = Path(
    "lib/features/shell/presentation/breakwave_shell.dart"
)
home_path = Path(
    "lib/features/home/presentation/home_screen.dart"
)
log_path = Path(
    "lib/features/log/presentation/log_screen.dart"
)

failed = False

required = {
    shell_path: [
        "refreshTick: _homeRefreshTick,",
        "refreshTick: _logRefreshTick,",
        "_homeRefreshTick += 1;",
        "_logRefreshTick += 1;",
    ],
    home_path: [
        "final int refreshTick;",
        "this.refreshTick = 0,",
        "late Future<_HomeSummaryData> _summaryFuture;",
        "void didUpdateWidget(covariant HomeScreen oldWidget)",
        "oldWidget.refreshTick != widget.refreshTick",
        "_summaryFuture = _loadSummary();",
        "future: _summaryFuture,",
    ],
    log_path: [
        "final int refreshTick;",
        "this.refreshTick = 0,",
        "void didUpdateWidget(covariant LogScreen oldWidget)",
        "oldWidget.refreshTick != widget.refreshTick",
        "_refreshFromStorage();",
    ],
}

for path, needles in required.items():
    if not path.exists():
        print(f"FAIL missing file: {path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {path} missing: {needle}")
            failed = True

shell = shell_path.read_text(encoding="utf-8")

for forbidden in [
    "key: ValueKey<int>(_homeRefreshTick)",
    "key: ValueKey<int>(_logRefreshTick)",
]:
    if forbidden in shell:
        print(f"FAIL obsolete subtree-remount mechanism remains: {forbidden}")
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: PERF-02A retains Home/Log State and preserves explicit refresh."
)
