# BreakWave Rescue-Safe Lock Technical Contract
## IOS-G2 / RSLC-1.0
**Status:** LOCKED FOR IMPLEMENTATION
**Project:** BreakWave
**Target:** iOS 16+ / iPhone-first
**Date:** 2026-09-12
**Owner:** 24/3CJ LLC
**Development:** Cube23 technical implementation
**Planned iOS bundle ID:** `com.breakwaveapp.breakwave`

---

## 1. Purpose

BreakWave's privacy lock must protect sensitive recovery information without making the app unavailable at the moment a user most needs immediate urge-interruption support.

This contract establishes a non-negotiable product invariant:

> **A privacy lock may protect BreakWave data, but it must not block immediate access to a safe, data-minimized Rescue experience.**

Rescue-safe access is **not** an unlocked BreakWave session. It is a separate restricted operating state with explicit data and navigation boundaries.

This contract governs the iOS implementation and is intended to become the reference for later cross-platform hardening.

---

## 2. Current-State Findings

The current shared Flutter implementation has three privacy lock modes: no lock, full-app lock, and sensitive-sections lock.

The current full-app mode replaces the shell body with the PIN unlock screen before any app content can be viewed. The current sensitive-sections mode protects Log and Support while leaving Home and Rescue reachable.

The current lock model also stores the six-digit PIN directly in the serialized privacy-lock settings persisted through `shared_preferences`.

The current Rescue implementation is not safe to expose unchanged while the full app is locked because Rescue can display personalized Personal Why content, save Victory/Urge/Slip outcomes into the Log, navigate to Log, navigate to Support, and use Support-linked/personalized surfaces.

Therefore, the existing Rescue screen cannot simply bypass full-app lock. A restricted Rescue-safe execution mode is required.

Relevant current code:
- `lib/core/privacy_lock/privacy_lock_mode.dart`
- `lib/core/privacy_lock/privacy_lock_settings.dart`
- `lib/core/privacy_lock/privacy_lock_store.dart`
- `lib/features/privacy_lock/presentation/privacy_unlock_screen.dart`
- `lib/features/shell/presentation/breakwave_shell.dart`
- `lib/features/rescue/presentation/rescue_screen.dart`

---

## 3. Core Security and Recovery Invariants

### RSLC-INV-01 — Rescue is never paywalled
Rescue-safe access and normal Rescue access must never depend on BreakWave Plus, RevenueCat entitlement state, subscription restoration, billing connectivity, onboarding completion gates that are not essential to safe rendering, or App Store availability.

### RSLC-INV-02 — Rescue-safe access is not authentication
Entering Rescue-safe mode must never set the normal BreakWave session to unlocked and must never satisfy a protected-route authentication requirement.

### RSLC-INV-03 — Protected data remains protected
While in Rescue-safe mode, BreakWave must not display existing sensitive recovery data or settings simply because the user can access Rescue.

### RSLC-INV-04 — Rescue remains usable during credential failure
If Keychain access, biometric authentication, credential verification, or the lock configuration subsystem fails, protected content must fail closed while Rescue-safe access remains available.

### RSLC-INV-05 — No plaintext privacy PIN
The raw BreakWave PIN must never be stored in `shared_preferences`, JSON settings, logs, analytics, crash reports, evidence artifacts, or ordinary files.

### RSLC-INV-06 — Authentication and recovery content are separate systems
Failure or unavailability of a privacy credential must never be interpreted as loss or corruption of the user's recovery history.

### RSLC-INV-07 — Locked means locked across navigation
No deep link, callback, tab switch, routine action, notification tap, modal, back-stack action, or Rescue callback may route from a locked state into protected content without successful authentication.

### RSLC-INV-08 — Background privacy protection is immediate
When iOS moves BreakWave away from the foreground, sensitive UI must be covered for app-switcher/background snapshots immediately, independent of any relock grace period.

---

## 4. Required Runtime States

### 4.1 `unlocked`
The user has successfully authenticated for the current BreakWave session. Normal app navigation is available subject to ordinary product access rules.

### 4.2 `locked`
Protected BreakWave content is unavailable. The locked surface must provide at least `Unlock BreakWave` and `Open Rescue`.

