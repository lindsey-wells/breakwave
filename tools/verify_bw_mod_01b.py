#!/usr/bin/env python3
# BreakWave BW-MOD-01B presentation-widget extraction verifier.

from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCREEN_REL = (
    "lib/features/personal_plan/presentation/"
    "personal_recovery_plan_screen.dart"
)
BODY_REL = (
    "lib/features/personal_plan/presentation/widgets/"
    "personal_recovery_plan_body.dart"
)
WIDGETS_REL = (
    "lib/features/personal_plan/presentation/widgets/"
    "personal_recovery_plan_widgets.dart"
)
LOCKED = {
    "lib/features/personal_plan/data/personal_recovery_plan_store.dart":
        "ad7bc81f6fbfa7bad62ad331f1f9f5bfba56c59668da088140fb56490958bcd5",
    "lib/features/personal_plan/domain/personal_recovery_plan.dart":
        "18df7d8df06864ae1660a3c308d1093ab90a92bee4e7aae1283b9dcf5664d52d",
    "lib/features/personal_plan/domain/personal_recovery_plan_prefill.dart":
        "3719bbfc683b92c881df95150c6c000250bf6f166503f79bfa2779ad723c7152",
    "test/personal_recovery_plan_refresh_test.dart":
        "97bc997b5aa9e341720e27ba10487a84172e9ba17f125460c997e9a57ba52eff",
    "test/helpers/personal_recovery_plan_test_harness.dart":
        "0937328c934a3514e626d0343dd4f6ddb99b0d523787b39f439ce845f5842608",
    "test/personal_recovery_plan_screen_characterization_test.dart":
        "75743cdb1609b43f2c403056986f80430994978d225d5065e4e99c1146a3d977",
    "test/personal_recovery_plan_screen_import_characterization_test.dart":
        "f5da191ffacb2a8201a12798062075a4ea931dc9cc8c29d931ab978bc7923a70",
}


def fail(message: str) -> None:
    print(f"FAIL BW-MOD-01B: {message}")
    raise SystemExit(1)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


for rel, expected in LOCKED.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing locked file: {rel}")
    if digest(path) != expected:
        fail(f"locked file changed: {rel}")

screen_path = ROOT / SCREEN_REL
body_path = ROOT / BODY_REL
widgets_path = ROOT / WIDGETS_REL
for path in (screen_path, body_path, widgets_path):
    if not path.is_file():
        fail(f"missing stage file: {path.relative_to(ROOT)}")

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
widgets = widgets_path.read_text(encoding="utf-8")
screen_lines = len(screen.splitlines())
widget_lines = len(widgets.splitlines())

if screen_lines > 480:
    fail(
        "screen exceeded later-stage presentation boundary: "
        f"{screen_lines} lines"
    )
if screen_lines <= 240:
    fail("screen unexpectedly crossed its state-owner boundary")
if widget_lines > 180:
    fail(f"widget module exceeds review ceiling: {widget_lines} lines")

if (
    "import 'widgets/personal_recovery_plan_body.dart';"
    not in screen
):
    fail("screen is missing the extracted body import")
if "import 'personal_recovery_plan_widgets.dart';" not in body:
    fail("body is missing the extracted widget import")

for old_name in ("_ListPlanField", "_SectionTitle", "_PlanCard"):
    if old_name in ui:
        fail(f"private widget remains in plan UI: {old_name}")

for name in (
    "PersonalPlanListField",
    "PersonalPlanSectionTitle",
    "PersonalPlanCard",
):
    if f"class {name}" in screen or f"class {name}" in body:
        fail(f"widget class was not kept in widget module: {name}")
    if f"class {name}" not in widgets:
        fail(f"extracted widget class missing: {name}")
    if name not in body:
        fail(f"form body does not use extracted widget: {name}")

for forbidden in (
    "PersonalRecoveryPlanStore",
    "RecoveryMode",
    "ReasonsStore",
    "TriggersStore",
    "SupportContactStore",
    "CustomWhyStore",
    "LogRepository",
    "RecoveryInsightsCalculator",
    "Future<",
    "async",
):
    if forbidden in widgets:
        fail(f"presentation widget module owns behavior: {forbidden}")

for token in (
    "AnimatedBuilder",
    "FilterChip",
    "TextField",
    "Your list",
    "One item per line",
    "withOpacity(0.45)",
    "surfaceContainerHighest",
    "outlineVariant",
):
    if token not in widgets:
        fail(f"presentation token missing from widget module: {token}")

for token in (
    "WillPopScope",
    "PersonalRecoveryPlanStore.save",
    "_refreshFromBreakWave",
    "_currentDraft",
    "_confirmLeave",
    "RecoveryMode.christian",
    "Personal recovery plan saved on this device.",
    "Refresh from current BreakWave choices",
    "Discard unsaved changes?",
):
    if token not in ui:
        fail(f"plan behavior marker changed or moved incorrectly: {token}")

print(
    "PASS: BW-MOD-01B extracted presentation-only widgets while "
    "preserving Personal Recovery Plan behavior and wording."
)
