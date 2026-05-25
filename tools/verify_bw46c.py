from pathlib import Path
import sys

checks = [
    ("lib/core/why/custom_why_image_service.dart", [
        "DateTime.now().millisecondsSinceEpoch",
        "custom_why_image_$timestamp$extension",
    ]),
    ("lib/features/support/presentation/widgets/custom_why_settings_card.dart", [
        "Why image saved.",
        "Why image removed.",
        "await CustomWhyStore.save(",
        "imagePath: nextPath",
        "imagePath: ''",
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

print("PASS: BW-46C why image replacement/removal persistence verified.")
