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
        print(f"FAIL BW-87B3B3 missing file: {path}")
        sys.exit(1)

model = model_path.read_text(encoding="utf-8")
prefill = prefill_path.read_text(encoding="utf-8")
screen = screen_path.read_text(encoding="utf-8")
tests = test_path.read_text(encoding="utf-8")

for needle in [
    "final int importSchemaVersion;",
    "'importSchemaVersion': importSchemaVersion",
    "this.importSchemaVersion = 0",
]:
    if needle not in model:
        print(
            f"FAIL BW-87B3B3 schema model missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "currentImportSchemaVersion = 2",
    "requiresLegacyMigration",
    "forceSourceRefresh:",
    "if (forceSourceRefresh)",
    "importSchemaVersion:",
]:
    if needle not in prefill:
        print(
            f"FAIL BW-87B3B3 migration missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "_importSourceSignature",
    "_importSourceSignature(refreshed)",
    "_importSourceSignature(basePlan)",
    "_importSourceSignature(imported)",
    "_importSourceSignature(current)",
]:
    if needle not in screen:
        print(
            f"FAIL BW-87B3B3 source detection missing: {needle}"
        )
        sys.exit(1)

for needle in [
    "migrates incorrect metadata saved by earlier plan builds",
    "'Mi familia'",
    "'Sam'",
    "importSchemaVersion: 0",
    "currentImportSchemaVersion",
]:
    if needle not in tests:
        print(
            f"FAIL BW-87B3B3 regression test missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B3B3 legacy plan migration and "
    "source-change detection verified."
)
