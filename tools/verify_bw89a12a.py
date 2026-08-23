#!/usr/bin/env python3
from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SNAPSHOT = ROOT / "lib/features/insights/domain/recovery_insights_snapshot.dart"
CALCULATOR = ROOT / "lib/features/insights/domain/recovery_insights_calculator.dart"
SCREEN = ROOT / "lib/features/insights/presentation/recovery_insights_screen.dart"
WIDGET = ROOT / "lib/features/insights/presentation/widgets/helpful_actions_history_section.dart"
CALC_TEST = ROOT / "test/recovery_insights_calculator_test.dart"
WIDGET_TEST = ROOT / "test/helpful_actions_history_section_test.dart"

PROTECTED_HASHES = {
    "lib/features/log/domain/log_entry.dart":
        "0aaa13a2faf32f8449da9c184ee4de6bf981bcffddcf9fca40151cd0efb49df8",
    "lib/features/log/data/log_repository.dart":
        "2c082d70c040b767c96a12d7b5d48338d96cb73e1316d17657aacebc1a73ef3b",
    "lib/features/patterns/domain/pattern_observation_engine.dart":
        "df134a04cc81f54f2cef39be5a9a7e2338b2ffdaf983d249f0e936d38d9c780f",
    "lib/features/home/presentation/home_screen.dart":
        "aa974f096a0abf5800a4bba78479e0913e206228124b6dee69c6217b6c976353",
    "lib/features/home/presentation/widgets/pattern_helpful_actions_card.dart":
        "a06f2ad99d57443c8f3580d8bf539605eaf165fa1f3c7ada22789b2c7ee67d23",
    "lib/features/personal_plan/presentation/personal_recovery_plan_screen.dart":
        "116da25f743e71eca484805768a77d1f9600781d7ea066e8f2348d39dca18224",
    "lib/core/access/breakwave_access_policy.dart":
        "5b326a8975d981604bdf3e94ab8956a5a71bf325f260fc5dcaeb3773050f682b",
    "lib/features/premium/presentation/breakwave_plus_screen.dart":
        "0473a5b2f2d5a1873a819431f0d9b4b1bd0b490e0061500e9bbe415494714433",
}


def fail(message: str) -> None:
    raise SystemExit(f"FAIL BW-89A12A: {message}")


def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


for rel, expected in PROTECTED_HASHES.items():
    actual = sha256(ROOT / rel)
    if actual != expected:
        fail(f"protected baseline drift: {rel} expected {expected}, got {actual}")

snapshot = text(SNAPSHOT)
calculator = text(CALCULATOR)
screen = text(SCREEN)
widget = text(WIDGET)
calc_test = text(CALC_TEST)
widget_test = text(WIDGET_TEST)

for needle in (
    "class HelpfulActionInsight",
    "required this.action",
    "required this.victoryCount30Days",
    "required this.victoryCount90Days",
    "final List<HelpfulActionInsight> helpfulActionsOverTime;",
):
    if needle not in snapshot:
        fail(f"snapshot contract missing: {needle}")

for needle in (
    "final List<_DatedLogEntry> entries90Days = _entriesWithin(",
    "helpfulActionsOverTime: _helpfulActions(",
    "required List<_DatedLogEntry> entries30Days",
    "required List<_DatedLogEntry> entries90Days",
    "item.normalizedType != 'victory'",
    "item.entry.replacementAction.trim()",
    "final String key = display.toLowerCase();",
    "accumulator.victoryCount90Days += 1;",
    "accumulator.victoryCount30Days += 1;",
    "b.victoryCount30Days.compareTo(a.victoryCount30Days)",
    "b.victoryCount90Days.compareTo(a.victoryCount90Days)",
    "ranked.take(5)",
):
    if needle not in calculator:
        fail(f"calculator contract missing: {needle}")

for forbidden in (
    "SharedPreferences",
    "setStringList(",
    "saveEntry(",
    "updateEntry(",
    "confirmVictoryReplacementAction(",
    "PersonalRecoveryPlanStore",
):
    if forbidden in snapshot + calculator + widget:
        fail(f"new persistence/write path forbidden: {forbidden}")

for needle in (
    "widgets/helpful_actions_history_section.dart",
    "HelpfulActionsHistorySection(",
    "actions: snapshot.helpfulActionsOverTime",
):
    if needle not in screen:
        fail(f"screen integration missing: {needle}")

idx_90 = screen.find("title: 'Last 90 days'")
idx_helpful = screen.find("HelpfulActionsHistorySection(")
idx_trigger = screen.find("_TriggerCard(")
if not (0 <= idx_90 < idx_helpful < idx_trigger):
    fail("Helpful actions section must appear after 90-day summary and before triggers")

for needle in (
    "Helpful actions over time",
    "From victories you recorded",
    "30-day window is part of the 90-day window",
    "do not prove what caused an outcome",
    "predict what ",
    "will work next",
    "victoryCount30Days",
    "victoryCount90Days",
):
    if needle not in widget:
        fail(f"widget observational contract missing: {needle}")

for forbidden in (
    "FilledButton",
    "OutlinedButton",
    "ChoiceChip",
    "Navigator.",
    "will work better",
    "works best",
    "effective",
    "success rate",
    "improving",
    "declining",
    "more likely",
    "less likely",
    "risk score",
):
    if forbidden in widget:
        fail(f"widget forbidden behavior/claim present: {forbidden}")

for needle in (
    "String replacementAction = ''",
    "replacementAction: replacementAction",
    "groups helpful actions case-insensitively across 30 and 90 days",
    "snapshot.helpfulActionsOverTime",
    "victoryCount30Days",
    "victoryCount90Days",
):
    if needle not in calc_test:
        fail(f"calculator regression coverage missing: {needle}")

for needle in (
    "helpful-action history shows raw overlapping-window counts only",
    "30 days: 2 victories • 90 days: 3 victories",
    "helpful-action history has an honest empty state",
):
    if needle not in widget_test:
        fail(f"widget test contract missing: {needle}")

print(
    "PASS: BW-89A12A Helpful actions over time verified — existing dated "
    "Victory replacementAction evidence is grouped into observational 30/90-day "
    "counts without new persistence, prediction, causation, or changes to the "
    "A11 Reinforce loop."
)
