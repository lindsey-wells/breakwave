from pathlib import Path
import sys

journey_path = Path(
    "lib/features/faith/domain/"
    "christian_recovery_journey.dart"
)
progress_path = Path(
    "lib/features/faith/domain/"
    "christian_journey_progress.dart"
)
store_path = Path(
    "lib/features/faith/data/"
    "christian_journey_progress_store.dart"
)
test_path = Path(
    "test/christian_journey_progress_test.dart"
)

for path in [
    journey_path,
    progress_path,
    store_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B5A1 missing file: {path}"
        )
        sys.exit(1)

journey = journey_path.read_text(
    encoding="utf-8"
)
progress = progress_path.read_text(
    encoding="utf-8"
)
store = store_path.read_text(
    encoding="utf-8"
)
tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "enum ChristianJourneyStepKind",
    "scripture",
    "context",
    "reflection",
    "action",
    "prayer",
    "enum ChristianJourneyActionTarget",
    "rescue",
    "personalPlan",
    "class ChristianJourneyStep",
    "class ChristianRecoveryJourney",
    "bool get hasRequiredFlow",
]:
    if needle not in journey:
        print(
            "FAIL BW-87B5A1 journey model "
            f"missing: {needle}"
        )
        sys.exit(1)


if progress.count(".toInt();") < 2:
    print(
        "FAIL BW-87B5A1 integer clamp "
        "conversions are missing."
    )
    sys.exit(1)

for needle in [
    "class ChristianJourneyProgress",
    "currentStepIndex",
    "completedStepIds",
    "currentRunCompletedAtIso",
    "completionHistoryIso",
    "completeCurrentStep",
    "ChristianJourneyProgress restart",
    "int get completionCount",
]:
    if needle not in progress:
        print(
            "FAIL BW-87B5A1 progress "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "bw_christian_journey_progress_v1",
    "ChristianJourneyProgressStore",
    "loadAll() async",
    "loadFor(",
    "saveProgress(",
    "clearJourney(",
    "ValueNotifier<int> changes",
    "catch (_)",
]:
    if needle not in store:
        print(
            "FAIL BW-87B5A1 store "
            f"missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "journey requires the complete Christian flow",
    "progress completes a journey and preserves history",
    "store saves and restores journey progress",
    "store rejects corrupt journey data safely",
    "Romans 8:1",
    "Open personal recovery plan",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B5A1 tests "
            f"missing: {needle}"
        )
        sys.exit(1)

combined = (
    journey
    + progress
    + store
    + tests
).lower()

for forbidden in [
    "cure",
    "guaranteed freedom",
    "faith replaces therapy",
    "professional help is unnecessary",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B5A1 unsafe claim "
            f"found: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B5A1 Christian journey model, "
    "progress, history, and local storage verified."
)