The locked surface must not reveal Personal Why, Log content, Support configuration, recovery history, triggers, Current Focus, plans, insights, account/billing details, or other sensitive personalized information.

### 4.3 `rescueSafe`
The user entered Rescue directly from the locked state. `rescueSafe` is a restricted state and **must not imply `unlocked`**.

Leaving Rescue-safe for a protected destination must transition to authentication, not directly to that destination.

### 4.4 `authenticating`
Biometric or PIN authentication is actively being attempted. Cancellation or failure returns to the prior locked/rescue-safe state without leaking protected data.

### 4.5 `privacyShielded`
The app is inactive/backgrounded and its visible snapshot is covered. This state is about visual privacy and is separate from session authentication.

---

## 5. Lock Modes

### 5.1 No Lock
BreakWave opens normally. Rescue functions normally. No privacy-lock authentication gate is applied.

### 5.2 Sensitive Sections
Home and normal Rescue remain available by explicit user choice.

Log, Support, recovery reports, detailed insights, privacy settings, trusted-contact configuration, exported recovery data, and other designated sensitive surfaces require authentication.

This mode preserves the existing product concept but must use the new credential architecture.

### 5.3 Full App
Cold launch and relock states show the locked surface.

Home and other personalized app surfaces are unavailable until authentication.

The locked surface must always offer `Open Rescue`.

`Open Rescue` enters `rescueSafe`, not `unlocked`.

The existing meaning "require a passcode before anything in BreakWave can be viewed" is superseded by this contract. Full-app lock protects the app **except for the restricted Rescue-safe path**.

---

## 6. Rescue-Safe Allowed Surface

Rescue-safe mode may expose only functions that can operate without revealing existing sensitive user data.

### 6.1 Immediate interruption tools
Allowed without authentication:
- urge-intensity selection;
- generic wave/urge framing;
- breathing/calm-reset guidance;
- wave timer;
- grounding exercises;
- generic next-right-action choices;
- generic encouragement;
- generic "stay in Rescue" flows.

### 6.2 Local in-session state
The current Rescue-safe session may hold temporary values such as selected intensity, timer progress, current redirect action, and completion state in memory.

Those values must not unlock any protected data.

### 6.3 Minimal append-only recovery event
BreakWave may allow Rescue-safe completion to append a new Rescue outcome to the local recovery store if implementation can do so without reading or displaying prior entries.

The allowed operation is conceptually:

`appendRescueOutcome(newEvent)`

It must not expose previous Log entries, totals/history, existing triggers, existing notes, previous slips/victories, or insights derived from prior recovery data.

A successful append may confirm only that **this new event** was saved.

If safe append cannot be guaranteed, Rescue-safe completion remains functional without persistence and offers the user the option to save after unlocking.

### 6.4 Generic external support handoff
Rescue-safe may offer generic actions such as opening the phone app, opening the messages app, showing static emergency/crisis guidance already approved for BreakWave, or encouraging contact with a trusted person.

It must not reveal a stored trusted contact, phone number, email address, accountability record, or personalized Support configuration without authentication.

---

## 7. Rescue-Safe Protected Content

The following must not be displayed in `rescueSafe` without authentication:
- Personal Why text;
- Personal Why image;
- recovery Log history;
- Log details or edits;
- Support settings;
- trusted-contact/accountability details;
- email capture data;
- Current Focus;
- stored triggers;
- recovery plan contents;
- detailed insights;
- weekly/30/90-day history;
- recovery reports;
- prior routine/journey history where personally revealing;
- billing/account-management information;
- privacy-lock settings;
- exported recovery files;
- internal QA/admin surfaces.

When a Rescue-safe surface reaches a feature that normally uses protected content, it must render a privacy-safe substitute.

Examples:
- Personal Why area → `Unlock to view your Personal Why`
- Open Log → authentication gate
- Open Support → authentication gate
- Return Home under Full App lock → authentication gate

No protected content may be prefetched and momentarily rendered before the gate appears.

---

## 8. Rescue-Safe Navigation Contract

### 8.1 Entry
From a locked full-app surface:

`Locked -> Open Rescue -> RescueSafe`

This transition requires no PIN, biometric, network, RevenueCat state, or subscription state.

### 8.2 Unlock from Rescue
Rescue-safe may offer `Unlock BreakWave`.

