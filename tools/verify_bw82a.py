from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
card = (root / "lib/features/rescue/presentation/widgets/remember_why_card.dart").read_text(encoding="utf-8")

required = [
    "BW-82A lets the user add or edit their why directly in Rescue.",
    "import '../../../../core/why/custom_why_image_service.dart';",
    "late final TextEditingController _whyController;",
    "bool _editing = false;",
    "bool _saving = false;",
    "String _imagePath = '';",
    "void _startEditing()",
    "Future<void> _saveWhy() async",
    "Future<void> _chooseImage() async",
    "Future<void> _removeImage() async",
    "Your saved why will appear here during Rescue. Add one now",
    "label: const Text('Add your why here')",
    "label: const Text('Edit why')",
    "class _WhyEditor",
    "labelText: 'Why statement'",
    "label: const Text('Choose why image')",
    "label: const Text('Remove image')",
    "Save why for Rescue",
    "Your why is saved for Rescue.",
    "Why image saved for Rescue.",
    "CustomWhyStore.save",
    "CustomWhyImageService.pickAndPersistWhyImage",
    "CustomWhyImageService.deleteImageIfPresent",
]

for needle in required:
    if needle not in card:
        print(f"FAIL BW-82A Rescue inline why missing: {needle}")
        sys.exit(1)

for forbidden in [
    "label: const Text('Add your why in Support')",
]:
    if forbidden in card:
        print(f"FAIL BW-82A still sends empty Rescue why setup to Support: {forbidden}")
        sys.exit(1)

print("PASS: BW-82A inline Rescue why setup verified.")
