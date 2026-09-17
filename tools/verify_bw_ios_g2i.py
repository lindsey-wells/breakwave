#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
failed = False

def read(rel):
    global failed
    p=ROOT/rel
    if not p.is_file():
        print(f"FAIL missing: {rel}"); failed=True; return ""
    return p.read_text(encoding='utf-8')

def require(text, needle, label):
    global failed
    if needle not in text:
        print(f"FAIL {label} missing: {needle}"); failed=True

unlock=read('lib/features/privacy_lock/presentation/privacy_unlock_screen.dart')
controller=read('lib/core/privacy_lock/privacy_session_controller.dart')
test=read('test/privacy_unlock_screen_test.dart')
biometric=read('ios/Runner/BreakWaveBiometricAuthenticator.swift')
bridge=read('ios/Runner/BreakWavePrivacyBridge.swift')
shield=read('ios/Runner/BreakWavePrivacyShieldCoordinator.swift')
scene=read('ios/Runner/SceneDelegate.swift')
plist=read('ios/Runner/Info.plist')
project=read('ios/Runner.xcodeproj/project.pbxproj')

for n in ('Future<PrivacyBiometricStatus> biometricStatus()', 'await _credentialGateway.biometricStatus()'):
    require(controller,n,'controller biometric availability')
for n in ('Use Face ID / Touch ID','widget.controller.biometricStatus()','widget.controller.unlockWithBiometrics()','PrivacyBiometricStatus.available','6-digit PIN'):
    require(unlock,n,'biometric unlock UI')
for n in ('available enabled biometrics unlock without removing PIN fallback','unavailable biometrics remain hidden and PIN stays available','biometric failure does not increment PIN failure counter'):
    require(test,n,'biometric widget tests')
require(unlock, r"RegExp(r'^\d{6}$')", 'six-digit PIN regex')
if r"RegExp(r'^\\d{6}$')" in unlock:
    print('FAIL PIN regex contains doubled raw-string backslash'); failed=True
require(biometric,'.deviceOwnerAuthenticationWithBiometrics','native biometrics-only policy')
if '.deviceOwnerAuthentication,' in biometric:
    print('FAIL generic device owner auth would permit passcode fallback'); failed=True
for n in ('guard try credentialStore.isConfigured() else','case "authenticateBiometric":'):
    require(bridge,n,'credential prerequisite')
for n in ('<key>NSFaceIDUsageDescription</key>','BreakWave uses Face ID to unlock your private recovery information when you enable privacy lock.'):
    require(plist,n,'Face ID usage')
for n in ('final class BreakWavePrivacyShieldCoordinator','func sceneWillResignActive(_ scene: UIScene)','func sceneDidEnterBackground(_ scene: UIScene)','func sceneDidBecomeActive(_ scene: UIScene)','showShield(in: scene)','removeShield(in: scene)','accessibilityIdentifier = "breakwave.privacyShield"','scene.activationState == .foregroundActive'):
    require(shield,n,'native privacy shield')
for n in ('privacyShieldCoordinator.sceneWillResignActive(scene)','privacyShieldCoordinator.sceneDidEnterBackground(scene)','super.sceneDidBecomeActive(scene)','privacyShieldCoordinator.sceneDidBecomeActive(scene)'):
    require(scene,n,'SceneDelegate shield wiring')
for n in ('BreakWavePrivacyShieldCoordinator.swift in Sources','path = BreakWavePrivacyShieldCoordinator.swift'):
    require(project,n,'Xcode project membership')
for forbidden in ('Personal Why','LogRepository','trusted contact','RevenueCat'):
    if forbidden in shield:
        print(f'FAIL privacy shield contains protected/product dependency: {forbidden}'); failed=True
if failed: raise SystemExit(1)
print('PASS: IOS-G2I wires enabled/available biometrics with PIN fallback, preserves biometrics-only native policy, adds Face ID usage text, and installs a native app-switcher privacy shield independent of relock grace.')