Successful authentication transitions:

`RescueSafe -> Authenticating -> Unlocked`

The implementation may then upgrade the current Rescue experience into normal personalized Rescue or route to the originally requested protected destination.

### 8.3 Protected navigation attempt
If Rescue-safe attempts to navigate to Log, Support, Home under Full App lock, Personal Why, settings, or any other protected destination:

`RescueSafe -> Authenticating`

On success:

`Authenticating -> Unlocked -> RequestedDestination`

On cancel/failure:

`Authenticating -> RescueSafe`

### 8.4 No hidden unlock
No Rescue action, outcome save, timer completion, support escalation, route pop, notification callback, or successful external-app handoff may implicitly mark the BreakWave session unlocked.

---

## 9. Credential Architecture

### 9.1 Metadata vs credential separation
Privacy-lock metadata and credentials must be separate.

Ordinary preferences may contain non-secret metadata such as lock mode, biometric preference, schema version, and non-sensitive UX options.

Ordinary preferences must not contain raw PIN, reversible PIN representation, biometric secret, or an authentication token capable of bypassing verification.

### 9.2 PIN
The six-digit BreakWave PIN remains a supported fallback credential.

The raw PIN must never be persisted.

The implementation must store only the material required to verify the PIN, using a salted, computationally appropriate one-way verifier and platform-protected storage.

### 9.3 iOS secure storage
Credential material must be stored using iOS Keychain semantics.

BreakWave privacy credentials must be non-synchronizing, device-bound where supported/appropriate, inaccessible as ordinary app files, and unavailable to normal migration/backup as plaintext application data.

Expected migration UX:
- recovery history may migrate;
- the old app-lock credential must not silently migrate as an ordinary preference;
- BreakWave may require privacy-lock setup on the new device.

### 9.4 Biometrics
Face ID / Touch ID may be offered as a convenience authentication method after the user enables privacy lock.

BreakWave must not store biometric data.

Biometric success may unlock the BreakWave session. Biometric cancellation/failure must not reveal protected content. The app's own PIN remains the supported fallback.

### 9.5 Device passcode
The iPhone device passcode must not silently become an automatic BreakWave privacy-lock bypass merely because LocalAuthentication supports broader device-owner authentication.

Any future decision to accept device passcode as BreakWave authentication requires a separate explicit product decision because BreakWave's privacy lock may intentionally provide protection beyond possession of the phone passcode.

---

## 10. Failed Attempts and Cooldown

The existing product behavior of a failed-attempt cooldown may be retained initially, but the implementation must fix the current in-memory-only weakness.

Minimum contract:
- failed PIN attempt state must survive ordinary widget rebuilds and app restarts during the cooldown window;
- force-closing the app must not trivially reset the attempt counter;
- cooldown state must not block Rescue-safe access;
- biometric OS lockout behavior remains controlled by iOS;
- failure messages must not reveal whether protected recovery data exists.

Initial compatibility target:
- 10 failed PIN attempts;
- 5-minute PIN cooldown.

Changing those values is a later product-tuning decision and not required by IOS-G2.

---

## 11. Lifecycle and Relock

### 11.1 Cold launch
If a lock is enabled, the session begins locked.

Full-app lock must show the locked surface with Rescue-safe access.

### 11.2 Backgrounding
As soon as the app becomes inactive/backgrounded, BreakWave must visually shield sensitive UI from app-switcher snapshots.

### 11.3 Grace period
The current two-minute relock grace period may remain as the initial compatibility behavior.

If the app returns before the grace period expires, the authenticated session may remain unlocked.

After the grace period expires, the session returns to locked.

### 11.4 Rescue on relock
If the user was in normal personalized Rescue and the session becomes locked while backgrounded, resuming must not restore personalized Rescue visibly before authentication.

The app must return to either the locked surface or Rescue-safe mode with protected personalized content removed.

### 11.5 Crash/restart
A process restart must not inherit an authenticated in-memory session.

A newly started process begins locked whenever privacy lock is enabled.

---

## 12. App-Switcher and Screenshot Privacy

On iOS, BreakWave must implement background/app-switcher shielding.

BreakWave must not claim that it can universally prevent screenshots on iOS.

