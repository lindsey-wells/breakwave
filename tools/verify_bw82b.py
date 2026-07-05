from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
rescue = (root / "lib/features/rescue/presentation/rescue_screen.dart").read_text(encoding="utf-8")
shell = (root / "lib/features/shell/presentation/breakwave_shell.dart").read_text(encoding="utf-8")

rescue_required = [
    "final VoidCallback onOpenLog;",
    "required this.onOpenLog",
    "bool _showWaveSavedFollowUp = false;",
    "_showWaveSavedFollowUp = true;",
    "_showWaveSavedFollowUp = false;",
    "snackBarText: 'Wave saved. You made it through this wave.'",
    "returnHome: false",
    "Widget _buildWaveSavedFollowUpCard(BuildContext context)",
    "'Wave saved'",
    "You made it through this wave. This victory was saved to your Log.",
    "onPressed: widget.onOpenLog",
    "label: const Text('Open Log')",
    "onPressed: widget.onReturnHome",
    "label: const Text('Return Home')",
    "label: const Text('Stay in Rescue')",
    "if (_showWaveSavedFollowUp) ...<Widget>[",
    "_buildWaveSavedFollowUpCard(context)",
]

shell_required = [
    "RescueScreen(",
    "onReturnHome: _returnHome",
    "onOpenSupport: () => _onDestinationSelected(3)",
    "onOpenLog: () => _onDestinationSelected(2)",
]

for needle in rescue_required:
    if needle not in rescue:
        print(f"FAIL BW-82B Rescue completion clarity missing: {needle}")
        sys.exit(1)

for needle in shell_required:
    if needle not in shell:
        print(f"FAIL BW-82B shell callback missing: {needle}")
        sys.exit(1)

if "snackBarText: 'Nice work. Wave saved with your next right action.'" in rescue:
    print("FAIL BW-82B old vague wave-save snackbar still present")
    sys.exit(1)

print("PASS: BW-82B Wave Completion save clarity verified.")
