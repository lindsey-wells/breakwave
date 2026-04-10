from pathlib import Path
import sys

checks = [
    ("lib/core/email_capture/email_app_handoff_settings.dart", [
        "class EmailAppHandoffSettings",
        "teamEmailAddress",
        "hasRecipient",
    ]),
    ("lib/core/email_capture/email_app_handoff_store.dart", [
        "class EmailAppHandoffStore",
        "bw_email_app_handoff_v1",
        "ValueNotifier<int>",
        "changes",
    ]),
    ("lib/core/email_capture/email_app_handoff_service.dart", [
        "class EmailAppHandoffService",
        "buildSubject",
        "buildBody",
        "mailto",
        "launchUrl(",
        "LaunchMode.externalApplication",
        "BreakWave lead / consent submission",
    ]),
    ("lib/features/support/presentation/widgets/email_app_handoff_card.dart", [
        "class EmailAppHandoffCard",
        "Send to BreakWave team",
        "BreakWave team email",
        "Save team email",
        "Clear team email",
        "Send saved data now",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "EmailAppHandoffCard",
    ]),
    ("launch/email_app_handoff_setup.md", [
        "Email App Handoff Setup",
        "saved email address",
        "marketing opt-in",
        "research opt-in",
        "Send to BreakWave team",
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

print("PASS: BW-44B email app handoff verified.")
