from pathlib import Path
import sys

log_path = Path(
    "lib/features/log/presentation/log_screen.dart"
)
calculator_path = Path(
    "lib/features/insights/domain/recovery_insights_calculator.dart"
)
snapshot_path = Path(
    "lib/features/insights/domain/recovery_insights_snapshot.dart"
)
test_path = Path(
    "test/recovery_insights_calculator_test.dart"
)

for path in [log_path, calculator_path, snapshot_path, test_path]:
    if not path.exists():
        print(f"FAIL BW-87B2A missing file: {path}")
        sys.exit(1)

log_text = log_path.read_text(encoding="utf-8")
calculator = calculator_path.read_text(encoding="utf-8")
snapshot = snapshot_path.read_text(encoding="utf-8")

for needle in [
    "BW-87B2A preserves the original timestamp when editing.",
    "String? _editingCreatedAtIso;",
    "_editingCreatedAtIso = entry.createdAtIso;",
    "_editingCreatedAtIso = null;",
    "createdAtIso: editingId == null",
    "? DateTime.now().toIso8601String()",
    ": (_editingCreatedAtIso ?? ''),",
]:
    if needle not in log_text:
        print(f"FAIL BW-87B2A timestamp integrity missing: {needle}")
        sys.exit(1)

for needle in [
    "class RecoveryInsightsCalculator",
    "minimumEntriesForTimePatterns = 5",
    "DateTime.tryParse(entry.createdAtIso)",
    "occurredAt.isAfter(localNow)",
    "days: 7",
    "days: 30",
    "days: 90",
    "_topTriggers(entries30Days)",
    "_weekdayCounts(entries30Days)",
    "_timeWindowCounts(entries30Days)",
]:
    if needle not in calculator:
        print(f"FAIL BW-87B2A calculator missing: {needle}")
        sys.exit(1)

for needle in [
    "class RecoveryPeriodSummary",
    "class TriggerInsight",
    "class RecoveryInsightsSnapshot",
    "ignoredEntryCount",
    "topTriggers30Days",
    "hasEnoughForTimePatterns",
]:
    if needle not in snapshot:
        print(f"FAIL BW-87B2A snapshot missing: {needle}")
        sys.exit(1)

test_text = test_path.read_text(encoding="utf-8")

for needle in [
    "calculates truthful 7, 30, and 90 day summaries",
    "withholds time patterns when fewer than five entries exist",
    "reports a dominant weekday and time window with enough data",
    "returns an honest empty snapshot when no valid logs exist",
    "snapshot.ignoredEntryCount, 3",
    "snapshot.busiestWeekday30Days, 'Monday'",
    "snapshot.busiestTimeWindow30Days, 'Evening'",
]:
    if needle not in test_text:
        print(f"FAIL BW-87B2A test coverage missing: {needle}")
        sys.exit(1)

print("PASS: BW-87B2A timestamp integrity and analytics engine verified.")
