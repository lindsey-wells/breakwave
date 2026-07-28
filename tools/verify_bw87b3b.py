from pathlib import Path
import sys

screen_path = Path(
    "lib/features/personal_plan/presentation/"
    "personal_recovery_plan_screen.dart"
)
session_path = Path(
    "lib/features/personal_plan/application/"
    "personal_recovery_plan_session.dart"
)
body_path = Path(
    "lib/features/personal_plan/presentation/widgets/"
    "personal_recovery_plan_body.dart"
)
plus_path = Path(
    "lib/features/premium/presentation/"
    "breakwave_plus_screen.dart"
)

for path in [screen_path, body_path, session_path, plus_path]:
    if not path.exists():
        print(f"FAIL BW-87B3B missing file: {path}")
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
body = body_path.read_text(encoding="utf-8")
session = session_path.read_text(encoding="utf-8")
ui = screen + "\n" + body
behavior = screen + "\n" + session
plus = plus_path.read_text(encoding="utf-8")

for needle in [
    "class PersonalRecoveryPlanScreen",
    "PersonalRecoveryPlanStore.load",
    "PersonalRecoveryPlanStore.save",
    "PersonalRecoveryPlanPrefill",
    "WillPopScope",
]:
    if needle not in behavior:
        print(f"FAIL BW-87B3B screen behavior missing: {needle}")
        sys.exit(1)

for needle in [
    "Use my current BreakWave choices",
    "Existing plan work will not be replaced.",
    "Why I am changing",
    "What I need to watch",
    "My first moves",
    "Support and boundaries",
    "After a slip",
    "Faith support",
    "Save recovery plan",
    "Personal recovery plan saved on this device.",
    "Discard unsaved changes?",
    "Calling and messaging details remain in Support.",
]:
    if needle not in ui + "\n" + session:
        print(f"FAIL BW-87B3B plan UI missing: {needle}")
        sys.exit(1)

for forbidden in [
    "phoneNumber:",
    "emailAddress:",
    "BedtimeModeStore",
    "BedtimeModeEntry",
]:
    if forbidden in ui:
        print(
            f"FAIL BW-87B3B duplicated/transient data: "
            f"{forbidden}"
        )
        sys.exit(1)

for needle in [
    "BW-87B3B adds a working personal recovery plan preview.",
    "PersonalRecoveryPlanScreen",
    "_openPersonalRecoveryPlan(context)",
    "Preview personal recovery plan",
]:
    if needle not in plus:
        print(f"FAIL BW-87B3B Plus integration missing: {needle}")
        sys.exit(1)

print(
    "PASS: BW-87B3B editable personal recovery "
    "plan screen verified."
)
