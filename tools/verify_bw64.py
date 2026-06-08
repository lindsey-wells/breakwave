from pathlib import Path
import sys

app_bar = Path("lib/core/ui/breakwave_app_bar.dart")
note = Path("launch/brand_header_mark.md")

checks = [
    (app_bar, [
        "Purpose: BW-64 branded app header.",
        "_BreakWaveBrandMark",
        "_BreakWaveBrandPainter",
        "BreakWave ocean mark",
        "CustomPaint",
        "cubicTo",
        "canvas.drawCircle",
        "'BreakWave'",
        "sectionTitle",
    ]),
    (note, [
        "BW-64 Header Brand Mark",
        "three-line menu icon",
        "Flutter-drawn circular ocean badge",
        "horizontal wordmark asset",
    ]),
]

failed = False

for path, needles in checks:
    if not path.exists():
        print(f"FAIL missing file: {path}")
        failed = True
        continue

    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            print(f"FAIL {path} missing: {needle}")
            failed = True

app_text = app_bar.read_text(encoding="utf-8")

if "Icons.waves_rounded" in app_text:
    print("FAIL app bar still uses Icons.waves_rounded")
    failed = True

if "Icons.menu" in app_text:
    print("FAIL app bar should not use a menu-like icon")
    failed = True

if "_BreakWaveBrandMark" not in app_text:
    print("FAIL app bar is missing the custom BreakWave brand mark")
    failed = True

if "_BreakWaveBrandPainter" not in app_text:
    print("FAIL app bar is missing the custom BreakWave brand painter")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-64 header brand mark verified.")
