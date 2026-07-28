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
        print("FAIL BW-MOD-01D: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


for token in [
    "class PersonalRecoveryPlanWorkflow",
    "String editableSignature",
    "String importSourceSignature",
    "bool hasChanges",
    "Future<PersonalRecoveryPlan> refreshFromBreakWave",
    "ReasonsStore.loadSelection()",
    "snapshot.topTriggers30Days",
]:
    if token not in workflow:
        print(f"FAIL BW-MOD-01D: workflow token missing: {token}")
        sys.exit(1)
for forbidden in ["BuildContext", "TextEditingController", "setState(", "showDialog"]:
    if forbidden in workflow:
        print(f"FAIL BW-MOD-01D: workflow owns UI behavior: {forbidden}")
        sys.exit(1)
if "workflow: workflow" not in screen or "PersonalRecoveryPlanSession" not in screen:
    print("FAIL BW-MOD-01D: workflow is not wired through session")
    sys.exit(1)


print("PASS: BW-MOD-01D refresh-workflow extraction remains intact.")
