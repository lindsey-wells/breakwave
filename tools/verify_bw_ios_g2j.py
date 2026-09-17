#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
failed = False

def read(rel: str) -> str:
    global failed
    path = ROOT / rel
    if not path.is_file():
        print(f"FAIL missing: {rel}")
        failed = True
        return ""
    return path.read_text(encoding="utf-8")

def require(text: str, needle: str, label: str) -> None:
    global failed
    if needle not in text:
        print(f"FAIL {label} missing: {needle}")
        failed = True

plist = read("ios/Runner/Info.plist")
project = read("ios/Runner.xcodeproj/project.pbxproj")

require(
    plist,
    "<key>CFBundleDisplayName</key>\n\t<string>BreakWave</string>",
    "BreakWave display name",
)
if "<string>Breakwave</string>" in plist:
    print("FAIL legacy Breakwave capitalization remains")
    failed = True

deployment = "IPHONEOS_DEPLOYMENT_TARGET = 16.0;"
if project.count(deployment) != 3:
    print(
        "FAIL expected exactly 3 iOS 16 deployment-target settings; "
        f"found {project.count(deployment)}"
    )
    failed = True
if "IPHONEOS_DEPLOYMENT_TARGET = 13.0;" in project:
    print("FAIL legacy iOS 13 deployment target remains")
    failed = True

iphone_family = 'TARGETED_DEVICE_FAMILY = "1";'
if project.count(iphone_family) != 3:
    print(
        "FAIL expected exactly 3 iPhone-only device-family settings; "
        f"found {project.count(iphone_family)}"
    )
    failed = True
if 'TARGETED_DEVICE_FAMILY = "1,2";' in project:
    print("FAIL iPad remains in targeted device family")
    failed = True

require(
    project,
    "PRODUCT_BUNDLE_IDENTIFIER = com.cube23.breakwave;",
    "existing unsigned project bundle identifier",
)
if "PRODUCT_BUNDLE_IDENTIFIER = com.breakwaveapp.breakwave;" in project:
    print("FAIL permanent bundle identifier changed before owner approval")
    failed = True

for needle in (
    "<key>NSFaceIDUsageDescription</key>",
    "BreakWavePrivacyShieldCoordinator.swift in Sources",
):
    require(plist + project, needle, "G2I privacy configuration")

if failed:
    raise SystemExit(1)

print(
    "PASS: IOS-G2J locks BreakWave display capitalization, iOS 16 minimum "
    "deployment, and iPhone-only device family while preserving the existing "
    "bundle identifier until owner approval."
)
