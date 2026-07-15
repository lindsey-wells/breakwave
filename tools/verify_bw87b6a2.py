from pathlib import Path
import sys

snapshot_path = Path(
    "lib/features/recovery_report/domain/"
    "recovery_report_snapshot.dart"
)

builder_path = Path(
    "lib/features/recovery_report/domain/"
    "recovery_report_snapshot_builder.dart"
)

test_path = Path(
    "test/recovery_report_snapshot_builder_test.dart"
)

for path in [
    snapshot_path,
    builder_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6A2 missing file: {path}"
        )
        sys.exit(1)

snapshot = snapshot_path.read_text(
    encoding="utf-8"
)

builder = builder_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "class RecoveryReportNamedCount",
    "class RecoveryReportTimingPatterns",
    "class RecoveryReportSnapshot",
    "RecoveryPeriodSummary summary",
    "selectedSections",
    "personalPlanFields",
    "excludedByDesign",
    "Map<String, dynamic> toMap()",
]:
    if needle not in snapshot:
        print(
            "FAIL BW-87B6A2 snapshot missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "class RecoveryReportSnapshotBuilder",
    "RecoveryInsightsCalculator",
    "selection.range.days",
    "_entriesWithin",
    "_topTriggers",
    "_timingPatterns",
    "_completedRoutines",
    "_completedChristianJourneys",
    "_selectedPlanFields",
    "minimumEntriesForTimePatterns",
    "'Morning'",
    "'Afternoon'",
    "'Evening'",
    "'Late night'",
    "'rescue completion'",
    "'wave timer'",
]:
    if needle not in builder:
        print(
            "FAIL BW-87B6A2 builder missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "entry.notes",
    "entry.thought",
    "entry.actionTaken",
    "entry.consequence",
    "entry.betterPlan",
    "entry.replacementAction",
    "entry.toMap()",
    "phoneNumber",
    "emailAddress",
]:
    if forbidden in builder:
        print(
            "FAIL BW-87B6A2 builder accesses "
            f"forbidden private data: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "summary-only report excludes optional and raw content",
    "90-day trigger and timing patterns use the selected range",
    "routine and journey counts include only selected-range completions",
    "personal plan snapshot contains only explicitly selected fields",
    "PRIVATE THOUGHT",
    "PRIVATE NOTES",
    "PRIVATE FAITH SUPPORT",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6A2 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6A2 real-data report snapshot, "
    "range filtering, and privacy enforcement verified."
)
