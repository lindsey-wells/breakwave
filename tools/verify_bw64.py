from pathlib import Path
import struct
import sys

app_bar = Path("lib/core/ui/breakwave_app_bar.dart")
note = Path("launch/brand_header_mark.md")
asset = Path(
    "assets/branding/breakwave_in_app_header.png"
)

checks = [
    (
        app_bar,
        [
            "Purpose: BW-88RC1B approved asset-based BreakWave header.",
            "_brandAssetPath",
            "assets/branding/breakwave_in_app_header.png",
            "Image.asset(",
            "BreakWave brand wordmark",
            "Semantics(",
            "errorBuilder:",
            "sectionTitle",
        ],
    ),
    (
        note,
        [
            "BW-64 history",
            "BW-88RC1B finalization",
            "approved bundled horizontal wordmark",
            "breakwave_in_app_header.png",
        ],
    ),
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

if not asset.exists():
    print(f"FAIL missing file: {asset}")
    failed = True
else:
    data = asset.read_bytes()

    if data[:8] != b"\x89PNG\r\n\x1a\n":
        print("FAIL in-app header asset is not PNG")
        failed = True
    elif data[12:16] != b"IHDR":
        print("FAIL in-app header asset lacks PNG IHDR")
        failed = True
    else:
        width, height, bit_depth, color_type = struct.unpack(
            ">IIBB",
            data[16:26],
        )

        if (width, height) != (1392, 304):
            print(
                "FAIL in-app header dimensions: "
                f"{width}x{height}"
            )
            failed = True

        if bit_depth != 8 or color_type != 6:
            print(
                "FAIL in-app header should be 8-bit RGBA PNG"
            )
            failed = True

app_text = (
    app_bar.read_text(encoding="utf-8")
    if app_bar.exists()
    else ""
)

for obsolete in [
    "_BreakWaveBrandMark",
    "_BreakWaveBrandPainter",
    "CustomPaint",
    "canvas.drawCircle",
]:
    if obsolete in app_text:
        print(
            "FAIL app bar retains obsolete painter: "
            f"{obsolete}"
        )
        failed = True

if failed:
    sys.exit(1)

print(
    "PASS: BW-64 header intent is preserved "
    "through the approved BW-88RC1B wordmark asset."
)
