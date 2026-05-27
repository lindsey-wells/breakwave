from pathlib import Path
import sys

checks = [
    ("lib/features/support/presentation/widgets/breakwave_contact_links_card.dart", [
        "class BreakWaveContactLinksCard",
        "BreakWaveapp@proton.me",
        "https://www.tiktok.com/@BreakWaveapp",
        "https://x.com/BreakWaveapp",
        "Connect with BreakWave",
        "BreakWave recovery tools work without following any social account.",
        "LaunchMode.externalApplication",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "breakwave_contact_links_card.dart",
        "BreakWaveContactLinksCard",
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

print("PASS: BW-48B BreakWave contact/social links verified.")
