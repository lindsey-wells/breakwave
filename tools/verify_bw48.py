from pathlib import Path
import sys

checks = [
    ("lib/core/email_capture/email_app_handoff_service.dart", [
        "static const String defaultTeamEmailAddress = 'BreakWaveapp@proton.me';",
        "BreakWave email / consent handoff",
        "Marketing updates consent:",
        "Research / feedback consent:",
        "Source: BreakWave Android MVP",
        "Privacy note: this handoff is manual.",
        "final String recipient = handoffSettings.hasRecipient",
        "path: recipient",
    ]),
    ("lib/features/support/presentation/widgets/email_app_handoff_card.dart", [
        "BreakWave recipient email",
        "EmailAppHandoffService.defaultTeamEmailAddress",
        "Using default BreakWave team email.",
        "Default inbox:",
        "Save email preferences first, then send the handoff when ready.",
        "onPressed: (!_working && hasData) ? _openDraft : null",
    ]),
    ("launch/email_app_handoff_setup.md", [
        "BW-48 launch polish",
        "BreakWaveapp@proton.me",
        "manual email handoff",
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

print("PASS: BW-48 email collection and handoff polish verified.")