The privacy promise should be framed accurately:
- BreakWave obscures sensitive content when the app leaves the foreground;
- BreakWave protects locked content inside the app;
- iOS may still permit user-initiated screenshots or system-level capture behavior beyond the app's control.

---

## 13. Data Migration Contract

BreakWave follows the previously locked hybrid privacy-first migration policy.

### Migration-friendly
User-created recovery data should participate in normal protected Apple device migration/backup where appropriate, including recovery history, recovery plans, user-created recovery content, routine/journey progress, Personal Why content subject to file-protection requirements, and non-secret preferences.

### Device-bound / non-ordinary migration
The following must not migrate as ordinary app data:
- raw PIN;
- PIN verifier material intended to remain device-bound;
- biometric authentication state/secrets;
- temporary export files;
- transient share files;
- caches;
- ephemeral authentication state.

After migration, "credential unavailable" and "recovery data unavailable" must be handled as separate states.

BreakWave must never delete valid migrated recovery history merely because the prior device's privacy credential is unavailable.

---

## 14. Failure Behavior

### Keychain unavailable or corrupted
Protected content fails closed. Rescue-safe remains available. The app must not silently disable privacy lock.

### Biometric unavailable
PIN remains available. Rescue-safe remains available.

### PIN verifier unavailable
Protected content fails closed. Rescue-safe remains available. The user must not be told that recovery data itself is lost.

### Local recovery store unavailable
Rescue-safe interruption tools must still function as far as possible. The app may report that this Rescue outcome could not be saved, but the calming/interruption flow must continue.

### RevenueCat/network/App Store failure
No effect on Rescue-safe availability.

---

## 15. Privacy-Lock Settings UX

The settings UI must eventually describe the new behavior accurately.

### Sensitive Sections
Suggested meaning:

> Keep Home and Rescue available while requiring authentication for Log, Support, and other sensitive recovery areas.

### Full App
Suggested meaning:

> Protect your BreakWave recovery information when the app opens. You can still open a private, limited Rescue mode without unlocking.

The settings UI should clearly distinguish BreakWave PIN, optional Face ID / Touch ID, Rescue-safe access, and device-migration behavior.

---

## 16. Architecture Boundary

Implementation should introduce explicit services/interfaces rather than continuing to compare plaintext PIN values inside widgets.

Conceptual boundaries:

`PrivacyLockPolicy`
- decides whether a destination is public, Rescue-safe, or protected.

`PrivacySessionController`
- owns runtime states: locked, rescueSafe, authenticating, unlocked.

`PrivacyCredentialStore`
- owns secure verifier material.

`PrivacyAuthenticator`
- performs PIN and biometric authentication.

`PrivacyShieldController`
- controls iOS foreground/background visual shielding.

`RescueAccessPolicy`
- declares which Rescue capabilities are allowed in normal vs Rescue-safe mode.

`RescueOutcomeSink`
- permits append-only Rescue outcome persistence without exposing history.

Names may change during implementation, but these responsibilities must remain separated.

---

## 17. Protected Route Policy

At minimum, routing must classify destinations into three categories.

### Public while locked
- locked landing surface;
- Rescue-safe entry;
- generic emergency/safety handoff approved for Rescue-safe use.

### Rescue-safe only
- data-minimized Rescue interruption flow;
- generic timer/breathing/grounding;
- generic redirect actions;
- minimal append-only Rescue outcome if safely implemented.

### Authentication required
- Home under Full App lock;
- normal personalized Rescue;
- Log;
- Support;
- Personal Why content;
- insights/history;
- personal recovery plan;
- routine/journey history containing user-specific progress;
- recovery reports;
- privacy settings;
- trusted-contact/accountability data;
- exports;
- billing/account-management screens;
- QA/internal screens.

The implementation must default unknown routes to **authentication required**, not public.

---

## 18. Verification Requirements

IOS-G3 implementation is not green until automated checks prove all of the following.

### Credential checks
- no raw PIN is serialized into privacy-lock preferences;
- no raw PIN appears in ordinary persisted settings;
- credential verification is behind an abstraction;
- iOS credential material uses secure platform storage.

### Routing checks
- Full App locked state exposes `Open Rescue`;
- `Open Rescue` does not mark the session unlocked;
- Rescue-safe cannot open Log without authentication;
- Rescue-safe cannot open Support without authentication;
- Rescue-safe cannot return to personalized Home without authentication under Full App lock;
- unknown protected routes fail closed.

