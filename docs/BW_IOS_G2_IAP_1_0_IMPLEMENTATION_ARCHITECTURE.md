# BreakWave IOS-G2 Implementation Architecture Plan
## IAP-1.0 — Rescue-Safe Lock / iOS Privacy Architecture

**Status:** LOCKED FOR IMPLEMENTATION
**Project:** BreakWave
**Date:** 2026-09-12
**Target:** iOS 16+ / iPhone-first
**Product owner:** 24/3CJ LLC
**Development:** Cube23
**Planned permanent iOS bundle ID:** `com.breakwaveapp.breakwave`
**Parent contract:** `BreakWave Rescue-Safe Lock Technical Contract — IOS-G2 / RSLC-1.0`

---

# 1. Objective

Convert RSLC-1.0 into a concrete implementation architecture before production code changes begin.

The implementation must accomplish four things simultaneously:

1. introduce a real privacy-session state machine instead of a single locked/unlocked boolean;
2. keep a useful, data-minimized Rescue experience available under Full App lock;
3. move iOS privacy credentials behind native Keychain + LocalAuthentication;
4. preserve the released Android app's behavior while the iOS architecture is proven.

This plan intentionally favors small patches, explicit boundaries, fail-closed routing, and dual-platform CI evidence.

---

# 2. Current Repository Constraints

The current implementation has several architectural constraints that this plan must work around safely.

## 2.1 Current lock state is shell-owned

`BreakWaveShell` currently owns:

- `_lockLoading`
- `_sessionUnlocked`
- `_privacyLockBackgroundedAt`
- `_lockSettings`

and decides whether to replace the shell body with `PrivacyUnlockScreen`.

That design has only two practical states: locked or unlocked. It has no first-class `rescueSafe` state.

## 2.2 Current credential is part of settings

`PrivacyLockSettings` currently contains:

- `PrivacyLockMode mode`
- `String passcode`

and serializes both.

`PrivacyLockStore` persists the serialized structure through `shared_preferences`.

Therefore the raw six-digit PIN currently exists in ordinary application preferences.

## 2.3 Current Rescue cannot be exposed unchanged while locked

The normal Rescue screen can:

- access Personal Why;
- write Victory/Urge/Slip events;
- navigate to Log;
- navigate to Support;
- use personalized recovery data.

Therefore `RescueScreen` is a protected personalized Rescue surface.

A separate `RescueSafeScreen` is required.

## 2.4 Current timer persistence is not Rescue-safe

`WaveTimerCard` directly constructs `LogRepository`.

`LogRepository.saveEntry()` calls `loadEntries()` before inserting the new event.

Therefore the current timer save path reads existing protected recovery history and is not permitted in Rescue-safe mode.

## 2.5 Existing Android privacy behavior must remain stable

Android already has native `FLAG_SECURE` behavior through the existing `breakwave/screen_privacy` bridge.

IOS-G2 must not disturb:

- Android application ID;
- Android screen privacy;
- Android reminders;
- Android billing;
- Android release signing;
- Android public lock behavior;
- Android production Rescue behavior.

---

# 3. Primary Architecture Decision

## 3.1 Do not add authentication/storage plugins for IOS-G2

IOS-G2 should use Apple's native frameworks directly:

- `Security` / Keychain for privacy credential material;
- `LocalAuthentication` for Face ID / Touch ID;
- UIKit/scene lifecycle for app-switcher shielding.

Flutter communicates with this native layer through one narrow MethodChannel.

### Reason

This approach:

- gives BreakWave explicit control over Keychain accessibility semantics;
- avoids adding `local_auth` and secure-storage dependencies to Android;
- does not expand the plugin dependency surface while the iOS project is still being stabilized;
- matches BreakWave's existing use of narrow native bridges;
- makes it easier to prove exactly what data crosses the Dart/native boundary.

No third-party dependency is required for the first iOS privacy-lock implementation.

---

# 4. Runtime State Model

Add:

`lib/core/privacy_lock/privacy_session_state.dart`

```text
enum PrivacySessionState {
  locked,
  rescueSafe,
  authenticating,
  unlocked,
}
```

