#!/usr/bin/env python3
# BreakWave BW-MOD-01E Personal Recovery Plan body extraction verifier.

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
TEST_REL = "test/personal_recovery_plan_body_test.dart"
LOCKED = {
    "lib/features/personal_plan/data/personal_recovery_plan_store.dart":
        "ad7bc81f6fbfa7bad62ad331f1f9f5bfba56c59668da088140fb56490958bcd5",
    "lib/features/personal_plan/domain/personal_recovery_plan.dart":
        "18df7d8df06864ae1660a3c308d1093ab90a92bee4e7aae1283b9dcf5664d52d",
    "lib/features/personal_plan/domain/personal_recovery_plan_prefill.dart":
        "3719bbfc683b92c881df95150c6c000250bf6f166503f79bfa2779ad723c7152",
    "test/personal_recovery_plan_screen_characterization_test.dart":
        "75743cdb1609b43f2c403056986f80430994978d225d5065e4e99c1146a3d977",
    "test/personal_recovery_plan_screen_import_characterization_test.dart":
        "f5da191ffacb2a8201a12798062075a4ea931dc9cc8c29d931ab978bc7923a70",
}


def fail(message: str) -> None:
    print(f"FAIL BW-MOD-01E: {message}")
    raise SystemExit(1)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


for rel, expected in LOCKED.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing locked file: {rel}")
    if digest(path) != expected:
        fail(f"locked file changed: {rel}")

paths = {
    "screen": ROOT / SCREEN_REL,
    "body": ROOT / BODY_REL,
    "test": ROOT / TEST_REL,
}
for label, path in paths.items():
    if not path.is_file():
        fail(f"missing {label} file: {path.relative_to(ROOT)}")

screen = paths["screen"].read_text(encoding="utf-8")
body = paths["body"].read_text(encoding="utf-8")
tests = paths["test"].read_text(encoding="utf-8")
verifier = Path(__file__).read_text(encoding="utf-8")

limits = {
    "screen": (241, 480, screen),
    "body": (300, 520, body),
    "test": (100, 240, tests),
    "verifier": (1, 360, verifier),
}
for label, (minimum, maximum, source) in limits.items():
    count = len(source.splitlines())
    if not minimum <= count <= maximum:
        fail(
            f"{label} line count outside stage boundary: "
            f"{count} not in {minimum}..{maximum}"
        )

for token in (
    "import 'widgets/personal_recovery_plan_body.dart';",
    "PersonalRecoveryPlanBody(",
    "loading: _loading",
    "loadError: _loadError",
    "draftControllers: _draftControllers",
    "statusMessage: _statusMessage",
    "onRetry: _retryLoadPlan",
    "onRefresh: _importCurrentChoices",
    "onSave: _savePlan",
):
    if token not in screen:
        fail(f"screen body integration missing: {token}")

for forbidden in (
    "Widget _buildBody(",
    "PersonalPlanCard(",
    "PersonalPlanListField(",
    "CircularProgressIndicator",
    "Build a plan you can actually use",
    "Refresh from current BreakWave choices",
    "Faith support",
):
    if forbidden in screen:
        fail(f"screen still owns extracted form markup: {forbidden}")

for token in (
    "class PersonalRecoveryPlanBody extends StatelessWidget",
    "final PersonalRecoveryPlanDraftControllers draftControllers",
    "final RecoveryMode mode",
    "final VoidCallback onRetry",
    "final Future<void> Function() onRefresh",
    "final Future<void> Function() onSave",
    "CircularProgressIndicator",
    "Plan unavailable",
    "Build a plan you can actually use",
    "New BreakWave choices are available",
    "Refresh from current BreakWave choices",
    "Why I am changing",
    "What I need to watch",
    "My first moves",
    "Support and boundaries",
    "After a slip",
    "RecoveryMode.christian",
    "Faith support",
    "PersonalPlanCard",
    "PersonalPlanListField",
    "Save recovery plan",
    "Plan saved",
):
    if token not in body:
        fail(f"form-body contract missing: {token}")

for forbidden in (
    "PersonalRecoveryPlanStore",
    "RecoveryModeStore",
    "PersonalRecoveryPlanWorkflow",
    "LogRepository",
    "RecoveryInsightsCalculator",
    "setState(",
    "showDialog",
    "DateTime.now",
    "WillPopScope",
    "Navigator.",
):
    if forbidden in body:
        fail(f"form body owns non-presentation behavior: {forbidden}")

for token in (
    "loading state remains a centered progress indicator",
    "error state preserves retry wording and callback",
    "secular body preserves refresh and primary plan sections",
    "Christian body exposes faith support and saves through callback",
    "saved body keeps the save button disabled",
    "PersonalRecoveryPlanBody(",
    "RecoveryMode.christian",
    "expect(retries, 1)",
    "expect(refreshes, 1)",
    "expect(saves, 1)",
):
    if token not in tests:
        fail(f"form-body test coverage missing: {token}")

for token in (
    "Future<void> _loadPlan()",
    "Future<void> _importCurrentChoices()",
    "Future<void> _savePlan()",
    "Future<bool> _confirmLeave()",
    "PersonalRecoveryPlanStore.save(saved)",
    "WillPopScope",
    "Discard unsaved changes?",
):
    if token not in screen:
        fail(f"screen lost required state ownership: {token}")

print(
    "PASS: BW-MOD-01E extracted the Personal Recovery Plan form body "
    "without changing wording, state ownership, or user behavior."
)
