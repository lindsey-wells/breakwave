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
        print("FAIL BW-MOD-01B: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


widgets_path = ROOT / "lib/features/personal_plan/presentation/widgets/personal_recovery_plan_widgets.dart"
if not widgets_path.is_file():
    print("FAIL BW-MOD-01B: widget module missing")
    sys.exit(1)
widgets = widgets_path.read_text(encoding="utf-8")
for name in ["PersonalPlanListField", "PersonalPlanSectionTitle", "PersonalPlanCard"]:
    if f"class {name}" not in widgets or name not in body:
        print(f"FAIL BW-MOD-01B: widget contract missing: {name}")
        sys.exit(1)
for forbidden in ["PersonalRecoveryPlanStore", "LogRepository", "Future<", "async"]:
    if forbidden in widgets:
        print(f"FAIL BW-MOD-01B: widget owns behavior: {forbidden}")
        sys.exit(1)


print("PASS: BW-MOD-01B presentation-only widget extraction remains intact.")
