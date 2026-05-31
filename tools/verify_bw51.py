from pathlib import Path
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

blocked_paths = [
    Path("upload-keystore.base64"),
    Path("upload-keystore.jks"),
    Path("ANDROID_KEYSTORE_BASE64.txt"),
    Path("android/app/upload-keystore.jks"),
    Path("android/key.properties"),
]

for path in blocked_paths:
    if path.exists():
        print(f"FAIL secret/signing file must not exist in repo: {path}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-51 Play signing pipeline verified.")
