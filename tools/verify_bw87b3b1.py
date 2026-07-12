from pathlib import Path
import sys

model_path = Path(
    "lib/features/personal_plan/domain/"
    "personal_recovery_plan.dart"
)
prefill_path = Path(
    "lib/features/personal_plan/domain/"
    "personal_recovery_plan_prefill.dart"
)
screen_path = Path(
    "lib/features/personal_plan/presentation/"
    "personal_recovery_plan_screen.dart"
)
test_path = Path(
    "test/personal_recovery_plan_refresh_test.dart"
)

for path in [
    model_path,
    prefill_path,
    screen_path,
    test_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B3B1 missing file: {path}")
        sys.exit(1)

model = model_path.read_text(encoding="utf-8")
prefill = prefill_path.read_text(encoding="utf-8")
screen = screen_path.read_text(encoding="utf-8")
tests = test_path.read_text(encoding="utf-8")

for needle in [
    "importedReasons",
    "importedPrimaryReason",
    "importedTriggers",
    "importedDangerWindows",
    "importedTrustedSupportName",
]:
    if needle not in model:
        print(
            f"FAIL BW-87B3B1 import metadata missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "refreshFromCurrentChoices",
    "_refreshText",
    "_refreshList",
    "previousImported",
    "nextImported",
]:
    if needle not in prefill:
        print(
            f"FAIL BW-87B3B1 refresh engine missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "RecoveryInsightsCalculator",
    "LogRepository",
    "_refreshFromBreakWave",
    "snapshot.topTriggers30Days",
    "busiestWeekday30Days",
    "busiestTimeWindow30Days",
    "New BreakWave choices are available",
    "Refresh from current BreakWave choices",
    "Custom plan work was preserved",
    "_draftPlan = saved",
]:
    if needle not in screen:
        print(
            f"FAIL BW-87B3B1 screen sync missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "key != 'rescue completion'",
    "key != 'wave timer'",
]:
    if needle not in screen:
        print(
            f"FAIL BW-87B3B1 system-trigger filter missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "refreshes imported sections and preserves manual additions",
    "manual scalar edits are never replaced by refresh",
    "My custom reason",
    "My custom trigger",
    "Charge my phone outside.",
]:
    if needle not in tests:
        print(
            f"FAIL BW-87B3B1 refresh tests missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B3B1 personal-plan import refresh "
    "and manual-work protection verified."
)
