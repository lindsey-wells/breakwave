#!/usr/bin/env python3
from __future__ import annotations
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = {
    "selection": ROOT / "lib/features/recovery_report/domain/recovery_report_selection.dart",
    "snapshot": ROOT / "lib/features/recovery_report/domain/recovery_report_snapshot.dart",
    "builder": ROOT / "lib/features/recovery_report/domain/recovery_report_snapshot_builder.dart",
    "formatter": ROOT / "lib/features/recovery_report/domain/recovery_report_formatter.dart",
    "screen": ROOT / "lib/features/recovery_report/presentation/recovery_report_builder_screen.dart",
    "selection_test": ROOT / "test/recovery_report_selection_test.dart",
    "builder_test": ROOT / "test/recovery_report_snapshot_builder_test.dart",
    "formatter_test": ROOT / "test/recovery_report_formatter_test.dart",
}

PROTECTED_BLOBS = {
    "lib/features/insights/domain/recovery_insights_snapshot.dart": "e528bf684c60d89152c4e1b96829ea5a9a0501ea",
    "lib/features/insights/domain/recovery_insights_calculator.dart": "5ac47984992b386a2cbfc365359b3b8fd7de269c",
    "lib/features/insights/presentation/widgets/weekly_recovery_review_section.dart": "d0b66cd6afe53ca7ff6d8f4224707676d0080ec2",
    "lib/features/recovery_report/data/recovery_report_export_service.dart": "f87a44d5b7d1e8924f23c508ebf89fc1f2ba992a",
    "lib/core/access/breakwave_access_policy.dart": "65a276c022d2d802f306f0980214cee072825a9a",
    "lib/features/premium/presentation/breakwave_plus_screen.dart": "59b5424c86c93dd3b2e4e9788f4bfd9e673329f8",
    "tools/verify_bw89a12b.py": "f8ebbe71a1f2b01da7e59a85c634683f1bf8c196",
}


def fail(msg: str) -> None:
    raise SystemExit(f"FAIL BW-89A12C: {msg}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def blob_sha(path: Path) -> str:
    data = path.read_bytes()
    header = f"blob {len(data)}\0".encode()
    return hashlib.sha1(header + data).hexdigest()

for rel, expected in PROTECTED_BLOBS.items():
    p = ROOT / rel
    if not p.is_file():
        fail(f"protected A12B file missing: {rel}")
    actual = blob_sha(p)
    if actual != expected:
        fail(f"protected A12B boundary drift: {rel} expected {expected} got {actual}")

content = {key: read(path) for key, path in FILES.items()}
selection = content["selection"]
snapshot = content["snapshot"]
builder = content["builder"]
formatter = content["formatter"]
screen = content["screen"]
selection_test = content["selection_test"]
builder_test = content["builder_test"]
formatter_test = content["formatter_test"]

for needle in (
    "weeklyReview,",
    "this.includeWeeklyReview = false",
    "final bool includeWeeklyReview;",
    "RecoveryReportSection.weeklyReview",
    "'includeWeeklyReview': includeWeeklyReview",
    "map['includeWeeklyReview'] == true",
):
    if needle not in selection:
        fail(f"selection contract missing: {needle}")

if "last7Days(" in selection or "last7Days," in selection or "last7Days(" in selection:
    fail("7-day report range was added; A12C must keep only 30/90-day report ranges")
for needle in ("last30Days(", "last90Days("):
    if needle not in selection:
        fail(f"existing report range missing: {needle}")

for needle in (
    "class RecoveryReportWeeklyReview",
    "final RecoveryPeriodSummary current;",
    "final RecoveryPeriodSummary previous;",
    "static const int reportVersion = 2;",
    "final RecoveryReportWeeklyReview? weeklyReview;",
    "map['weeklyReview'] = weeklyReview?.toMap();",
    "'last7Days': _summaryMap(current)",
    "'previous7Days': _summaryMap(previous)",
):
    if needle not in snapshot:
        fail(f"snapshot contract missing: {needle}")

for needle in (
    "selection.includeWeeklyReview",
    "RecoveryReportWeeklyReview(",
    "current: insights.last7Days",
    "previous: insights.previous7Days",
):
    if needle not in builder:
        fail(f"builder A12B-reuse contract missing: {needle}")

for needle in (
    "RecoveryReportSection.weeklyReview",
    "7-DAY RECOVERY REVIEW",
    "Last 7 days",
    "Previous 7 days",
    "two adjacent 7-day windows",
    "do not by themselves mean recovery is improving",
    "No weekly review data was available.",
):
    if needle not in formatter:
        fail(f"formatter observational contract missing: {needle}")

for forbidden in (
    "better week",
    "worse week",
    "success rate",
    "risk score",
    "more likely",
    "less likely",
    "recommendation",
):
    if forbidden in formatter.lower():
        fail(f"formatter forbidden judgment/prediction language: {forbidden}")

for needle in (
    "bool _includeWeeklyReview = false;",
    "includeWeeklyReview: _includeWeeklyReview",
    "title: '7-day recovery review'",
    "fixed weekly comparison does not change",
):
    if needle not in screen:
        fail(f"screen opt-in contract missing: {needle}")

for needle in (
    "expect(selection.includeWeeklyReview, isFalse)",
    "includeWeeklyReview: true",
    "RecoveryReportSection.weeklyReview",
    "expect(restored.includeWeeklyReview, isTrue)",
    "expect(restored.includeWeeklyReview, isFalse)",
):
    if needle not in selection_test:
        fail(f"selection regression coverage missing: {needle}")

for needle in (
    "weekly review reuses adjacent A12B windows only when selected",
    "snapshot.weeklyReview!.current.total",
    "snapshot.weeklyReview!.previous.total",
    "contains('weeklyReview')",
    "contains('last7Days')",
    "contains('previous7Days')",
):
    if needle not in builder_test:
        fail(f"builder regression coverage missing: {needle}")

for needle in (
    "weekly review renders adjacent raw windows without judgment",
    "RecoveryReportWeeklyReview(",
    "contains('7-DAY RECOVERY REVIEW')",
    "contains('\"reportVersion\": 2')",
    "contains('\"weeklyReview\"')",
):
    if needle not in formatter_test:
        fail(f"formatter regression coverage missing: {needle}")

for forbidden in (
    "SharedPreferences",
    "BreakWaveAccessPolicy",
    "billing",
    "entitlement",
    "saveEntry(",
    "updateEntry(",
):
    if forbidden.lower() in (selection + snapshot + builder + formatter).lower():
        fail(f"forbidden persistence/access/billing coupling: {forbidden}")

print(
    "PASS: BW-89A12C Weekly Share Summary verified — optional/off-by-default "
    "weekly review in the privacy-first Recovery Report, exact reuse of A12B "
    "last7Days/previous7Days aggregates, report schema v2, no new report range, "
    "no new persistence/export-service/access-policy/billing changes, and A12B "
    "insight boundaries preserved with the exact A12B verifier blob protected."
)