`privacyShielded` is not part of the authentication enum because the app can be both unlocked and visually shielded while backgrounded.

The current `_sessionUnlocked` boolean is eventually removed from `BreakWaveShell`.

---

# 5. Destination Access Model

Add:

`lib/core/privacy_lock/privacy_destination.dart`

Initial destinations:

```text
lockedLanding
home
rescueSafe
rescuePersonalized
log
support
personalWhy
insights
personalPlan
routineHistory
recoveryReport
privacySettings
trustedContact
exports
billing
internalQa
unknown
```

Add:

`lib/core/privacy_lock/privacy_access_class.dart`

```text
enum PrivacyAccessClass {
  publicLocked,
  rescueSafe,
  protected,
}
```

Add:

`lib/core/privacy_lock/privacy_route_policy.dart`

Responsibilities:

```text
PrivacyAccessClass classify(PrivacyDestination destination)
bool requiresAuthentication(
  PrivacyDestination destination,
  PrivacyLockMode lockMode,
  PrivacySessionState sessionState,
)
```

Rules:

- unknown destination => `protected`;
- Rescue-safe landing => `rescueSafe`;
- under Full App lock, Home => protected;
- normal personalized Rescue => protected;
- Log/Support/Personal Why => protected;
- under Sensitive Sections, Home + normal Rescue remain available by current product policy.

This policy is pure Dart and must have exhaustive tests before shell integration.

---

# 6. Lock Configuration Model

Replace the long-term role of `PrivacyLockSettings` with metadata that contains no credential.

Add:

`lib/core/privacy_lock/privacy_lock_configuration.dart`

Proposed fields:

```text
PrivacyLockMode mode
bool biometricEnabled
bool credentialConfigured
int schemaVersion
```

No PIN or verifier may appear in this model.

Add:

`lib/core/privacy_lock/privacy_lock_configuration_store.dart`

Storage:

- SharedPreferences is allowed for non-secret metadata.
- New key: `bw_privacy_lock_config_v2`.

The current `PrivacyLockSettings` / `PrivacyLockStore` remain temporarily available only for Android compatibility/migration until the new composition layer is proven.

---

# 7. Credential Abstraction

Add:

`lib/core/privacy_lock/privacy_auth_result.dart`

Initial result values:

```text
success
cancelled
failed
cooldown
unavailable
error
```

Add:

`lib/core/privacy_lock/privacy_biometric_status.dart`

Initial values:

```text
available
notEnrolled
notAvailable
lockedOut
unknown
```

Add:

`lib/core/privacy_lock/privacy_credential_gateway.dart`

Interface:

```text
Future<bool> isCredentialConfigured()
Future<void> configurePin(String pin)
Future<PrivacyAuthResult> verifyPin(String pin)
Future<void> clearCredential()

Future<PrivacyBiometricStatus> biometricStatus()
Future<PrivacyAuthResult> authenticateBiometric()
```

The gateway never exposes:

- stored PIN;
- salt;
- verifier;
- Keychain blob;
- biometric secret.

---

# 8. Platform Composition

Add:

`lib/core/privacy_lock/privacy_lock_composition.dart`

Responsibilities:

- construct the correct credential gateway by platform;
- construct configuration store;
- construct attempt/cooldown store;
- construct session controller;
- keep widgets unaware of iOS/Android credential implementation details.

Initial composition:

```text
iOS -> IosPrivacyCredentialGateway
Android -> LegacyAndroidPrivacyCredentialGateway
other -> UnsupportedPrivacyCredentialGateway
```

This is a temporary migration architecture.

The legacy Android adapter exists only to preserve the released Android behavior during IOS-G2. It is not an endorsement of plaintext credential storage.

A separate Android credential-hardening project can later replace it without redesigning the UI or session policy.

---

# 9. iOS Flutter-to-Native Boundary

Add:

`lib/core/privacy_lock/platform/privacy_native_bridge.dart`

MethodChannel:

`breakwave/privacy_auth`

Permitted methods:

```text
credentialStatus
configurePin
verifyPin
clearCredential
biometricStatus
authenticateBiometric
```

Arguments crossing Dart -> native:

