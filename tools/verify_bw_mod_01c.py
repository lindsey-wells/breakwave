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
        print("FAIL BW-MOD-01C: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


for token in [
    "class PersonalRecoveryPlanDraftControllers",
    "void applyPlan(PersonalRecoveryPlan plan)",
    "PersonalRecoveryPlan currentDraft()",
    "void toggleSuggestion(",
    "removeListener(_handleChanged)",
]:
    if token not in controllers:
        print(f"FAIL BW-MOD-01C: controller token missing: {token}")
        sys.exit(1)
for forbidden in ["TextEditingController", "_parseLines", "_writeLines"]:
    if forbidden in screen:
        print(f"FAIL BW-MOD-01C: screen owns controller detail: {forbidden}")
        sys.exit(1)


print("PASS: BW-MOD-01C draft-controller extraction remains intact.")
