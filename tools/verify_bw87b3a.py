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
store_path = Path(
    "lib/features/personal_plan/data/"
    "personal_recovery_plan_store.dart"
)
test_path = Path(
    "test/personal_recovery_plan_test.dart"
)

for path in [
    model_path,
    prefill_path,
    store_path,
    test_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B3A missing file: {path}")
        sys.exit(1)

model = model_path.read_text(encoding="utf-8")
prefill = prefill_path.read_text(encoding="utf-8")
store = store_path.read_text(encoding="utf-8")
tests = test_path.read_text(encoding="utf-8")

for needle in [
    "class PersonalRecoveryPlan",
    "final List<String> reasons;",
    "final String primaryReason;",
    "final List<String> triggers;",
    "final List<String> dangerWindows;",
    "final List<String> redirectActions;",
    "final String trustedSupportName;",
    "final String phoneBoundary;",
    "final String bedtimeStrategy;",
    "final String afterSlipReset;",
    "final String faithSupport;",
    "preparedForSave(DateTime now)",
    "bool get hasAnyContent",
]:
    if needle not in model:
        print(f"FAIL BW-87B3A model missing: {needle}")
        sys.exit(1)

for needle in [
    "class PersonalRecoveryPlanPrefill",
    "fillEmptySections",
    "current.reasons.isEmpty",
    "current.primaryReason.trim().isEmpty",
    "current.triggers.isEmpty",
    "current.dangerWindows.isEmpty",
    "current.trustedSupportName.trim().isEmpty",
]:
    if needle not in prefill:
        print(f"FAIL BW-87B3A prefill missing: {needle}")
        sys.exit(1)

for forbidden in [
    "phoneNumber",
    "emailAddress",
    "BedtimeModeStore",
    "BedtimeModeEntry",
]:
    if forbidden in model or forbidden in prefill:
        print(
            f"FAIL BW-87B3A duplicated/transient data: "
            f"{forbidden}"
        )
        sys.exit(1)

for needle in [
    "bw_personal_recovery_plan_v1",
    "Future<PersonalRecoveryPlan?> load()",
    "return plan.hasAnyContent ? plan : null;",
    "catch (_)",
    "Future<void> save(",
    "ValueNotifier<int> changes",
]:
    if needle not in store:
        print(f"FAIL BW-87B3A store missing: {needle}")
        sys.exit(1)

for needle in [
    "prefills empty sections from current choices",
    "prefill never overwrites existing plan work",
    "preparedForSave preserves created date",
    "store saves, loads, and rejects corrupt JSON",
    "PersonalRecoveryPlanStore.storageKey",
]:
    if needle not in tests:
        print(f"FAIL BW-87B3A tests missing: {needle}")
        sys.exit(1)

print(
    "PASS: BW-87B3A personal recovery plan "
    "model, store, and safe prefill verified."
)