- raw PIN only during `configurePin` or `verifyPin`;
- no recovery data;
- no Personal Why;
- no Log data;
- no user notes.

Native -> Dart returns only non-secret status/result values.

The bridge must never log raw arguments.

---

# 10. Native iOS Classes

Add these Swift files under `ios/Runner/`.

## 10.1 `BreakWavePrivacyBridge.swift`

Responsibilities:

- register `breakwave/privacy_auth`;
- validate channel method names and arguments;
- dispatch to credential/biometric services;
- convert native errors to bounded Flutter results;
- never print PIN values or credential blobs.

Registration occurs from the Flutter engine initialization path in `AppDelegate`.

## 10.2 `BreakWaveKeychainCredentialStore.swift`

Responsibilities:

- persist only a versioned PIN-verification record;
- use Keychain, not UserDefaults/files;
- use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` or an equivalent approved device-bound accessibility class;
- expose configure / verify / clear / configured-state operations;
- never return verifier material to Dart.

Proposed Keychain service:

`com.breakwaveapp.breakwave.privacy-lock`

The service string can be stable before App Store registration because it is an internal Keychain service identifier.

## 10.3 `BreakWavePinVerifier.swift`

Responsibilities:

- generate cryptographically secure random salt;
- derive a one-way verifier from the six-digit PIN;
- store a versioned verifier record;
- use constant-time verifier comparison;
- make the KDF parameters versioned so they can be raised later.

Initial KDF direction:

- PBKDF2-HMAC-SHA256;
- iteration count selected after an iPhone performance benchmark;
- no raw PIN persisted.

The iteration count is intentionally not frozen in IAP-1.0; it must be measured on the oldest supported physical iPhone before release.

## 10.4 `BreakWaveBiometricAuthenticator.swift`

Uses:

`LocalAuthentication`

Policy:

`deviceOwnerAuthenticationWithBiometrics`

This is deliberate.

IOS-G2 does **not** silently accept the device passcode as a BreakWave privacy-lock bypass.

Responsibilities:

- report biometric availability;
- request Face ID / Touch ID;
- return only success/cancel/failure/unavailable result;
- never store biometric data.

## 10.5 `BreakWavePrivacyShieldCoordinator.swift`

Responsibilities:

- add a neutral/brand privacy cover when the iOS scene becomes inactive;
- keep the cover present while backgrounded;
- remove it only after the scene becomes active and the Flutter privacy state is safe to display;
- operate independently of the two-minute authentication relock grace period.

`SceneDelegate.swift` delegates lifecycle shielding to this coordinator.

This feature is app-switcher/background shielding, not a screenshot-prevention promise.

---

# 11. iOS Configuration Changes

Eventually modify:

`ios/Runner/Info.plist`

Required:

```text
NSFaceIDUsageDescription
```

Suggested user-facing meaning:

"BreakWave uses Face ID to unlock your private recovery information when you enable privacy lock."

Also fix before TestFlight:

- display name: `BreakWave`
- iOS deployment floor: 16.0
- iPhone-first device family
- planned bundle ID: `com.breakwaveapp.breakwave` once Apple team/App ID is available

The final bundle ID registration waits for 24/3CJ LLC's Apple Developer organization account.

---

# 12. Persistent Failed-Attempt State

Add:

`lib/core/privacy_lock/privacy_attempt_state.dart`

Add:

`lib/core/privacy_lock/privacy_attempt_store.dart`

Persist only non-secret values:

```text
failedAttemptCount
cooldownUntilUtc
schemaVersion
```

Initial compatibility behavior remains:

- 10 failed PIN attempts;
- 5-minute cooldown.

Requirements:

- app restart does not reset cooldown;
- widget rebuild does not reset cooldown;
- cooldown never blocks Rescue-safe;
- successful PIN authentication clears attempt state;
- biometric failure does not need to increment the BreakWave PIN counter unless product policy later says otherwise.

---

# 13. Privacy Session Controller

Add:

`lib/core/privacy_lock/privacy_session_controller.dart`

Use Flutter core state primitives (`ChangeNotifier` or equivalent), not a new state-management package.

Responsibilities:

```text
Future<void> initialize()
Future<void> enterRescueSafe()
Future<PrivacyAuthResult> unlockWithPin(String pin)
Future<PrivacyAuthResult> unlockWithBiometrics()
void authenticationCancelled()
void onBackgrounded(DateTime at)
void onResumed(DateTime at)
void lockNow()
Future<void> applyConfiguration(...)
```

State owned here:

- current `PrivacySessionState`;
- current configuration;
- background timestamp;
- relock grace calculation;
- current requested protected destination, if any.

The controller must not own recovery data.

---

# 14. Locked Landing Screen

Add:

`lib/features/privacy_lock/presentation/privacy_locked_screen.dart`

Full App locked surface:

```text
Privacy lock

