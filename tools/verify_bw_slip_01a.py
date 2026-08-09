#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODEL = ROOT / "lib/features/log/domain/log_entry.dart"
SCREEN = ROOT / "lib/features/log/presentation/log_screen.dart"
WIDGET = ROOT / "lib/features/log/presentation/widgets/slip_follow_up_card.dart"
TEST = ROOT / "test/slip_follow_up_card_test.dart"

for path in [MODEL, SCREEN, WIDGET, TEST]:
    if not path.is_file():
        print("FAIL BW-SLIP-01A missing: " + str(path.relative_to(ROOT)))
        raise SystemExit(1)

model = MODEL.read_text(encoding="utf-8")
screen = SCREEN.read_text(encoding="utf-8")
widget = WIDGET.read_text(encoding="utf-8")
test = TEST.read_text(encoding="utf-8")
failed = False

def require(text, needle, label):
    global failed
    if needle not in text:
        print("FAIL BW-SLIP-01A " + label + " missing: " + needle)
        failed = True

for needle in ["slipEntryType = 'Slip'", "bool get isSlip"]:
    require(model, needle, "LogEntry")

for needle in [
    "slip_follow_up_card.dart",
    "bool get _isSlipDraft",
    "SlipFollowUpCard(",
    "You came back and captured what happened.",
]:
    require(screen, needle, "LogScreen")

for needle in [
    "'After a slip'",
    "'Recognize'",
    "'Interrupt'",
    "'Redirect'",
    "'Reinforce'",
    "'What was happening just before?'",
    "'What could you notice earlier next time?'",
    "'What will you do next?'",
    "'Open Rescue now'",
    "'You came back and looked at what happened. '",
    "'That matters.'",
]:
    require(widget, needle, "SlipFollowUpCard")

for forbidden in [
    "Upgrade",
    "upgrade",
    "BreakWave Plus",
    "paywall",
    "You failed",
    "you failed",
    "failure",
    "back to zero",
    "streak reset",
]:
    if forbidden in widget:
        print("FAIL BW-SLIP-01A shame/paywall language present: " + forbidden)
        failed = True

for needle in [
    "log-entry-type-Slip",
    "slip-follow-up-card",
    "slip-open-rescue-now",
    "expect(entry.isSlip, isTrue)",
]:
    require(test, needle, "Flutter test")

if failed:
    raise SystemExit(1)

print("PASS: BW-SLIP-01A compassionate Slip Follow-Up foundation verified.")
