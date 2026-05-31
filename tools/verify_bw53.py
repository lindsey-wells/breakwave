from pathlib import Path
import sys

checks = [
    ("launch/play_integrity_licensing_spike.md", [
        "Play Integrity / Licensing Research Spike",
        "This is a research and decision pass only.",
        "Play upload signing key",
        "Runtime licensing / integrity check",
        "Google Play Licensing",
        "Play Integrity API",
        "not a magic anti-cloning shield",
        "Do not add runtime blocking before first internal test.",
        "allow Rescue to keep working",
        "Do not hardcode a secret license key inside the Flutter app.",
        "Defer runtime Play Integrity / Licensing until after internal testing",
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

print("PASS: BW-53 Play Integrity / Licensing research spike verified.")
