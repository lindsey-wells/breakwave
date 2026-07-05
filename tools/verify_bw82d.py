from pathlib import Path
import sys

path = Path("lib/features/rescue/presentation/widgets/calm_reset_card.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-82D adds a short settle pause after the exhale step.",
    "static const int _postStepPauseSeconds = 2;",
    "bool _isPostStepPause = false;",
    "_isPostStepPause = false;",
    "if (_activeStep == _steps.length - 1 && !_isPostStepPause)",
    "_isPostStepPause = true;",
    "_remainingSeconds = _postStepPauseSeconds;",
    "Let it settle",
    "Three calm reset rounds completed. Choose the next right action.",
    "One calm reset round completed. Starting the next round.",
    "Reset started. Breathe through the steps one round at a time.",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-82D Calm Reset pause missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-82D Calm Reset contains a dead button callback")
    sys.exit(1)

print("PASS: BW-82D Calm Reset settle pause verified.")
