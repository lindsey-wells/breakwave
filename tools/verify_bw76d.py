from pathlib import Path
import sys

checks = [
    ("lib/features/shell/presentation/breakwave_shell.dart", [
        "onOpenRescue: () => _onDestinationSelected(1)",
        "onOpenSupport: () => _onDestinationSelected(3)",
    ]),
    ("lib/features/log/presentation/log_screen.dart", [
        "BW-76D turns key replacement choices into real navigation actions.",
        "final VoidCallback onOpenRescue;",
        "final VoidCallback onOpenSupport;",
        "required this.onOpenRescue",
        "required this.onOpenSupport",
        "onOpenRescue: widget.onOpenRescue",
        "onOpenSupport: widget.onOpenSupport",
    ]),
    ("lib/features/log/presentation/widgets/log_cbt_reflection_card.dart", [
        "BW-76D adds real actions for Open Rescue and trusted support choices.",
        "final VoidCallback onOpenRescue;",
        "final VoidCallback onOpenSupport;",
        "selectedReplacementAction == 'Open Rescue'",
        "Open Rescue now",
        "onPressed: onOpenRescue",
        "selectedReplacementAction == 'Text someone safe'",
        "Open trusted support",
        "onPressed: onOpenSupport",
        "Use your saved trusted contact or support message from the Support tab.",
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

if failed:
    sys.exit(1)

print("PASS: BW-76D log replacement action navigation verified.")
