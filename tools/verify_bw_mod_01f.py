#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
screen_path = ROOT / "lib/features/personal_plan/presentation/personal_recovery_plan_screen.dart"
body_path = ROOT / "lib/features/personal_plan/presentation/widgets/personal_recovery_plan_body.dart"
controllers_path = ROOT / "lib/features/personal_plan/presentation/personal_recovery_plan_draft_controllers.dart"
workflow_path = ROOT / "lib/features/personal_plan/application/personal_recovery_plan_workflow.dart"
session_path = ROOT / "lib/features/personal_plan/application/personal_recovery_plan_session.dart"

for path in [screen_path, body_path, controllers_path, workflow_path, session_path]:
    if not path.is_file():
        print("FAIL BW-MOD-01F: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


test_path = ROOT / "test/personal_recovery_plan_session_test.dart"
if not test_path.is_file():
    print("FAIL BW-MOD-01F: session test missing")
    sys.exit(1)
tests = test_path.read_text(encoding="utf-8")

for token in [
    "class PersonalRecoveryPlanSession",
    "Future<PersonalRecoveryPlanLoadResult> load()",
    "Future<PersonalRecoveryPlanImportResult> importCurrentChoices",
    "Future<PersonalRecoveryPlanSaveResult> save",
    "bool canSave",
    "PersonalRecoveryPlanStore",
]:
    source = session if token != "PersonalRecoveryPlanStore" else screen
    if token not in source:
        print(f"FAIL BW-MOD-01F: session contract missing: {token}")
        sys.exit(1)

for forbidden in [
    "BuildContext",
    "Widget",
    "TextEditingController",
    "setState(",
    "showDialog",
    "Navigator.",
]:
    if forbidden in session:
        print(f"FAIL BW-MOD-01F: session owns UI behavior: {forbidden}")
        sys.exit(1)

for token in [
    "_session.load()",
    "_session.importCurrentChoices",
    "_session.canSave",
    "_session.save",
    "WillPopScope",
    "Discard unsaved changes?",
]:
    if token not in screen:
        print(f"FAIL BW-MOD-01F: screen integration missing: {token}")
        sys.exit(1)

for forbidden in [
    "await PersonalRecoveryPlanStore.load()",
    "await RecoveryModeStore.loadMode()",
    "await PersonalRecoveryPlanStore.save(",
    "await _workflow.refreshFromBreakWave",
]:
    if forbidden in screen:
        print(f"FAIL BW-MOD-01F: screen still owns orchestration: {forbidden}")
        sys.exit(1)

for token in [
    "load returns saved plan mode and source-update state",
    "load failure returns the existing safe error message",
    "import reports changed content and preservation wording",
    "import failure preserves the current plan",
    "empty draft validation stays synchronous",
    "save prepares timestamps and returns the saved plan",
    "save failure keeps the existing draft-safe wording",
]:
    if token not in tests:
        print(f"FAIL BW-MOD-01F: session test marker missing: {token}")
        sys.exit(1)


print("PASS: BW-MOD-01F plan-session orchestration extracted without user-facing changes.")
