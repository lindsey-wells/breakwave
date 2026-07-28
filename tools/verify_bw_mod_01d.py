#!/usr/bin/env python3
# BreakWave BW-MOD-01D refresh-workflow extraction verifier.

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
WORKFLOW_REL = (
    "lib/features/personal_plan/application/"
    "personal_recovery_plan_workflow.dart"
)
TEST_REL = "test/personal_recovery_plan_workflow_test.dart"
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
    print(f"FAIL BW-MOD-01D: {message}")
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
    "workflow": ROOT / WORKFLOW_REL,
    "test": ROOT / TEST_REL,
}
for label, path in paths.items():
    if not path.is_file():
        fail(f"missing {label} file: {path.relative_to(ROOT)}")

screen = paths["screen"].read_text(encoding="utf-8")
body = paths["body"].read_text(encoding="utf-8")
ui = screen + "\n" + body
workflow = paths["workflow"].read_text(encoding="utf-8")
tests = paths["test"].read_text(encoding="utf-8")
verifier = Path(__file__).read_text(encoding="utf-8")

limits = {
    "screen": (241, 480, screen),
    "workflow": (80, 180, workflow),
    "test": (60, 180, tests),
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
    "import '../application/personal_recovery_plan_workflow.dart';",
    "late final PersonalRecoveryPlanWorkflow _workflow;",
    "_workflow = PersonalRecoveryPlanWorkflow(",
    "_workflow.editableSignature(plan)",
    "_workflow.importSourceSignature(plan)",
    "_workflow.refreshFromBreakWave(current)",
):
    if token not in screen:
        fail(f"screen workflow integration missing: {token}")

for forbidden in (
    "final reasons =\n        await ReasonsStore.loadSelection()",
    "final triggers =\n        await TriggersStore.loadSelection()",
    "snapshot.topTriggers30Days",
    "observedDangerWindows =",
    "key != 'rescue completion'",
    "key != 'wave timer'",
):
    if forbidden in screen:
        fail(f"screen still owns extracted refresh behavior: {forbidden}")

for token in (
    "class PersonalRecoveryPlanWorkflow",
    "String editableSignature(PersonalRecoveryPlan plan)",
    "String importSourceSignature(PersonalRecoveryPlan plan)",
    "bool hasChanges(",
    "Future<PersonalRecoveryPlan> refreshFromBreakWave(",
    "ReasonsStore.loadSelection()",
    "TriggersStore.loadSelection()",
    "SupportContactStore.loadContact()",
    "CustomWhyStore.load()",
    "_logRepository.loadEntries()",
    "snapshot.topTriggers30Days",
    "key != 'rescue completion'",
    "key != 'wave timer'",
    "_prefill.refreshFromCurrentChoices(",
):
    if token not in workflow:
        fail(f"refresh-workflow contract missing: {token}")

for forbidden in (
    "BuildContext",
    "Widget",
    "TextEditingController",
    "setState(",
    "CircularProgressIndicator",
    "showDialog",
    "PersonalRecoveryPlanStore.save",
):
    if forbidden in workflow:
        fail(f"workflow module owns unrelated behavior: {forbidden}")

for token in (
    "refresh imports current reasons through the extracted workflow",
    "editable signature ignores display case and scalar whitespace",
    "source metadata is compared separately from editable content",
    "identical plans report no workflow changes",
    "ReasonsStore.saveSelection",
    "workflow.refreshFromBreakWave",
    "workflow.hasChanges",
):
    if token not in tests:
        fail(f"workflow test coverage missing: {token}")

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
    "PASS: BW-MOD-01D extracted Personal Recovery Plan refresh "
    "workflow without changing user-facing behavior."
)
