from pathlib import Path
import sys

checks = [
    ("lib/core/why/custom_why_fullscreen_image_viewer.dart", [
        "class CustomWhyFullscreenImageViewer",
        "MaterialPageRoute<void>",
        "fullscreenDialog: true",
        "InteractiveViewer",
        "Pinch to zoom. Drag to move.",
        "Saved why image could not be loaded.",
        "IconButton.filledTonal",
    ]),
    ("lib/features/rescue/presentation/widgets/remember_why_card.dart", [
        "CustomWhyFullscreenImageViewer",
        "class _WhyImagePreview extends StatelessWidget",
        "Open saved why image full screen",
        "custom-why-rescue-image",
        "Tap to enlarge",
    ]),
    ("lib/features/support/presentation/widgets/custom_why_settings_card.dart", [
        "CustomWhyFullscreenImageViewer",
        "class _EditableWhyImagePreview extends StatelessWidget",
        "Open saved why image full screen",
        "custom-why-settings-image",
        "Tap to enlarge",
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

print("PASS: BW-46 custom why fullscreen image viewer verified.")
