# BreakWave IOS-G2K Integration Freeze

Freeze base: `8da569b43c4a3997fe5e0de201fba0129ca003a3`
Branch: `validation/bw-ios-g2k-integration-freeze`
Scope: integration closeout only; no runtime behavior changes.

## Required exact-candidate evidence
- full phase-aware BreakWave verifiers
- Flutter analyze and full Flutter tests
- Android Shadow APK/AAB build
- unsigned iOS Simulator build
- privacy-contract static audit
- source-drift classification and machine-readable iOS Shadow evidence
- Android Shadow success
- iOS Shadow success
- fresh main CI success after fast-forward promotion

## Frozen IOS-G2 invariants
- privacy states remain locked / rescueSafe / authenticating / unlocked
- unknown/protected routes fail closed
- Rescue-safe never unlocks the protected session
- Rescue-safe excludes protected recovery data and normal Log history while locked
- pending Rescue-safe outcomes remain isolated until post-auth reconciliation
- no iOS raw PIN persistence
- native Keychain uses device-bound when-unlocked accessibility
- PIN verification remains PBKDF2-HMAC-SHA256 with constant-time comparison
- biometric unlock remains biometrics-only; device passcode is not a BreakWave-lock bypass
- app-switcher/background shield remains wired and is not represented as screenshot prevention
- Rescue remains independent of billing
- Android behavior remains stable
- display name is BreakWave; iOS floor is 16.0; device family is iPhone-only
- permanent Apple bundle-ID registration/signing remains deferred

## Deferred to IOS-G3 / Apple-owner-dependent work
- register permanent Apple App ID / bundle identifier under 24/3CJ LLC
- signing and provisioning
- physical iPhone installation
- physical Face ID / Touch ID acceptance
- physical app-switcher shield acceptance
- oldest-supported-iPhone PBKDF2 benchmark / iteration adjustment
- TestFlight / App Store Connect acceptance

IOS-G2 may close only when remaining blockers are Apple signing / physical-device acceptance,
not unresolved architecture.
