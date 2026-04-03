from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent

EXPECTED_FILES = [
    "lib/features/home/presentation/home_screen.dart",
    "lib/features/home/presentation/widgets/recovery_snapshot_card.dart",
    "lib/features/home/presentation/widgets/latest_logged_moment_card.dart",
]

EXPECTED_PATTERNS = {
    "lib/features/home/presentation/home_screen.dart": [
        "FutureBuilder<_HomeSummaryData>(",
        "Future<_HomeSummaryData> _loadSummary() async",
        "final LogRepository repository = const LogRepository();",
        "RecoverySnapshotCard(",
        "LatestLoggedMomentCard(",
        "latestEntry: entries.isEmpty ? null : entries.first",
        "class _HomeSummaryData",
    ],
    "lib/features/home/presentation/widgets/recovery_snapshot_card.dart": [
        "class RecoverySnapshotCard",
        "Recovery Snapshot",
        "Saved entries",
        "Urges",
        "Slips",
        "Victories",
    ],
    "lib/features/home/presentation/widgets/latest_logged_moment_card.dart": [
        "class LatestLoggedMomentCard",
        "Latest Logged Moment",
        "No logged moments yet.",
        "Intensity ",
        "Triggers:",
    ],
}

HEADER_TOKEN = "Cube23 Collaboration Header"


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def main() -> None:
    for rel_path in EXPECTED_FILES:
        path = ROOT / rel_path
        if not path.exists():
            fail(f"missing file: {rel_path}")

        content = path.read_text(encoding="utf-8")

        if HEADER_TOKEN not in content:
            fail(f"missing Cube23 header in: {rel_path}")

        for pattern in EXPECTED_PATTERNS.get(rel_path, []):
            if pattern not in content:
                fail(f"missing pattern in {rel_path}: {pattern}")

    print("PASS: BW-09 home summary from persisted data verified.")


if __name__ == "__main__":
    main()
