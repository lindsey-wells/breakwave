# BreakWave — Play Signing Setup

## Purpose

BW-51 prepares BreakWave for signed Android App Bundle output through GitHub Actions.

The app supports release signing through android/key.properties when signing secrets are available. If secrets are missing, CI falls back to debug signing so normal verification builds can still run.

## Required GitHub Secrets

Add these repository secrets:

- ANDROID_KEYSTORE_BASE64
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD

Do not commit the keystore, passwords, alias password, or base64 keystore text to the repository.

## Generate upload key in Termux

Install Java tools if needed:

    pkg install openjdk-17 -y

Generate the upload key:

    keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

Recommended values:
- Keystore filename: upload-keystore.jks
- Alias: upload
- Use a strong password and save it somewhere private.
- Do not paste passwords into ChatGPT.
- Do not commit upload-keystore.jks to GitHub.

## Convert keystore to base64 in Termux

Install coreutils if needed:

    pkg install coreutils -y

Convert:

    base64 -w 0 upload-keystore.jks > upload-keystore.base64

View/copy the base64 text:

    cat upload-keystore.base64

Copy the full output into the GitHub Secret named ANDROID_KEYSTORE_BASE64.

## GitHub Secrets setup

Go to:

    GitHub repo
    Settings
    Secrets and variables
    Actions
    New repository secret

Create these secrets:

1. ANDROID_KEYSTORE_BASE64
   Value: full contents of upload-keystore.base64

2. ANDROID_KEYSTORE_PASSWORD
   Value: the keystore password

3. ANDROID_KEY_ALIAS
   Value: upload

4. ANDROID_KEY_PASSWORD
   Value: the key password

## Expected CI behavior

Without secrets:
- CI builds APK/AAB with debug signing fallback.
- Useful for normal smoke builds.
- Not Play-upload-ready.

With secrets:
- CI writes android/app/upload-keystore.jks.
- CI writes android/key.properties.
- Gradle uses the release signing config.
- Uploaded AAB artifact is signed with the upload key.

## Play Store handoff

The Upwork Play Store publisher should receive the signed AAB artifact from GitHub Actions only after signing secrets are configured and a green CI run confirms the artifact is produced.

## Signing status language

Without GitHub signing secrets, CI can still build APK/AAB artifacts for smoke testing, but those artifacts are not Play-upload-ready.

With GitHub signing secrets configured, CI should produce a signed AAB artifact suitable for Play upload.