[ Unlock BreakWave ]
[ Open Rescue ]
```

Optional biometric affordance appears only when enabled/available.

The screen must not render:

- Personal Why;
- current focus;
- streak/history;
- recent Log;
- trusted contact;
- Plus/billing status.

`Open Rescue` calls:

`PrivacySessionController.enterRescueSafe()`

It must not call any unlock method.

---

# 15. Rescue-Safe Presentation

Add:

`lib/features/rescue/presentation/rescue_safe_screen.dart`

Do **not** make the first version an unrestricted `RescueScreen(accessMode: safe)` toggle.

A separate screen provides stronger fail-closed guarantees and makes accidental personalized-widget imports easier for CI to detect.

Initial allowed content:

- urge-intensity selector;
- generic Rescue intro;
- generic breathing/grounding;
- generic timer;
- generic redirect actions;
- generic outcome buttons;
- `Unlock BreakWave`;
- generic external support guidance.

Explicitly excluded:

- `RememberWhyCard`;
- Personal Why image/text;
- existing Log data;
- normal Support screen;
- trusted-contact content;
- recovery insights;
- billing;
- normal Home.

Existing widgets may be reused only after a static + behavioral audit proves they have no protected-data dependency.

---

# 16. Rescue-Safe Widget Rule

The first implementation should classify Rescue widgets.

## Candidate safe after audit

- `UrgeIntensitySection`
- `CalmResetCard`

## Requires refactor or safe-specific replacement

- `WaveTimerCard` — currently writes through `LogRepository`
- `RedirectActionsCard` — currently connects to Personal Why behavior
- `SupportEscalationCard` — must not reveal personalized Support/trusted contacts
- completion/follow-up widgets — currently route to protected screens

## Forbidden in Rescue-safe without authentication

- `RememberWhyCard`

CI verifier should maintain an explicit allowed-import list for `rescue_safe_screen.dart`.

---

# 17. Rescue-Safe Outcome Persistence

Do not call `LogRepository.saveEntry()` from Rescue-safe.

Add:

`lib/features/rescue/domain/pending_rescue_outcome.dart`

Fields limited to the newly-created event:

```text
id
entryType
intensity
genericOutcomeTag
genericAction
createdAtIso
```

No prior-history-derived content.

Add:

`lib/features/rescue/data/rescue_safe_outcome_store.dart`

Storage key:

`bw_rescue_safe_pending_v1`

This store may read/write only the pending Rescue-safe queue.

It must not call `LogRepository.loadEntries()`.

Add:

`lib/features/rescue/data/rescue_outcome_reconciler.dart`

Responsibilities after successful authentication:

1. load pending Rescue-safe events;
2. convert them to ordinary `LogEntry` records;
3. save them to the normal Log;
4. remove only successfully reconciled pending records.

If reconciliation fails:

- pending event remains;
- normal unlock still succeeds;
- user is not trapped in authentication;
- reconciliation can retry later.

This preserves the Rescue-safe contract while still allowing the user to retain what happened.

---

# 18. Android Compatibility Strategy

IOS-G2 must treat Android as a protected production baseline.

## 18.1 Do not touch

Unless a later patch explicitly requires it:

- `android/app/src/main/kotlin/com/cube23/breakwave/MainActivity.kt`
- Android application ID
- Android manifest permissions
- Android `FLAG_SECURE` initialization
- RevenueCat Android configuration
- notification scheduling
- release signing
- Play Store resources

## 18.2 Compatibility adapter

Add:

`lib/core/privacy_lock/platform/legacy_android_privacy_credential_gateway.dart`

This adapter wraps the current `PrivacyLockStore` behavior behind the new interface.

Purpose:

- keep Android behavior functionally identical while shared widgets/controllers are refactored;
- prevent iOS implementation from requiring Android security changes at the same time.

The adapter is marked technical debt with a dedicated follow-up item:

`ANDROID-PRIVACY-HARDENING`

## 18.3 Android parity tests

Before any shared shell refactor merges, tests must prove:

- No Lock behaves as before.
- Sensitive Sections still leaves Home/normal Rescue reachable.
- Full App still locks the Android shell.
- two-minute relock grace remains.
- existing Android screen privacy verifier remains green.
- Android APK/AAB builds remain green.

---

# 19. Shell Integration

Modify eventually:

`lib/features/shell/presentation/breakwave_shell.dart`

The shell stops owning credential details.

Instead it receives/creates a `PrivacySessionController`.

High-level render decision:

```text
state == locked       -> PrivacyLockedScreen
state == rescueSafe   -> RescueSafeScreen
state == authenticating -> bounded authentication UI/state
state == unlocked     -> existing IndexedStack shell
```

Under Sensitive Sections:

- the main shell may remain visible;
- route policy gates protected destinations.

Under Full App:

- Home is not rendered while locked/rescueSafe;
- protected screens are not constructed in a way that can briefly flash before authentication.

The current normal `RescueScreen` remains the personalized unlocked Rescue experience.

---

# 20. Unlock Screen Refactor

Modify:

`lib/features/privacy_lock/presentation/privacy_unlock_screen.dart`

Remove:

- direct access to `PrivacyLockSettings.passcode`;
- direct plaintext equality comparison;
- in-widget ownership of security state.

New inputs:

```text
PrivacySessionController
PrivacyUnlockContext / requested destination
```

The screen becomes presentation only.

It requests:

- biometric unlock;
- PIN unlock;
- cancel.

Cooldown state comes from controller/store.

---

# 21. Settings UI Refactor

Modify:

`lib/features/support/presentation/widgets/privacy_lock_settings_card.dart`

Remove:

- `_savedPasscode`;
- loading raw saved PIN;
- comparing current PIN against stored plaintext;
- saving PIN inside `PrivacyLockSettings`.

New flow:

1. load non-secret configuration;
2. if changing an existing lock, authenticate current credential;
3. configure new PIN through `PrivacyCredentialGateway`;
4. save metadata separately;
5. optionally enable biometrics;
6. clear credential only after successful authentication.

Android compatibility gateway preserves existing Android behavior during this refactor.

---

# 22. App-Switcher Shield Integration

Modify:

`ios/Runner/SceneDelegate.swift`

Add:

`BreakWavePrivacyShieldCoordinator`

Lifecycle:

```text
sceneWillResignActive -> show shield immediately
sceneDidEnterBackground -> shield remains
sceneWillEnterForeground -> shield remains
sceneDidBecomeActive -> remove only when safe
```

The visual shield is not the authentication lock itself.

Authentication relock remains controlled by `PrivacySessionController`.

This separation prevents a two-minute grace period from exposing a sensitive app-switcher snapshot.

---

# 23. CI Architecture

Do not repurpose the completed IOS-G1 proof as a moving-target test.

IOS-G1 remains immutable evidence for the exact September baseline.

Add a new workflow:

`.github/workflows/breakwave-ios-shadow-ci.yml`

Purpose:

build the candidate branch SHA on hosted macOS for ongoing iOS work.

Initial gates:

```text
checkout candidate SHA
verify candidate SHA
Flutter 3.44.9 pin
toolchain evidence
flutter pub get
pubspec.lock drift check
BreakWaveVerify selftest
IOS-G2 verifier(s)
flutter analyze --no-fatal-infos
flutter test
flutter build ios --simulator --debug
verify Runner.app
artifact SHA-256
upload evidence
```

Unlike IOS-G1, generated Xcode/SwiftPM files that are intentionally committed during IOS-G2 should no longer be treated as unexplained bootstrap drift.

Every runtime IOS-G2 patch must pass:

1. BreakWave Android Shadow CI;
2. BreakWave iOS Shadow CI.

No iOS patch is considered green with only one platform passing.

---

# 24. New Verifiers

Add progressively:

`tools/verify_bw_ios_g2a_architecture.py`

Checks:

- required architecture files exist;
- RSLC/IAP docs exist;
- no production wiring yet in architecture-only patch.

`tools/verify_bw_ios_g2b_policy.py`

Checks:

- route policy defaults unknown to protected;
- `rescueSafe` state exists;
- pure-policy test files exist.

`tools/verify_bw_ios_g2c_credentials.py`

Checks:

- no `passcode` field remains in v2 configuration;
- iOS bridge channel name fixed;
- Swift Keychain/auth classes exist;
- `NSFaceIDUsageDescription` exists when biometrics are wired;
- no obvious raw PIN serialization patterns.

`tools/verify_bw_ios_g2d_rescue_safe.py`

Checks:

- `RescueSafeScreen` exists;
- forbidden personalized imports absent;
- no direct `LogRepository` import;
- no billing dependency;
- no `RememberWhyCard`.

`tools/verify_bw_ios_g2e_android_parity.py`

Checks:

- Android screen privacy implementation remains present;
- Android application ID unchanged;
- protected Android files have expected contract markers.

Static verifiers supplement tests; they do not replace runtime/widget tests.

---

# 25. Test Files

Add:

`test/privacy_route_policy_test.dart`

Must cover all lock mode / state / destination combinations.

Add:

`test/privacy_session_controller_test.dart`

Must cover:

- cold locked start;
- enter Rescue-safe;
- Rescue-safe is not unlocked;
- auth success;
- auth cancellation;
- grace-period relock;
- restart semantics;
- cooldown.

Add:

`test/privacy_lock_configuration_test.dart`

Must prove no credential is serialized.

Add:

`test/rescue_safe_access_policy_test.dart`

Must prove protected Rescue capabilities are unavailable.

Add:

`test/rescue_safe_outcome_store_test.dart`

Must prove pending store is independent from normal Log history.

Add:

`test/rescue_outcome_reconciler_test.dart`

Must prove success/failure/retry behavior.

Add:

`test/privacy_locked_screen_test.dart`

Must prove `Open Rescue` exists under Full App lock.

Add:

`test/rescue_safe_screen_test.dart`

Must prove:

- no Personal Why;
- no Log content;
- no personalized Support;
- unlock gates protected navigation.

---

# 26. Patch Sequence

Each patch is intentionally small.

## IOS-G2A — Architecture Freeze + Candidate iOS CI

Changes:

- commit RSLC-1.0;
- commit IAP-1.0;
- add `breakwave-ios-shadow-ci.yml`;
- add architecture verifier.

Production behavior change: **none**.

Green gates:

- verifier;
- Flutter analyze;
- Flutter tests;
- Android Shadow CI;
- iOS candidate Simulator build.

## IOS-G2B — Pure Dart Privacy Policy Types

Add:

- session state;
- destination enum;
- access class;
- route policy;
- configuration model.

No shell wiring.

Production behavior change: **none**.

Green gates:

- exhaustive pure-Dart tests;
- both platform CI workflows.

## IOS-G2C — Credential Interfaces + Android Compatibility Adapter

Add:

- auth result/status types;
- credential gateway;
- composition layer;
- legacy Android adapter.

Existing Android UI remains wired to current behavior until parity tests are green.

Production behavior change: **none intended**.

Green gates:

- Android parity tests;
- existing Android privacy verifiers;
- both platform builds.

## IOS-G2D — iOS Native Keychain/Auth Bridge

Add Swift native classes and Dart bridge.

Do not route the app through it yet.

Production behavior change: **none**.

Green gates:

- iOS Simulator compile;
- bridge/verifier tests;
- Android CI proves no effect.

## IOS-G2E — Persistent Attempt State + Session Controller

Add:

- attempt store;
- session controller;
- controller tests.

Controller remains unhooked from shell until tests are green.

Production behavior change: **none**.

## IOS-G2F — Locked Landing + Route Gate

Wire controller into shell in the smallest possible integration patch.

Add:

- locked landing;
- protected-route gate.

Normal Android behavior must remain parity-equivalent through compatibility adapter.

This is the first material runtime architecture change.

## IOS-G2G — Rescue-Safe Presentation

Add `RescueSafeScreen`.

At first:

- no Personal Why;
- no normal Log write;
- no personalized Support;
- no billing.

Prove Rescue-safe remains available while locked.

## IOS-G2H — Pending Rescue Outcome Queue

Add:

- pending outcome model/store;
- reconciler.

Then allow limited locked-Rescue outcome saving.

## IOS-G2I — iOS Biometrics + App-Switcher Shield

Wire:

- biometric UI;
- `NSFaceIDUsageDescription`;
- SceneDelegate shield.

Simulator proves build; physical-device behavior waits for IOS-G3.

## IOS-G2J — iOS Platform Configuration

Lock in project configuration that does not require signing:

- display name `BreakWave`;
- minimum iOS 16;
- iPhone-first supported family;
- intended bundle identifier in project once owner approves.

Apple registration/signing remains deferred until 24/3CJ account is active.

## IOS-G2K — Integration Freeze

Run:

- full Flutter tests;
- full BreakWave verifiers;
- Android APK/AAB CI;
- unsigned iOS Simulator build;
- privacy-contract static audit;
- source drift/evidence bundle.

If green, IOS-G2 engineering architecture is complete and ready for IOS-G3 signed-device work.

---

# 27. Stop Conditions

Stop the patch sequence immediately if any patch:

- changes public Android lock behavior unexpectedly;
- makes Rescue depend on billing;
- allows Rescue-safe to set the session unlocked;
- exposes Personal Why/history while locked;
- stores raw PIN outside transient input memory;
- makes iOS authentication failure disable Rescue;
- removes Android `FLAG_SECURE`;
- changes Android application ID;
- causes pubspec.lock drift unrelated to an explicitly approved dependency;
- requires a large package upgrade merely to continue iOS work.

Fix one proven blocker at a time.

---

# 28. Explicitly Deferred

Not part of this implementation sequence:

- Android secure-credential migration beyond compatibility preservation;
- iPad lock UX;
- home widget;
- cross-device BreakWave PIN sync;
- remote credential recovery;
- device-passcode-as-BreakWave-unlock;
- account/cloud identity;
- Android/iOS subscription portability;
- universal screenshot blocking;
- RevenueCat Apple product setup;
- TestFlight signing.

---

# 29. Apple Enrollment Dependency

IOS-G2A through much of IOS-G2J can proceed before Apple enrollment completes.

Apple organization membership becomes a hard dependency for:

- registering `com.breakwaveapp.breakwave`;
- signing/provisioning a real iPhone build;
- App Store Connect;
- TestFlight;
- Apple in-app purchase/subscription products.

Therefore Jeff's Apple enrollment and the engineering IOS-G2 sequence may run in parallel.

---

# 30. IOS-G2 Definition of Done

IOS-G2 is green when:

1. the privacy architecture is represented by explicit tested abstractions;
2. no iOS raw PIN is persisted;
3. Full App lock provides Rescue-safe access without unlocking;
4. Rescue-safe cannot expose protected recovery data;
5. Rescue-safe outcome persistence is isolated from existing Log history;
6. iOS Keychain/biometric code compiles successfully;
7. app-switcher shielding architecture is wired;
8. Android behavior remains demonstrably stable;
9. Android and iOS candidate CI both pass;
10. all remaining blockers require Apple signing/physical-device access rather than unresolved architecture.

At that point the project moves to IOS-G3:

> sign BreakWave for 24/3CJ LLC, install it on a physical iPhone, and execute the RSLC physical-device acceptance matrix.

---

# 31. Recommended First Engineering Action

Do **not** start with Keychain code.

Start with:

**IOS-G2A — Architecture Freeze + BreakWave iOS Shadow CI**

That gives every later iOS patch a moving-candidate macOS build gate while preserving IOS-G1 as immutable baseline evidence.

Only after G2A is green should production privacy-lock code begin.

---

**End of BreakWave IOS-G2 Implementation Architecture Plan — IAP-1.0**
