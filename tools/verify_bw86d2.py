from pathlib import Path
import sys

path = Path(
    "lib/features/support/presentation/widgets/email_app_handoff_card.dart"
)
text = path.read_text(encoding="utf-8")

required = [
    "Notes: BW-86D2 removes internal recipient configuration from the public UI.",
    "EmailAppHandoffService.defaultTeamEmailAddress",
    "Future<void> _openFeedbackEmail()",
    "BreakWave feedback",
    "Open a prefilled email to",
    "Nothing leaves your device until you tap Send in your email app.",
    "Open feedback email",
    "FilledButton.icon(",
    "width: double.infinity",
    "launchUrl(",
    "LaunchMode.externalApplication",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86D2 simplified feedback card missing: {needle}")
        sys.exit(1)

build_start = text.find("  Widget build(BuildContext context)")
if build_start == -1:
    print("FAIL BW-86D2 build method not found")
    sys.exit(1)

visible_ui = text[build_start:]

for old_ui in [
    "BreakWave recipient email",
    "Save recipient email",
    "Use default email",
    "Open email draft",
    "Saved email-consent data is ready to send.",
    "Save preferences on this device first",
    "TextField(",
]:
    if old_ui in visible_ui:
        print(f"FAIL BW-86D2 old public UI remains: {old_ui}")
        sys.exit(1)

if text.count("FilledButton.icon(") != 1:
    print("FAIL BW-86D2 feedback card should contain one primary action")
    sys.exit(1)

print("PASS: BW-86D2 simplified feedback email card verified.")