### Rescue privacy checks
- Personal Why is not rendered in Rescue-safe;
- prior Log entries are not read/rendered in Rescue-safe;
- trusted-contact details are not rendered in Rescue-safe;
- billing state is irrelevant to Rescue-safe availability;
- Rescue-safe remains usable if authentication is cancelled.

### Persistence checks
- Rescue-safe append-only event saving, if enabled, does not require reading history;
- failed save does not terminate Rescue;
- migrated recovery data is not deleted when credential state is missing.

### Lifecycle checks
- cold launch is locked when configured;
- process restart does not preserve unlocked state;
- app-switcher shielding activates immediately on background/inactive;
- relock occurs after the configured grace period;
- relock while in personalized Rescue does not briefly expose personalized content on resume.

### Failure checks
- Keychain/authentication failure leaves Rescue-safe available;
- biometric failure leaves PIN available;
- cooldown does not block Rescue-safe;
- RevenueCat/network failure cannot block Rescue-safe.

---

## 19. Manual Physical-iPhone Acceptance Scenarios

Before IOS-G3 is considered complete, the following scenarios must be exercised on a real iPhone:

1. Full App lock -> cold launch -> Open Rescue -> complete generic Rescue without authentication.
2. Rescue-safe -> tap Personal Why -> authentication gate appears before content.
3. Rescue-safe -> tap Log -> authentication gate appears.
4. Rescue-safe -> tap Support -> authentication gate appears.
5. Rescue-safe -> cancel Face ID -> remain in Rescue-safe with no protected content exposed.
6. Rescue-safe -> enter wrong PIN repeatedly -> cooldown engages but Rescue remains usable.
7. Unlocked -> personalized Rescue -> background app -> app-switcher snapshot is shielded.
8. Remain backgrounded beyond grace -> resume -> protected content does not flash before lock.
9. Force-close/relaunch -> session is locked.
10. Disable network / RevenueCat unavailable -> Rescue-safe still works.
11. Simulate local save failure -> Rescue tools still work and user receives non-catastrophic save feedback.
12. Migrate/restore test data -> recovery history survives while device-bound privacy credential is re-established separately.

---

## 20. Explicit Non-Goals for IOS-G3

IOS-G3 does not require iOS home-screen widget, iPad-specific lock UX, cloud account recovery, cross-platform account identity, cross-device privacy-lock credential synchronization, remote PIN reset, screenshot-prevention guarantees, RevenueCat subscription portability between Android and iOS, or major redesign of the Android privacy-lock UX unless separately approved.

---

## 21. Definition of Done

The Rescue-Safe Lock implementation is complete only when:

> A person can open BreakWave while the full app is privacy-locked, immediately access a useful Rescue interruption flow, receive meaningful help without a subscription or network connection, and still be unable to view or navigate into protected personal recovery information until authentication succeeds.

At the same time:

> A successful privacy unlock must restore the full personalized BreakWave experience without treating Rescue-safe access itself as authentication.

These two conditions are equally mandatory.

---

## 22. Locked Product Decisions

The following are locked by IOS-G2 / RSLC-1.0:
- Rescue remains available under Full App lock.
- Rescue-safe is a separate restricted state, not an unlocked session.
- Personal Why is protected by default in Rescue-safe mode.
- Existing recovery history is protected in Rescue-safe mode.
- Log and Support require authentication from Rescue-safe.
- Generic calming/timer/redirect tools remain available without authentication.
- Rescue-safe availability is independent of subscription/network state.
- Plaintext PIN storage is prohibited.
- iOS privacy credentials are secure-storage-backed and not ordinary migrated app data.
- Recovery data remains migration-friendly under the hybrid privacy-first policy.
- App-switcher shielding is required; universal screenshot prevention is not promised.
- Existing two-minute relock grace and 10-attempt/5-minute cooldown may remain initially, but their persistence/security behavior must be hardened.
- Unknown routes fail closed.
- iOS implementation must not silently weaken Android behavior.

---

**End of BreakWave Rescue-Safe Lock Technical Contract — IOS-G2 / RSLC-1.0**
