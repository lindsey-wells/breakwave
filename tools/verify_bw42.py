from pathlib import Path
import sys

checks = [
    ("lib/core/email_capture/email_capture_settings.dart", [
        "class EmailCaptureSettings",
        "emailAddress",
        "marketingOptIn",
        "researchOptIn",
        "hasAnyConsent",
    ]),
    ("lib/core/email_capture/email_capture_store.dart", [
        "class EmailCaptureStore",
        "bw_email_capture_v1",
        "ValueNotifier<int>",
        "changes",
        "save(EmailCaptureSettings settings)",
    ]),
    ("lib/features/support/presentation/widgets/email_capture_settings_card.dart", [
        "class EmailCaptureSettingsCard",
        "Stay in touch",
        "BreakWave help works without email.",
        "Email address",
        "Send me product updates",
        "Invite me to research or feedback",
        "Save email preferences",
        "Clear email preferences",
    ]),
    ("lib/features/support/presentation/support_screen.dart", [
        "EmailCaptureSettingsCard",
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

print("PASS: BW-42 optional email capture and consent verified.")
