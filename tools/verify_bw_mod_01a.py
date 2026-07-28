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
        print("FAIL BW-MOD-01A: missing " + str(path.relative_to(ROOT)))
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
controllers = controllers_path.read_text(encoding="utf-8")
workflow = workflow_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + workflow + "\n" + session


for token in [
    "CircularProgressIndicator",
    "Plan unavailable",
    "Try again",
    "Unsaved changes",
    "Discard unsaved changes?",
    "Refresh from current BreakWave choices",
    "Personal recovery plan saved on this device.",
    "RecoveryMode.christian",
]:
    if token not in ui + "\n" + session:
        print(f"FAIL BW-MOD-01A: characterization token missing: {token}")
        sys.exit(1)

workflow_ci = (ROOT / ".github/workflows/breakwave-shadow-ci.yml").read_text(encoding="utf-8")
runner = (ROOT / ".github/scripts/run_breakwave_shadow_ci.py").read_text(encoding="utf-8")
for token in ["name: BreakWave Shadow CI", "validation/bw-mod-*", "run_breakwave_shadow_ci.py"]:
    if token not in workflow_ci:
        print(f"FAIL BW-MOD-01A: Shadow marker missing: {token}")
        sys.exit(1)
for token in ["flutter", "build", "appbundle", "verify_bw88rc1a.py", "verify_bw88rc1b.py"]:
    if token not in runner:
        print(f"FAIL BW-MOD-01A: runner marker missing: {token}")
        sys.exit(1)


print("PASS: BW-MOD-01A characterization and Shadow CI contract remain intact.")
