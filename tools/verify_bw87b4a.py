from pathlib import Path
import sys

routine_path = Path(
    "lib/features/guided_routines/domain/"
    "recovery_routine.dart"
)
catalog_path = Path(
    "lib/features/guided_routines/domain/"
    "recovery_routine_catalog.dart"
)
progress_path = Path(
    "lib/features/guided_routines/domain/"
    "recovery_routine_progress.dart"
)
store_path = Path(
    "lib/features/guided_routines/data/"
    "recovery_routine_progress_store.dart"
)
test_path = Path(
    "test/recovery_routine_progress_test.dart"
)

for path in [
    routine_path,
    catalog_path,
    progress_path,
    store_path,
    test_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B4A missing file: {path}")
        sys.exit(1)

routine = routine_path.read_text(encoding="utf-8")
catalog = catalog_path.read_text(encoding="utf-8")
progress = progress_path.read_text(encoding="utf-8")
store = store_path.read_text(encoding="utf-8")
tests = test_path.read_text(encoding="utf-8")

for needle in [
    "enum RoutineActionTarget",
    "class RecoveryRoutineStep",
    "class RecoveryRoutine",
    "RoutineActionTarget? actionTarget",
    "bool get hasAction",
]:
    if needle not in routine:
        print(f"FAIL BW-87B4A routine model missing: {needle}")
        sys.exit(1)

for needle in [
    "morning-reset",
    "stress-interruption",
    "loneliness-response",
    "phone-boundary-reset",
    "bedtime-protection",
    "after-slip-reset",
    "RoutineActionTarget.rescue",
    "RoutineActionTarget.log",
    "RoutineActionTarget.support",
    "RoutineActionTarget.personalPlan",
]:
    if needle not in catalog:
        print(f"FAIL BW-87B4A catalog missing: {needle}")
        sys.exit(1)

for needle in [
    "class RecoveryRoutineProgress",
    "currentStepIndex",
    "completedStepIds",
    "currentRunCompletedAtIso",
    "completionHistoryIso",
    "completeCurrentStep",
    "RecoveryRoutineProgress restart",
    "int get completionCount",
]:
    if needle not in progress:
        print(f"FAIL BW-87B4A progress missing: {needle}")
        sys.exit(1)

for needle in [
    "bw_guided_routine_progress_v1",
    "Map<String, RecoveryRoutineProgress>",
    "loadAll() async",
    "loadFor(",
    "saveProgress(",
    "clearRoutine(",
    "ValueNotifier<int> changes",
    "catch (_)",
]:
    if needle not in store:
        print(f"FAIL BW-87B4A store missing: {needle}")
        sys.exit(1)

for needle in [
    "catalog provides six actionable routines",
    "Christian wording appears only in Christian catalog",
    "progress completes a run and preserves history",
    "store saves and restores routine progress",
    "store rejects corrupt progress safely",
]:
    if needle not in tests:
        print(f"FAIL BW-87B4A tests missing: {needle}")
        sys.exit(1)

print(
    "PASS: BW-87B4A guided routine catalog, "
    "progress, and completion history verified."
)
