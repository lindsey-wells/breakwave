#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
G2C_REF = "1a718ea0bcbdac31cd12bd2c747d5abe279c9cbc"

PBX = ROOT / "ios/Runner.xcodeproj/project.pbxproj"
RUNNER = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"

SWIFT_FILES = [
    "BreakWavePrivacyBridge.swift",
    "BreakWaveKeychainCredentialStore.swift",
    "BreakWavePinVerifier.swift",
    "BreakWaveBiometricAuthenticator.swift",
]

FILE_REF_IDS = {
    "BreakWavePrivacyBridge.swift": "B2D000000000000000000001",
    "BreakWaveKeychainCredentialStore.swift": "B2D000000000000000000002",
    "BreakWavePinVerifier.swift": "B2D000000000000000000003",
    "BreakWaveBiometricAuthenticator.swift": "B2D000000000000000000004",
}

BUILD_IDS = {
    "BreakWavePrivacyBridge.swift": "B2D000000000000000000101",
    "BreakWaveKeychainCredentialStore.swift": "B2D000000000000000000102",
    "BreakWavePinVerifier.swift": "B2D000000000000000000103",
    "BreakWaveBiometricAuthenticator.swift": "B2D000000000000000000104",
}


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"STOP IOS-G2D apply: expected one {label} anchor, found {count}"
        )
    return text.replace(old, new, 1)


def apply_pbx() -> None:
    text = PBX.read_text(encoding="utf-8")
    if all(FILE_REF_IDS[name] in text for name in SWIFT_FILES):
        return
    if any(FILE_REF_IDS[name] in text or BUILD_IDS[name] in text for name in SWIFT_FILES):
        raise SystemExit("STOP IOS-G2D apply: partial Xcode reference state detected")

    build_anchor = (
        "\t\t74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */ = "
        "{isa = PBXBuildFile; fileRef = 74858FAE1ED2DC5600515810 /* AppDelegate.swift */; };\n"
    )
    build_lines = "".join(
        f"\t\t{BUILD_IDS[name]} /* {name} in Sources */ = "
        f"{{isa = PBXBuildFile; fileRef = {FILE_REF_IDS[name]} /* {name} */; }};\n"
        for name in SWIFT_FILES
    )
    text = replace_once(text, build_anchor, build_anchor + build_lines, "PBXBuildFile")

    ref_anchor = (
        "\t\t74858FAE1ED2DC5600515810 /* AppDelegate.swift */ = "
        "{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; "
        "path = AppDelegate.swift; sourceTree = \"<group>\"; };\n"
    )
    ref_lines = "".join(
        f"\t\t{FILE_REF_IDS[name]} /* {name} */ = "
        f"{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; "
        f"path = {name}; sourceTree = \"<group>\"; }};\n"
        for name in SWIFT_FILES
    )
    text = replace_once(text, ref_anchor, ref_anchor + ref_lines, "PBXFileReference")

    group_anchor = "\t\t\t\t74858FAE1ED2DC5600515810 /* AppDelegate.swift */,\n"
    group_lines = "".join(
        f"\t\t\t\t{FILE_REF_IDS[name]} /* {name} */,\n"
        for name in SWIFT_FILES
    )
    text = replace_once(text, group_anchor, group_anchor + group_lines, "Runner PBXGroup")

    source_anchor = "\t\t\t\t74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */,\n"
    source_lines = "".join(
        f"\t\t\t\t{BUILD_IDS[name]} /* {name} in Sources */,\n"
        for name in SWIFT_FILES
    )
    text = replace_once(text, source_anchor, source_anchor + source_lines, "Sources build phase")

    PBX.write_text(text, encoding="utf-8")


def apply_phase_pin() -> None:
    text = RUNNER.read_text(encoding="utf-8")
    mapping_line = f'    "tools/verify_bw_ios_g2c.py": "{G2C_REF}",\n'
    if mapping_line not in text:
        anchor = (
            '\n    "tools/verify_bw_wp03r.py": '
            '"02136802599b5a286cf42d98217da7b4f696e50b",\n'
        )
        text = replace_once(text, anchor, anchor + mapping_line, "G2C phase mapping")

    expected_line = f'        "tools/verify_bw_ios_g2c.py": "{G2C_REF}",\n'
    if expected_line not in text:
        anchor = (
            '\n        "tools/verify_bw_wp03r.py": '
            '"02136802599b5a286cf42d98217da7b4f696e50b",\n'
        )
        text = replace_once(text, anchor, anchor + expected_line, "G2C selftest mapping")

    list_line = '            "tools/verify_bw_ios_g2c.py",\n'
    if list_line not in text:
        anchor = '\n            "tools/verify_bw_wp03r.py",\n'
        text = replace_once(text, anchor, anchor + list_line, "G2C selftest verifier list")

    RUNNER.write_text(text, encoding="utf-8")


def apply_stage() -> None:
    apply_pbx()
    apply_phase_pin()
    print("APPLIED: IOS-G2D Xcode source references and G2C historical verifier pin.")


