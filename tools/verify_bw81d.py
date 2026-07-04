from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]

home = (root / "lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
card = (root / "lib/features/home/presentation/widgets/recovery_snapshot_card.dart").read_text(encoding="utf-8")

home_required = [
    "RecoverySnapshotCard(",
    "totalEntries: summary.totalEntries",
    "urgeCount: summary.urgeCount",
    "slipCount: summary.slipCount",
    "victoryCount: summary.victoryCount",
    "onOpenLog: widget.onOpenLog",
]

card_required = [
    "BW-81D makes snapshot metrics tappable entry points to Log.",
    "final VoidCallback onOpenLog;",
    "required this.onOpenLog",
    "Tap any snapshot number to open your Log.",
    "Saved entries",
    "Urges",
    "Slips",
    "Victories",
    "onTap: onOpenLog",
    "Semantics(",
    "button: true",
    "Open Log.",
    "InkWell(",
    "const Icon(Icons.chevron_right, size: 18)",
]

for needle in home_required:
    if needle not in home:
        print(f"FAIL BW-81D home missing: {needle}")
        sys.exit(1)

for needle in card_required:
    if needle not in card:
        print(f"FAIL BW-81D snapshot card missing: {needle}")
        sys.exit(1)

if card.count("onTap: onOpenLog") < 4:
    print("FAIL BW-81D expected all four snapshot metrics to open Log")
    sys.exit(1)

print("PASS: BW-81D clickable Recovery Snapshot metrics verified.")
