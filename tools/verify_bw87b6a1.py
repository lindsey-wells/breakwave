from pathlib import Path
import sys

model_path = Path(
    "lib/features/recovery_report/domain/"
    "recovery_report_selection.dart"
)

test_path = Path(
    "test/recovery_report_selection_test.dart"
)

for path in [
    model_path,
    test_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6A1 missing file: {path}"
        )
        sys.exit(1)

model = model_path.read_text(
    encoding="utf-8"
)

tests = test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "enum RecoveryReportRange",
    "last30Days",
    "last90Days",
    "enum RecoveryReportSection",
    "class RecoveryReportPlanSelection",
    "class RecoveryReportSelection",
    "summaryOnly",
    "bool get includeSummary => true",
    "includeCompletedChristianJourneys =",
    "bool get includePersonalPlan",
    "selectedSections",
    "excludedByDesign",
    "Individual log entries",
    "Log notes and CBT reflections",
    "Trusted-contact phone numbers",
    "Trusted-contact email addresses",
    "Map<String, dynamic> toMap()",
    "RecoveryReportSelection.fromMap",
]:
    if needle not in model:
        print(
            "FAIL BW-87B6A1 selection model "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "includeRawLogs",
    "includeIndividualLogs",
    "includeLogNotes",
    "includeThoughts",
    "includeContactPhoneNumber",
    "includeContactEmailAddress",
]:
    if forbidden in model:
        print(
            "FAIL BW-87B6A1 forbidden "
            f"share option found: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "default report is 30-day summary only",
    "optional aggregate sections require opt-in",
    "personal plan fields are individually selected",
    "selection survives map round trip",
    "malformed values never opt users into sharing",
    "raw logs and contact details are excluded",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B6A1 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6A1 privacy-first report "
    "range and selectable-content contract verified."
)
