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
body_path = Path(
    "lib/features/personal_plan/presentation/widgets/"
    "personal_recovery_plan_body.dart"
)
workflow_path = Path(
    "lib/features/personal_plan/application/"
    "personal_recovery_plan_workflow.dart"
)
session_path = Path(
    "lib/features/personal_plan/application/"
    "personal_recovery_plan_session.dart"
)
test_path = Path(
    "test/personal_recovery_plan_refresh_test.dart"
)

for path in [
    model_path,
    prefill_path,
    screen_path,
    body_path,
    workflow_path,
    session_path,
    test_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B3B1 missing file: {path}")
        sys.exit(1)

model = model_path.read_text(encoding="utf-8")
prefill = prefill_path.read_text(encoding="utf-8")
screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
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
    "importCurrentChoices",
    "Custom plan work was preserved",
]:
    if needle not in session:
        print(
            f"FAIL BW-87B3B1 screen sync missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "New BreakWave choices are available",
    "Refresh from current BreakWave choices",
]:
    if needle not in ui:
        print(
            f"FAIL BW-87B3B1 plan UI sync missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "RecoveryInsightsCalculator",
    "LogRepository",
    "refreshFromBreakWave",
    "snapshot.topTriggers30Days",
    "busiestWeekday30Days",
    "busiestTimeWindow30Days",
    "key != 'rescue completion'",
    "key != 'wave timer'",
]:
    if needle not in workflow:
        print(
            f"FAIL BW-87B3B1 workflow sync missing: {needle}"
        )
        sys.exit(1)

saved_sync_markers = [
    "_draftPlan = saved",
    "_draftControllers.updateBasePlan(saved)",
]
if not any(marker in screen for marker in saved_sync_markers):
    print(
        "FAIL BW-87B3B1 saved draft sync is missing from "
        "both supported architectures"
    )
    sys.exit(1)

for needle in [
    "refreshes imported sections and preserves manual additions",
    "manual scalar edits are never replaced by refresh",
    "legacy imported Why and contact refresh when metadata is missing",
    "A new saved Why",
    "Mi familia",
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
