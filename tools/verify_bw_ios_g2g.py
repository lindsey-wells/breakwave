#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SAFE = ROOT / "lib/features/rescue/presentation/rescue_safe_screen.dart"
SHELL = ROOT / "lib/features/shell/presentation/breakwave_shell.dart"
TEST = ROOT / "test/rescue_safe_screen_test.dart"
IAP = ROOT / "docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md"

failed = False


def read(path: Path, label: str) -> str:
    global failed
    if not path.is_file():
        print(f"FAIL missing {label}: {path.relative_to(ROOT)}")
        failed = True
        return ""
    return path.read_text(encoding="utf-8")


safe = read(SAFE, "RescueSafeScreen")
shell = read(SHELL, "BreakWaveShell")
test = read(TEST, "RescueSafeScreen tests")
iap = read(IAP, "IOS-G2 architecture plan")


def require(text: str, needle: str, label: str) -> None:
    global failed
    if needle not in text:
        print(f"FAIL {label} missing: {needle}")
        failed = True


for needle in (
    "class RescueSafeScreen",
    "UrgeIntensitySection(",
    "const CalmResetCard()",
    "60-second pause",
    "Choose a generic redirect",
    "Wave is easing",
    "Still strong",
    "Unlock BreakWave",
    "Back to privacy lock",
    "Nothing is saved to recovery history",
):
    require(safe, needle, "rescue-safe presentation")

allowed_imports = {
    "import 'dart:async';",
    "import 'package:flutter/material.dart';",
    "import 'widgets/calm_reset_card.dart';",
    "import 'widgets/urge_intensity_section.dart';",
}
actual_imports = {
    line.strip() for line in safe.splitlines() if line.startswith("import ")
}
if actual_imports != allowed_imports:
    print("FAIL rescue-safe import allowlist mismatch")
    print("EXPECTED:", sorted(allowed_imports))
    print("ACTUAL:", sorted(actual_imports))
    failed = True

for forbidden in (
    "LogRepository",
    "LogEntry",
    "RescueScreen(",
    "RememberWhyCard",
    "PersonalWhy",
    "SupportScreen",
    "TrustedContact",
    "BreakWavePlus",
    "RevenueCat",
    "Purchases",
    "PrivacyLockStore",
    "SharedPreferences",
    "saveEntry(",
    "onOpenLog",
    "onOpenSupport",
):
    if forbidden in safe:
        print(f"FAIL RescueSafeScreen references protected dependency: {forbidden}")
        failed = True

require(
    shell,
    "import '../../rescue/presentation/rescue_safe_screen.dart';",
    "shell RescueSafeScreen import",
)
require(shell, "body: RescueSafeScreen(", "shell rescue-safe wiring")
require(
    shell,
    "onUnlock: () => _requestUnlockFromLockedLanding(",
    "shell rescue-safe unlock gate",
)
require(
    shell,
    "onBackToLock: _privacySessionController.lockNow",
    "shell rescue-safe back-to-lock",
)

if "rescueSafeActive: true" in shell:
    print("FAIL shell still uses IOS-G2F holding surface for active Rescue-safe state")
    failed = True

for needle in (
    "Rescue-safe renders generic tools without protected recovery content",
    "Rescue-safe back action returns to privacy lock",
):
    require(test, needle, "G2G widget tests")

require(iap, "## IOS-G2G — Rescue-Safe Presentation", "IAP G2G stage")
require(iap, "Add `RescueSafeScreen`.", "IAP G2G screen contract")

if failed:
    raise SystemExit(1)

print(
    "PASS: IOS-G2G provides a dedicated data-minimized RescueSafeScreen, "
    "keeps the session locked, exposes only generic in-memory Rescue tools, "
    "routes Unlock BreakWave through the existing protected destination gate, "
    "and introduces no Log, Personal Why, Support, billing, or persistence dependency."
)
