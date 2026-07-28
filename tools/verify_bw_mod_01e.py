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
        print("FAIL BW-MOD-01E: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


for token in [
    "class PersonalRecoveryPlanBody extends StatelessWidget",
    "Build a plan you can actually use",
    "Refresh from current BreakWave choices",
    "Faith support",
    "Save recovery plan",
]:
    if token not in body:
        print(f"FAIL BW-MOD-01E: body token missing: {token}")
        sys.exit(1)
for forbidden in ["PersonalRecoveryPlanStore", "setState(", "showDialog", "WillPopScope"]:
    if forbidden in body:
        print(f"FAIL BW-MOD-01E: body owns non-presentation behavior: {forbidden}")
        sys.exit(1)
if "PersonalRecoveryPlanBody(" not in screen:
    print("FAIL BW-MOD-01E: screen body wiring missing")
    sys.exit(1)


print("PASS: BW-MOD-01E form-body extraction remains intact.")
