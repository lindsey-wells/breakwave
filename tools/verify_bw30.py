from pathlib import Path
import sys

checks = [
    ("lib/core/ui/wave_surface.dart", [
        "class WaveSurface",
        "class _WaveSurfacePainter",
        "class _GlowOrb",
        "CustomPaint",
        "LinearGradient(",
        "Color(0xFF163F69)",
        "quadraticBezierTo(",
    ]),
    ("lib/features/rescue/presentation/widgets/wave_timer_card.dart", [
        "class WaveTimerCard",
        "_resetTimerState()",
        "Start 90-second timer",
        "Lower now",
        "Still strong",
        "I slipped",
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

print("PASS: BW-30 ocean polish verified.")
