from pathlib import Path
import sys

checks = [
    ("pubspec.yaml", [
        "image_picker:",
        "path_provider:",
    ]),
    ("lib/core/why/custom_why_entry.dart", [
        "class CustomWhyEntry",
        "whyText",
        "imagePath",
        "hasAnyContent",
    ]),
    ("lib/core/why/custom_why_store.dart", [
        "class CustomWhyStore",
        "bw_custom_why_v1",
        "ValueNotifier<int>",
        "changes",
        "save(CustomWhyEntry entry)",
    ]),
    ("lib/core/why/custom_why_image_service.dart", [
        "class CustomWhyImageService",
        "ImagePicker",
        "ImageSource.gallery",
        "getApplicationDocumentsDirectory()",
        "custom_why_image",
    ]),
    ("lib/features/support/presentation/widgets/custom_why_settings_card.dart", [
        "class CustomWhySettingsCard",
        "Custom why",
        "Why statement",
        "Choose why image",
        "Save custom why",
    ]),
    ("lib/features/rescue/presentation/widgets/remember_why_card.dart", [
        "class RememberWhyCard",
        "Remember why",
        "CustomWhyStore.changes.addListener",
        "CustomWhyStore.changes.removeListener",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "CustomWhySettingsCard",
    ]),
    ("lib/features/rescue/presentation/rescue_screen.dart", [
        "RememberWhyCard",
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

print("PASS: BW-39 custom why support verified.")
