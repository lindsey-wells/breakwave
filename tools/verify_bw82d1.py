from pathlib import Path
import sys

path = Path("lib/features/rescue/presentation/widgets/calm_reset_card.dart")
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-82D1 clears the settle-pause flag before the next round starts.",
    "if (_activeStep == _steps.length - 1 && !_isPostStepPause)",
    "_isPostStepPause = true;",
    "Let it settle",
    """setState(() {
          _isPostStepPause = false;
          _completedRounds = nextRoundCount;
          _activeStep = 0;
          _remainingSeconds = _steps.first.seconds;
        });""",
    """setState(() {
            _isRunning = false;
            _isPostStepPause = false;
            _activeStep = -1;
            _remainingSeconds = 0;
            _completedRounds = nextRoundCount;
          });""",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-82D1 Calm Reset pause flag fix missing: {needle}")
        sys.exit(1)

if "onPressed: () {}" in text:
    print("FAIL BW-82D1 Calm Reset contains a dead button callback")
    sys.exit(1)

print("PASS: BW-82D1 Calm Reset settle flag reset verified.")
