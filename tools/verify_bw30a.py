from pathlib import Path
import sys

checks = [
    ("lib/core/ui/wave_surface.dart", [
        "class WaveSurface",
        "class _WaveSurfacePainter",
        "class _GlowOrb",
        "Color(0xFF163F69)",
        "Color(0xFF0E2B49)",
        "Color(0xFF09192D)",
        "Color(0xFF73C4FF)",
        "topWave",
        "lowWave",
        "quadraticBezierTo(",
    ]),
    ("lib/features/home/presentation/widgets/recovery_cycle_preview_card.dart", [
        "class RecoveryCyclePreviewCard",
        "Recovery cycle wheel",
        "Trigger → Urge → Escalation → Action → Regret / Recovery",
        "RecoveryCycleWheelScreen",
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

print("PASS: BW-30A ocean identity correction verified.")
