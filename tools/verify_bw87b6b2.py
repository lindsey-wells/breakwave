from pathlib import Path
import re
import sys

service_path = Path(
    "lib/features/recovery_report/data/"
    "recovery_report_export_service.dart"
)

screen_path = Path(
    "lib/features/recovery_report/presentation/"
    "recovery_report_builder_screen.dart"
)

test_path = Path(
    "test/recovery_report_export_service_test.dart"
)

for path in [
    service_path,
    screen_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6B2 missing file: {path}"
        )
        sys.exit(1)

service = service_path.read_text(
    encoding="utf-8"
)

screen = screen_path.read_text(
    encoding="utf-8"
)

# Dart frequently represents one visible sentence as
# adjacent string literals. Collapse the quote boundary
# and whitespace so privacy-copy checks validate what the
# user actually sees rather than source-line wrapping.
semantic_screen = re.sub(
    r"'\s*'",
    "",
    screen,
)

tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "class RecoveryReportExportFiles",
    "class RecoveryReportExportService",
    "getTemporaryDirectory",
    "writeAsString",
    "RecoveryReportFormatter.buildText",
    "RecoveryReportFormatter.buildJson",
    "breakwave_recovery_report_",
    "SharePlus.instance.share",
    "ShareParams",
    "XFile(files.textFile.path)",
    "XFile(files.jsonFile.path)",
]:
    if needle not in service:
        print(
            "FAIL BW-87B6B2 export service "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "LogEntry",
    "LogRepository",
    "PersonalRecoveryPlan",
    "SupportContact",
    "EmailCapture",
    "entry.notes",
    "entry.thought",
    "phoneNumber",
    "emailAddress",
]:
    if forbidden in service:
        print(
            "FAIL BW-87B6B2 export service "
            f"accesses forbidden data: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "RecoveryReportSnapshot? _previewSnapshot",
    "_previewSnapshot = null",
    "_previewSnapshot = snapshot",
    "Future<void> _sharePreviewedReport()",
    "Share this recovery report?",
    "exact preview",
    "Nothing is uploaded by BreakWave",
    "that app controls any copy you share",
    "RecoveryReportExportService",
    ".shareSnapshot(snapshot)",
    "Open share sheet",
    "Share this report",
    "temporary TXT and JSON files",
    "The receiving app controls any copy",
]:
    if needle not in semantic_screen:
        print(
            "FAIL BW-87B6B2 report screen "
            f"missing: {needle}"
        )
        sys.exit(1)

if screen.count("_previewSnapshot = null") < 2:
    print(
        "FAIL BW-87B6B2 preview must be invalidated "
        "by both refresh and selection changes."
    )
    sys.exit(1)

for forbidden in [
    "SharePlus.instance",
    "ShareParams(",
    "XFile(",
    "dart:io",
    "getTemporaryDirectory",
    "writeAsString",
]:
    if forbidden in screen:
        print(
            "FAIL BW-87B6B2 platform sharing leaked "
            f"into presentation code: {forbidden}"
        )
        sys.exit(1)

preview_index = screen.find(
    "'Complete report preview'"
)

share_index = screen.find(
    "'Share this report'"
)

if not (
    preview_index >= 0
    and share_index > preview_index
):
    print(
        "FAIL BW-87B6B2 share action must appear "
        "after the complete preview."
    )
    sys.exit(1)

for needle in [
    "timestamp token is stable and zero padded",
    "file stem is neutral and contains no personal data",
    "breakwave_recovery_report_90d_",
    "isNot(contains('email'))",
    "isNot(contains('phone'))",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6B2 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6B2 exact-preview TXT/JSON "
    "export and deliberate share handoff verified."
)
