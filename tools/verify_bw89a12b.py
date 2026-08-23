#!/usr/bin/env python3
from __future__ import annotations
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = ROOT / "lib/features/insights/domain/recovery_insights_snapshot.dart"
CALCULATOR = ROOT / "lib/features/insights/domain/recovery_insights_calculator.dart"
SCREEN = ROOT / "lib/features/insights/presentation/recovery_insights_screen.dart"
WIDGET = ROOT / "lib/features/insights/presentation/widgets/weekly_recovery_review_section.dart"
CALC_TEST = ROOT / "test/recovery_insights_calculator_test.dart"
WIDGET_TEST = ROOT / "test/weekly_recovery_review_section_test.dart"
A8B = ROOT / "tools/verify_bw89a8b.py"
A9 = ROOT / "tools/verify_bw89a9.py"
A12A = ROOT / "tools/verify_bw89a12a.py"

PROTECTED_HASHES = {
    "lib/features/log/domain/log_entry.dart": "0aaa13a2faf32f8449da9c184ee4de6bf981bcffddcf9fca40151cd0efb49df8",
    "lib/features/log/data/log_repository.dart": "2c082d70c040b767c96a12d7b5d48338d96cb73e1316d17657aacebc1a73ef3b",
    "lib/features/patterns/domain/pattern_observation_engine.dart": "df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f",
    "lib/features/home/presentation/home_screen.dart": "aa974f096a0abf5800a4bba78479e0913e206228124b6dee69c6217b6c976353",
    "lib/features/home/presentation/widgets/pattern_helpful_actions_card.dart": "a06f2ad99d57443c8f3580d8bf539605eaf165fa1f3c7ada22789b2c7ee67d23",
    "lib/features/personal_plan/presentation/personal_recovery_plan_screen.dart": "116da25f743e71eca484805768a77d1f9600781d7ea066e8f2348d39dca18224",
    "lib/core/access/breakwave_access_policy.dart": "5b326a8975d981604bdf3e94ab8956a5a71bf325f260fc5dcaeb3773050f682b",
    "lib/features/premium/presentation/breakwave_plus_screen.dart": "0473a5b2f2d5a1873a819431f0d9b4b1bd0b490e0061500e9bbe415494714433",
}


def fail(msg: str) -> None:
    raise SystemExit(f"FAIL BW-89A12B: {msg}")


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

for rel, expected in PROTECTED_HASHES.items():
    actual = sha(ROOT / rel)
    if actual != expected:
        fail(f"protected A12A boundary drift: {rel} expected {expected} got {actual}")

snapshot = text(SNAPSHOT)
calculator = text(CALCULATOR)
screen = text(SCREEN)
widget = text(WIDGET)
calc_test = text(CALC_TEST)
widget_test = text(WIDGET_TEST)
a8b = text(A8B)
a9 = text(A9)
a12a = text(A12A)

for needle in (
    "required this.previous7Days",
    "final RecoveryPeriodSummary previous7Days;",
):
    if needle not in snapshot:
        fail(f"snapshot missing: {needle}")

for needle in (
    "final RecoveryPeriodSummary previous7Days = _periodSummaryBetween(",
    "startInclusive: localNow.subtract(const Duration(days: 14))",
    "endExclusive: localNow.subtract(const Duration(days: 7))",
    "previous7Days: previous7Days",
    "!item.occurredAt.isBefore(startInclusive)",
    "item.occurredAt.isBefore(endExclusive)",
):
    if needle not in calculator:
        fail(f"calculator adjacent-window contract missing: {needle}")

for needle in (
    "weekly_recovery_review_section.dart",
    "WeeklyRecoveryReviewSection(",
    "current: snapshot.last7Days",
    "previous: snapshot.previous7Days",
):
    if needle not in screen:
        fail(f"screen integration missing: {needle}")

idx_last7 = screen.find("Your last 7 days")
idx_review = screen.find("WeeklyRecoveryReviewSection(")
idx_30 = screen.find("title: 'Last 30 days'")
if not (0 <= idx_last7 < idx_review < idx_30):
    fail("weekly review must follow existing 7-day summary and precede 30-day card")

for needle in (
    "7-day recovery review",
    "Last 7 days",
    "Previous 7 days",
    "two adjacent 7-day windows",
    "do not by themselves mean recovery is improving or worsening",
    "Logged moments:",
    "Average recorded intensity:",
):
    if needle not in widget:
        fail(f"weekly review observational contract missing: {needle}")

for forbidden in (
    "FilledButton",
    "OutlinedButton",
    "Navigator.",
    "better week",
    "worse week",
    "success rate",
    "risk score",
    "more likely",
    "less likely",
    "recommend",
):
    if forbidden in widget:
        fail(f"weekly review forbidden behavior/claim: {forbidden}")

for forbidden in (
    "SharedPreferences",
    "setString",
    "saveEntry(",
    "updateEntry(",
    "PersonalRecoveryPlanStore",
    "BreakWaveAccessPolicy",
    "billing",
    "entitlement",
):
    if forbidden in snapshot + calculator + widget:
        fail(f"forbidden persistence/access coupling: {forbidden}")

for needle in (
    "builds adjacent non-overlapping 7-day review windows",
    "snapshot.previous7Days.total",
    "previous-start-boundary",
    "current-boundary",
):
    if needle not in calc_test:
        fail(f"calculator regression coverage missing: {needle}")

for needle in (
    "weekly review shows adjacent raw windows without judgment",
    "weekly review shows honest empty intensity",
    "do not by themselves mean recovery",
):
    if needle not in widget_test:
        fail(f"widget regression coverage missing: {needle}")

calc_sha = sha(CALCULATOR)
if calc_sha == "5051fe330cc68315a1fe3e560f34b1a4690235e02f13c9f272e3f8c528bc09e0":
    fail("calculator hash did not change from A12A baseline")
for label, verifier_text in (("A8B", a8b), ("A9", a9)):
    if calc_sha not in verifier_text:
        fail(f"{label} calculator hash guard not updated to A12B candidate")
    if "5051fe330cc68315a1fe3e560f34b1a4690235e02f13c9f272e3f8c528bc09e0" in verifier_text:
        fail(f"{label} stale A12A calculator hash remains")

# A12A verifier remains present and still carries its Reinforce guardrails.
for needle in (
    "Helpful actions over time",
    "do not prove what caused an outcome",
    "new persistence/write path forbidden",
):
    if needle not in a12a:
        fail(f"A12A verifier boundary missing: {needle}")

print(
    "PASS: BW-89A12B 7-Day Recovery Review verified — adjacent non-overlapping "
    "7-day windows from existing local logs, observational wording only, no new "
    "persistence, billing, access-policy, prediction, or A12A Reinforce drift."
)
