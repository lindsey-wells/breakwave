from pathlib import Path
import sys

checks = [
    ("lib/features/rescue/presentation/widgets/calm_reset_card.dart", [
        "Start reset",
        "Reset started. Breathe through the steps one round at a time.",
        "ScaffoldMessenger.of(context).showSnackBar",
    ]),
    ("lib/features/rescue/presentation/widgets/support_escalation_card.dart", [
        "Purpose: BW-66 Support escalation card for Rescue.",
        "required this.onOpenSupport",
        "final VoidCallback onOpenSupport;",
        "onPressed: onOpenSupport",
        "Open Support",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "final VoidCallback onOpenSupport;",
        "required this.onOpenSupport",
        "SupportEscalationCard(",
        "onOpenSupport: widget.onOpenSupport",
    ]),
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "onOpenSupport: () => _onDestinationSelected(3)",
        "const SupportScreen()",
        "label: 'Support'",
    ]),
    ("launch/rescue_dead_button_cleanup.md", [
        "BW-66 Rescue Dead-Button Cleanup",
        "Start reset now gives immediate feedback",
        "Open Support now routes from Rescue to the Support tab",
        "Buttons in Rescue must either do something useful",
    ]),
]

failed = False

for rel_path, needles in checks:
    path = Path(rel_path)
    if not path.exists():
        print(f"FAIL missing file: {rel_path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {rel_path} missing: {needle}")
            failed = True

for rel_path in [
    "lib/features/rescue/presentation/widgets/calm_reset_card.dart",
    "lib/features/rescue/presentation/widgets/support_escalation_card.dart",
]:
    text = Path(rel_path).read_text(encoding="utf-8")
    if "onPressed: () {}" in text:
        print(f"FAIL {rel_path} still has a dead placeholder onPressed")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-66 Rescue dead-button cleanup verified.")
