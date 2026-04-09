from pathlib import Path
import sys

checks = [
    ("pubspec.yaml", [
        "share_plus:",
        "cross_file:",
    ]),
    ("lib/core/email_capture/email_export_service.dart", [
        "class EmailExportService",
        "buildCsv",
        "buildJson",
        "exportCsvFile",
        "exportJsonFile",
        "shareExportBundle",
        "SharePlus.instance.share",
        "XFile(",
        "breakwave_email_export_",
    ]),
    ("lib/features/support/presentation/widgets/email_export_card.dart", [
        "class EmailExportCard",
        "Email export",
        "Export CSV",
        "Export JSON",
        "Share export bundle",
        "Manual export only.",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "EmailExportCard",
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

print("PASS: BW-43 email export verified.")
