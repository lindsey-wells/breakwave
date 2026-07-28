#!/usr/bin/env python3
# BreakWave BW-MOD-01C draft-controller extraction verifier.

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
CONTROLLERS_REL = (
    "lib/features/personal_plan/presentation/"
    "personal_recovery_plan_draft_controllers.dart"
)
TEST_REL = "test/personal_recovery_plan_draft_controllers_test.dart"
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
    print(f"FAIL BW-MOD-01C: {message}")
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
    "controllers": ROOT / CONTROLLERS_REL,
    "test": ROOT / TEST_REL,
}
for label, path in paths.items():
    if not path.is_file():
        fail(f"missing {label} file: {path.relative_to(ROOT)}")

screen = paths["screen"].read_text(encoding="utf-8")
body = paths["body"].read_text(encoding="utf-8")
ui = screen + "\n" + body
controllers = paths["controllers"].read_text(encoding="utf-8")
tests = paths["test"].read_text(encoding="utf-8")

line_limits = {
    "screen": (241, 480),
    "controllers": (1, 220),
    "test": (1, 220),
    "verifier": (1, 420),
}
sources = {
    "screen": screen,
    "controllers": controllers,
    "test": tests,
    "verifier": Path(__file__).read_text(encoding="utf-8"),
}
for label, (minimum, maximum) in line_limits.items():
    lines = len(sources[label].splitlines())
    if not minimum <= lines <= maximum:
        fail(
            f"{label} line count outside stage boundary: "
            f"{lines} not in {minimum}..{maximum}"
        )

for token in (
    "import 'personal_recovery_plan_draft_controllers.dart';",
    "PersonalRecoveryPlanDraftControllers",
    "_draftControllers;",
    "_draftControllers.applyPlan(plan)",
    "_draftControllers.currentDraft()",
    "_draftControllers.updateBasePlan(saved)",
    "draftControllers.toggleSuggestion(",
):
    if token not in ui:
        fail(f"plan controller integration missing: {token}")

for forbidden in (
    "late final TextEditingController",
    "_reasonsController",
    "_primaryReasonController",
    "_triggersController",
    "_dangerWindowsController",
    "_redirectActionsController",
    "_trustedSupportController",
    "_phoneBoundaryController",
    "_bedtimeStrategyController",
    "_afterSlipResetController",
    "_faithSupportController",
    "_draftPlan",
    "_suppressDirty",
    "List<TextEditingController> get _controllers",
    "List<String> _parseLines",
    "void _writeLines",
):
    if forbidden in ui:
        fail(f"plan UI still owns extracted responsibility: {forbidden}")

for name in (
    "reasons",
    "primaryReason",
    "triggers",
    "dangerWindows",
    "redirectActions",
    "trustedSupport",
    "phoneBoundary",
    "bedtimeStrategy",
    "afterSlipReset",
    "faithSupport",
):
    marker = f"final TextEditingController {name}"
    if marker not in controllers:
        fail(f"controller field missing: {name}")

for token in (
    "class PersonalRecoveryPlanDraftControllers",
    "controller.addListener(_handleChanged)",
    "_suppressChanges",
    "void applyPlan(PersonalRecoveryPlan plan)",
    "void updateBasePlan(PersonalRecoveryPlan plan)",
    "PersonalRecoveryPlan currentDraft()",
    "void toggleSuggestion(",
    "raw.split(RegExp(r'[\\n,]'))",
    "seen.add(key)",
    "removeListener(_handleChanged)",
    "..dispose()",
):
    if token not in controllers:
        fail(f"draft-controller contract missing: {token}")

for forbidden in (
    "PersonalRecoveryPlanStore",
    "RecoveryMode",
    "ReasonsStore",
    "TriggersStore",
    "SupportContactStore",
    "CustomWhyStore",
    "LogRepository",
    "RecoveryInsightsCalculator",
    "BuildContext",
    "Widget build",
    "Future<",
    "async",
):
    if forbidden in controllers:
        fail(f"draft-controller module owns unrelated behavior: {forbidden}")

for token in (
    "applyPlan maps every field without reporting a user edit",
    "currentDraft trims text and de-duplicates list values",
    "toggleSuggestion removes and adds case-insensitively",
    "updateBasePlan preserves edits and refreshes saved metadata",
    "importSchemaVersion",
    "addTearDown(controllers.dispose)",
):
    if token not in tests:
        fail(f"draft-controller test coverage missing: {token}")

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
        fail(f"plan behavior marker changed or moved: {token}")

print(
    "PASS: BW-MOD-01C extracted Personal Recovery Plan controller "
    "lifecycle and draft mapping without changing user behavior."
)
