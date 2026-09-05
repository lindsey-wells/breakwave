#!/usr/bin/env python3
from pathlib import Path

ROOT = Path.cwd()
failures = []

def read(path):
    p = ROOT / path
    if not p.is_file():
        failures.append(f"missing file: {path}")
        return ""
    return p.read_text(encoding="utf-8")

badge = read("lib/features/premium/presentation/breakwave_plus_badge.dart")
button = read("lib/features/premium/presentation/breakwave_plus_access_button.dart")
screen = read("lib/features/premium/presentation/breakwave_plus_screen.dart")
shell = read("lib/features/shell/presentation/breakwave_shell.dart")
support = read("lib/features/support/presentation/support_screen.dart")
reminder = read(
    "lib/features/support/presentation/widgets/reminder_settings_card.dart"
)
pubspec = read("pubspec.yaml")

required_badge = [
    "class BreakWavePlusBadge",
    "LinearGradient(",
    "FontWeight.w900",
    "Color(0xFF3DA8DC)",
    "Text(",
    "'+'",
]
for needle in required_badge:
    if needle not in badge:
        failures.append(f"badge missing: {needle}")

if "BreakWavePlusBadge(" not in button:
    failures.append("persistent Plus button does not use shared badge")
if "size: 62" not in button:
    failures.append("persistent Plus badge is not enlarged to 62")
if "BreakWavePlusBadge(" not in screen:
    failures.append("Plus status card does not use shared badge")
if "Icons.workspace_premium" in screen:
    failures.append("Plus status card retains ribbon premium icon")

if "_selectedIndex != 1" in shell:
    failures.append("Rescue is still excluded from persistent Plus access")
if "_selectedIndex < 4" not in shell:
    failures.append("customer Plus visibility is not limited to public tabs")

if "icon: Icons.workspace_premium_outlined" in support:
    failures.append("Support retains old ribbon Plus icon")
if "title: 'Explore BreakWave Plus'" in support and "icon: Icons.add_rounded" not in support:
    failures.append("Support Plus group does not use Plus glyph")

if reminder.count("if (!kReleaseMode) ...<Widget>[") != 2:
    failures.append("notification QA release-mode gates changed")
for needle in [
    "Notification readiness",
    "Send test notification",
    "Schedule 5-minute check",
    "Precise reminder timing",
    "Notification settings",
    "App settings",
]:
    if needle not in reminder:
        failures.append(f"reminder contract missing: {needle}")

if "version: 1.0.1+5" not in pubspec:
    failures.append("pubspec version is not 1.0.1+5")

if failures:
    print("BW SEP07 RC3 verification failed:")
    for failure in failures:
        print(f" - {failure}")
    raise SystemExit(1)

print(
    "PASS: BW SEP07 RC3 branded Plus badge, Rescue access, "
    "Plus-screen badge consistency, Support glyph cleanup, "
    "notification release gates, and version 1.0.1+5 verified."
)
