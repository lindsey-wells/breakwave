from pathlib import Path
import subprocess
import sys

checks = [
    ("android/app/build.gradle.kts", [
        "import java.io.FileInputStream",
        "import java.util.Properties",
        "val keystoreProperties = Properties()",
        "val keystorePropertiesFile = rootProject.file(\"key.properties\")",
        "val hasReleaseSigning = keystorePropertiesFile.exists()",
        "keystoreProperties.load(FileInputStream(keystorePropertiesFile))",
        "signingConfigs {",
        "create(\"release\")",
        "keyAlias = keystoreProperties[\"keyAlias\"] as String",
        "storeFile = file(keystoreProperties[\"storeFile\"] as String)",
        "signingConfigs.getByName(\"release\")",
        "signingConfigs.getByName(\"debug\")",
    ]),
    (".github/workflows/ci.yml", [
        "Prepare Android release signing",
        "ANDROID_KEYSTORE_BASE64",
        "ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_ALIAS",
        "ANDROID_KEY_PASSWORD",
        "base64 --decode > android/app/upload-keystore.jks",
        "cat > android/key.properties <<EOF",
        "No Android signing secrets found. Release build will use debug signing fallback.",
        "Android signing secrets are incomplete.",
        "Build release APK",
        "Build release AAB",
    ]),
    ("android/.gitignore", [
        "key.properties",
        "app/upload-keystore.jks",
        "*.jks",
        "*.keystore",
    ]),
    (".gitignore", [
        "*.jks",
        "*.keystore",
        "upload-keystore.base64",
        "ANDROID_KEYSTORE_BASE64.txt",
    ]),
    ("launch/play_signing_setup.md", [
        "Play Signing Setup",
        "Required GitHub Secrets",
        "ANDROID_KEYSTORE_BASE64",
        "keytool -genkey",
        "not Play-upload-ready",
        "With secrets:",
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

# CI may create signing files from secrets during the workflow.
# The release safety rule is: secret files must never be tracked by git.
tracked = subprocess.check_output(
    ["git", "ls-files"],
    text=True,
).splitlines()

blocked_tracked = {
    "upload-keystore.base64",
    "upload-keystore.jks",
    "ANDROID_KEYSTORE_BASE64.txt",
    "android/app/upload-keystore.jks",
    "android/key.properties",
}

for rel_path in blocked_tracked:
    if rel_path in tracked:
        print(f"FAIL secret/signing file must not be tracked by git: {rel_path}")
        failed = True

workflow = Path(".github/workflows/ci.yml").read_text(encoding="utf-8")
signing_index = workflow.find("Prepare Android release signing")
verify_index = workflow.find("Run BreakWave verification scripts")
test_index = workflow.find("Flutter test")
build_apk_index = workflow.find("Build release APK")

if not (verify_index < test_index < signing_index < build_apk_index):
    print("FAIL signing prep should run after verifiers/tests and before release builds")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-51 Play signing pipeline verified.")
