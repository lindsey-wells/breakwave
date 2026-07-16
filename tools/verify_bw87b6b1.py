from pathlib import Path
import sys

screen_path = Path(
    "lib/features/recovery_report/presentation/"
    "recovery_report_builder_screen.dart"
)

plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

for path in [
    screen_path,
    plus_path,
]:
    if not path.exists():
        print(
            f"FAIL BW-87B6B1 missing file: {path}"
        )
        sys.exit(1)

screen = screen_path.read_text(
    encoding="utf-8"
)

plus = plus_path.read_text(
    encoding="utf-8"
)

for needle in [
    "class RecoveryReportBuilderScreen",
    "RecoveryReportSnapshotBuilder",
    "RecoveryReportFormatter.buildText",
    "RecoveryReportRange.values",
    "Recovery summary",
    "Top recorded triggers",
    "Timing observations",
    "Guided routine completions",
    "Christian journey completions",
    "Selected recovery-plan details",
    "Primary reason",
    "Danger windows",
    "Trusted support name",
    "Faith support",
    "Never included",
    "excludedByDesign",
    "Generate private preview",
    "Complete report preview",
    "Nothing is uploaded or shared from this screen",
    "does not create a file",
    "open the system share sheet",
    "RecoveryMode.christian",
    "PersonalRecoveryPlanStore.load",
    "RecoveryRoutineProgressStore",
    "ChristianJourneyProgressStore",
]:
    if needle not in screen:
        print(
            "FAIL BW-87B6B1 builder screen "
            f"missing: {needle}"
        )
        sys.exit(1)

for forbidden in [
    "SharePlus",
    "ShareParams",
    "XFile",
    "writeAsString",
    "getTemporaryDirectory",
    "share_plus",
    "dart:io",
]:
    if forbidden in screen:
        print(
            "FAIL BW-87B6B1 builder performs "
            f"premature export action: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "recovery_report_builder_screen.dart",
    "void _openRecoveryReport(",
    "const RecoveryReportBuilderScreen()",
    "Preview recovery report",
]:
    if needle not in plus:
        print(
            "FAIL BW-87B6B1 Plus launch "
            f"missing: {needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B6B1 privacy-first report "
    "selection, preview UI, and Plus launch verified."
)
