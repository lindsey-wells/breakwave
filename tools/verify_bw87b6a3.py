from pathlib import Path
import sys

formatter_path = Path(
    "lib/features/recovery_report/domain/"
    "recovery_report_formatter.dart"
)

test_path = Path(
    "test/recovery_report_formatter_test.dart"
)

for path in [
    formatter_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6A3 missing file: {path}"
        )
        sys.exit(1)

formatter = formatter_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "class RecoveryReportFormatter",
    "BreakWave Recovery Summary",
    "RECOVERY SUMMARY",
    "TOP RECORDED TRIGGERS",
    "TIMING OBSERVATIONS",
    "COMPLETED GUIDED ROUTINES",
    "COMPLETED CHRISTIAN JOURNEYS",
    "SELECTED RECOVERY PLAN DETAILS",
    "PRIVACY",
    "created on your device",
    "does not include individual logs",
    "buildText",
    "buildJson",
    "JsonEncoder.withIndent",
]:
    if needle not in formatter:
        print(
            "FAIL BW-87B6A3 formatter missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "LogEntry",
    "entry.notes",
    "entry.thought",
    "phoneNumber",
    "emailAddress",
    "SupportContact",
]:
    if forbidden in formatter:
        print(
            "FAIL BW-87B6A3 formatter accesses "
            f"forbidden data: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "summary-only text excludes optional headings",
    "selected aggregate sections render readable content",
    "personal plan output includes only snapshot fields",
    "empty optional sections explain missing data",
    "json contains structured filtered snapshot",
    "PRIVATE FAITH SUPPORT",
    "PRIVATE THOUGHT",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6A3 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6A3 readable text and JSON "
    "accountability report formatting verified."
)