def verify() -> None:
    failed = False

    paths = {
        "app_delegate": ROOT / "ios/Runner/AppDelegate.swift",
        "native_bridge": ROOT / "ios/Runner/BreakWavePrivacyBridge.swift",
        "keychain": ROOT / "ios/Runner/BreakWaveKeychainCredentialStore.swift",
        "pin_verifier": ROOT / "ios/Runner/BreakWavePinVerifier.swift",
        "biometric": ROOT / "ios/Runner/BreakWaveBiometricAuthenticator.swift",
        "dart_bridge": ROOT / "lib/core/privacy_lock/platform/privacy_native_bridge.dart",
        "ios_gateway": ROOT / "lib/core/privacy_lock/platform/ios_privacy_credential_gateway.dart",
        "composition": ROOT / "lib/core/privacy_lock/privacy_lock_composition.dart",
        "bridge_test": ROOT / "test/privacy_native_bridge_test.dart",
        "composition_test": ROOT / "test/privacy_lock_composition_test.dart",
        "pbx": PBX,
        "runner": RUNNER,
        "g2c_verifier": ROOT / "tools/verify_bw_ios_g2c.py",
        "legacy_adapter": ROOT / "lib/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart",
        "gateway_test": ROOT / "test/privacy_credential_gateway_test.dart",
        "iap": ROOT / "docs/BW_IOS_G2_IAP_1_0_IMPLEMENTATION_ARCHITECTURE.md",
    }

    for name, path in paths.items():
        if not path.is_file():
            print(f"FAIL missing {name}: {path.relative_to(ROOT)}")
            failed = True

    if failed:
        raise SystemExit(1)

    texts = {name: path.read_text(encoding="utf-8") for name, path in paths.items()}

    def require(name: str, needle: str) -> None:
        nonlocal failed
        if needle not in texts[name]:
            print(f"FAIL {name} missing: {needle}")
            failed = True

    require("app_delegate", "BreakWavePrivacyBridge.register(")
    require("app_delegate", "engineBridge.applicationRegistrar.messenger()")

    for method in [
        "credentialStatus",
        "configurePin",
        "verifyPin",
        "clearCredential",
        "biometricStatus",
        "authenticateBiometric",
    ]:
        require("native_bridge", f'case "{method}"')
        require("dart_bridge", f"'{method}'")

    require("native_bridge", 'static let channelName = "breakwave/privacy_auth"')
    require("dart_bridge", "static const String channelName = 'breakwave/privacy_auth';")

    for forbidden in ["print(", "NSLog", "debugPrint", "developer.log"]:
        for name in ["native_bridge", "keychain", "pin_verifier", "biometric", "dart_bridge"]:
            if forbidden in texts[name]:
                print(f"FAIL {name} logs privacy-auth material via {forbidden}")
                failed = True

    for needle in [
        'static let service = "com.breakwaveapp.breakwave.privacy-lock"',
        "kSecClassGenericPassword",
        "kSecAttrAccessibleWhenUnlockedThisDeviceOnly",
        "SecItemAdd",
        "SecItemUpdate",
        "SecItemCopyMatching",
        "SecItemDelete",
    ]:
        require("keychain", needle)

    for forbidden in ["UserDefaults", "FileManager", "SharedPreferences"]:
        if forbidden in texts["keychain"]:
            print(f"FAIL Keychain store contains forbidden persistence: {forbidden}")
            failed = True

    for needle in [
        "PBKDF2-HMAC-SHA256".lower(),
        "CCKeyDerivationPBKDF",
        "kCCPRFHmacAlgSHA256",
        "SecRandomCopyBytes",
        "constantTimeEqual",
        "provisionalIterations",
    ]:
        haystack = texts["pin_verifier"]
        if needle.lower() not in haystack.lower():
            print(f"FAIL pin_verifier missing: {needle}")
            failed = True

    if "passcode" in texts["keychain"].lower():
        print("FAIL Keychain record/store uses legacy passcode field")
        failed = True

    require("biometric", ".deviceOwnerAuthenticationWithBiometrics")
    require("biometric", "NSFaceIDUsageDescription")
    if ".deviceOwnerAuthentication," in texts["biometric"]:
        print("FAIL biometric authenticator permits device passcode policy")
        failed = True

    require("ios_gateway", "implements PrivacyCredentialGateway")
    require("composition", "IosPrivacyCredentialGateway()")

    for needle in [
        "on MissingPluginException",
        "on PlatformException",
        "return PrivacyAuthResult.error;",
        "return PrivacyBiometricStatus.unknown;",
    ]:
        require("dart_bridge", needle)

    require("bridge_test", "platform exceptions fail closed without escaping the bridge")
    require("bridge_test", "missing plugin failures are bounded")
    require("native_bridge", "guard try credentialStore.isConfigured() else")
    require("keychain", "private func decodeRecord(")
    require("keychain", "try verifier.validateRecord(record)")
    require("pin_verifier", "func validateRecord(")

    if "ArgumentError.value(" in texts["legacy_adapter"]:
        print("FAIL G2C legacy adapter can echo candidate PIN diagnostics")
        failed = True
    require(
        "gateway_test",
        "expect(error.toString(), isNot(contains(invalidPin)))",
    )
    require("g2c_verifier", "ArgumentError.value(")
    require("composition_test", "iOS defaults to the native-bound credential gateway")
    require("bridge_test", "uses only the approved channel methods and bounded values")
    require("bridge_test", "validates PIN shape before crossing the native boundary")

    for swift_file in SWIFT_FILES:
        if texts["pbx"].count(swift_file) < 4:
            print(f"FAIL Xcode project does not fully reference {swift_file}")
            failed = True

    require("runner", f'"tools/verify_bw_ios_g2c.py": "{G2C_REF}"')
    require("iap", "IOS-G2D — iOS Native Keychain/Auth Bridge")

    if failed:
        raise SystemExit(1)

    print(
        "PASS: IOS-G2D registers the bounded breakwave/privacy_auth channel, "
        "stores only a versioned PBKDF2 verifier in device-bound Keychain, "
        "uses biometric-only LocalAuthentication, composes iOS through the "
        "native gateway, hardens native transport and credential validation "
        "fail-closed behavior, and pins the superseded G2C verifier historically."
    )


if __name__ == "__main__":
    if sys.argv[1:] == ["--apply-stage"]:
        apply_stage()
    elif sys.argv[1:]:
        raise SystemExit("Usage: verify_bw_ios_g2d.py [--apply-stage]")
    else:
        verify()
