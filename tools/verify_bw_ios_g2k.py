#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bad=False
def r(p):
 global bad
 q=ROOT/p
 if not q.is_file(): print("FAIL missing:",p); bad=True; return ""
 return q.read_text(encoding="utf-8")
def req(t,n,l):
 global bad
 if n not in t: print(f"FAIL {l} missing: {n}"); bad=True
def forbid(t,n,l):
 global bad
 if n in t: print(f"FAIL {l} forbidden: {n}"); bad=True

for p in [f"tools/verify_bw_ios_g2{x}.py" for x in "abcdefghij"]:
 r(p)

freeze=r("docs/BW_IOS_G2K_INTEGRATION_FREEZE.md")
arch=r("docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md")
runner=r(".github/scripts/run_breakwave_shadow_ci.py")
android=r(".github/workflows/breakwave-shadow-ci.yml")
ios=r(".github/workflows/breakwave-ios-shadow-ci.yml")
session=r("lib/core/privacy_lock/privacy_session_state.dart")
policy=r("lib/core/privacy_lock/privacy_route_policy.dart")
config=r("lib/core/privacy_lock/privacy_lock_configuration.dart")
safe=r("lib/features/rescue/presentation/rescue_safe_screen.dart")
store=r("lib/features/rescue/data/rescue_safe_outcome_store.dart")
rec=r("lib/features/rescue/data/rescue_outcome_reconciler.dart")
key=r("ios/Runner/BreakWaveKeychainCredentialStore.swift")
pin=r("ios/Runner/BreakWavePinVerifier.swift")
bio=r("ios/Runner/BreakWaveBiometricAuthenticator.swift")
shield=r("ios/Runner/BreakWavePrivacyShieldCoordinator.swift")
scene=r("ios/Runner/SceneDelegate.swift")
plist=r("ios/Runner/Info.plist")
proj=r("ios/Runner.xcodeproj/project.pbxproj")

for n in ("Freeze base: `8da569b43c4a3997fe5e0de201fba0129ca003a3`","no runtime behavior changes","Android Shadow success","iOS Shadow success","Deferred to IOS-G3"):
 req(freeze,n,"freeze")
for n in ("## IOS-G2K — Integration Freeze","full Flutter tests","full BreakWave verifiers","Android APK/AAB CI","unsigned iOS Simulator build","privacy-contract static audit","source drift/evidence bundle","all remaining blockers require Apple signing/physical-device access rather than unresolved architecture"):
 req(arch,n,"architecture")

req(runner,'glob("verify_bw*.py")',"dynamic verifier discovery")
req(runner,'IOS_G2G_CLOSED_REF = "0c2a18df625cb1db7212cb3c570cb782effd0648"',"G2G pin")
req(runner,'"tools/verify_bw_ios_g2g.py": IOS_G2G_CLOSED_REF',"G2G routing")

for n in ("Checkout exact validation commit","python3 .github/scripts/run_breakwave_shadow_ci.py","Upload Shadow evidence","Upload Shadow APK","Upload Shadow AAB"): req(android,n,"Android Shadow")
for n in ("Checkout exact candidate commit","flutter analyze --no-fatal-infos","flutter test","flutter build ios --simulator --debug","Classify final generated iOS drift","Write machine-readable iOS Shadow evidence","Upload iOS Shadow evidence",'"signing_used": False','"apple_credentials_used": False'): req(ios,n,"iOS Shadow")

for n in ("locked","rescueSafe","authenticating","unlocked"): req(session,n,"session")
req(policy,"PrivacyDestination.unknown: PrivacyAccessClass.protected","fail-closed routing")
for n in ("passcode","rawpin","pinhash","pinverifier"): forbid(config.lower(),n,"v2 config")

for n in ("RememberWhyCard","LogRepository","LogEntry","SharedPreferences","saveEntry("): forbid(safe,n,"RescueSafeScreen")
for n in ("LogRepository","LogEntry","loadEntries","bw_log_entries_v1"): forbid(store,n,"pending store")
for n in ("await pendingStore.loadPending()","await logRepository.loadEntries()","await logRepository.saveEntry(_toLogEntry(outcome))","await pendingStore.removeIds(removeIds)"): req(rec,n,"reconciler")

for n in ('static let service = "com.breakwaveapp.breakwave.privacy-lock"',"kSecAttrAccessibleWhenUnlockedThisDeviceOnly","kSecClassGenericPassword"): req(key,n,"Keychain")
for n in ('private static let kdfName = "pbkdf2-hmac-sha256"',"CCKeyDerivationPBKDF","kCCPRFHmacAlgSHA256","SecRandomCopyBytes","constantTimeEqual","IOS-G3 must benchmark the oldest supported physical"): req(pin,n,"PIN verifier")
req(bio,".deviceOwnerAuthenticationWithBiometrics","biometric policy")
forbid(bio,".deviceOwnerAuthentication,","biometric policy")
for n in ("final class BreakWavePrivacyShieldCoordinator",'accessibilityIdentifier = "breakwave.privacyShield"',"scene.activationState == .foregroundActive"): req(shield,n,"shield")
for n in ("privacyShieldCoordinator.sceneWillResignActive(scene)","privacyShieldCoordinator.sceneDidEnterBackground(scene)","privacyShieldCoordinator.sceneDidBecomeActive(scene)"): req(scene,n,"SceneDelegate")

req(plist,"<key>CFBundleDisplayName</key>\n\t<string>BreakWave</string>","display name")
if proj.count("IPHONEOS_DEPLOYMENT_TARGET = 16.0;")!=3: print("FAIL iOS 16 target count"); bad=True
if proj.count('TARGETED_DEVICE_FAMILY = "1";')!=3: print("FAIL iPhone family count"); bad=True
req(proj,"PRODUCT_BUNDLE_IDENTIFIER = com.cube23.breakwave;","deferred bundle ID")
forbid(proj,"PRODUCT_BUNDLE_IDENTIFIER = com.breakwaveapp.breakwave;","permanent bundle ID")

if bad: raise SystemExit(1)
print("PASS: IOS-G2K freezes the integrated IOS-G2 privacy architecture and evidence paths; remaining acceptance work is Apple/signing/physical-device dependent.")
