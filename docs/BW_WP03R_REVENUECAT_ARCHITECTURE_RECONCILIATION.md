# BreakWave WP-03R — RevenueCat Architecture Reconciliation

Status: **LOCKED ARCHITECTURE DECISION — documentation/verifier closeout only**

Decision date: 2026-08-29

App baseline: `0430f14c717fe9f5b4eb45e79fd101e19adcd238` (`bw-89a12f-green`)

Existing custom billing-backend baseline: `a3fb51a49dd085e1ce5bdb30fecd2a02980eee1b` (WP-03C offline staging readiness). The 24/3CJ primary and Cube23 disaster-recovery mirror were reconciled with matching heads before this decision.

This pass adds **no billing SDK, no production purchase entry, no cloud deployment, no Google Play product, no RevenueCat key, no service credential, and no entitlement behavior change**. It exists to lock the production billing authority boundary before WP-03S introduces client integration code.

The governing invariant remains:

> **Billing failure must never become recovery failure.**

Rescue and all protected Free recovery capabilities remain independent from subscription availability. Recovery data allowed in billing infrastructure remains zero.

## 1. Locked production authority boundary

For the paid-launch path:

1. **Google Play remains the store/payment system and underlying transaction source.**
2. **RevenueCat is the production purchase-validation and subscription-lifecycle authority.** RevenueCat communicates with Google Play using the dedicated Play service credentials configured for the BreakWave app.
3. **BreakWave keeps a narrow local entitlement adapter as the final access-policy enforcer.** The adapter may accept or reject RevenueCat state under the stricter RC1K rules below, but it must not invent an independent positive billing state.
4. `BreakWaveEntitlementSource` and `BreakWaveAccessService` remain the app-facing seams.
5. `LocalPremiumEntitlementSource` remains test/scaffold compatibility only and **must not become the production billing authority**.
6. The custom `24-3cj/breakwave-billing-backend` implementation is retained as a **disaster-recovery and security reference**, not deployed as the normal September 2026 production subscription authority.

Presentation code must not become coupled directly to RevenueCat, Google Play purchase tokens, local premium persistence, or the preserved custom backend.

## 2. RevenueCat Trusted Entitlements policy

RevenueCat Trusted Entitlements provides a verification result to the app. BreakWave applies a stricter decision policy than simply trusting `isActive`:

- `verified` — eligible to participate in a positive Plus decision only when the entitlement itself is active/eligible and all BreakWave time/state checks pass.
- `verifiedOnDevice` — **rejected as authority to create or extend BreakWave Plus**.
- `notRequested` — **rejected as authority to create or extend BreakWave Plus**.
- `failed` — **rejected as authority to create or extend BreakWave Plus**.

A RevenueCat SDK callback, purchase completion callback, cached Boolean, local premium flag, or UI state must never directly grant Plus.

Pending purchases remain non-entitled. A pending transaction may show progress/status, but the global Plus indicator remains inactive until trusted entitlement state qualifies.

Official reference: https://www.revenuecat.com/docs/customers/trusted-entitlements

## 3. RevenueCat temporary outage grants

RevenueCat documents `TEMPORARY_ENTITLEMENT_GRANT` for exceptional cases where RevenueCat cannot temporarily validate a purchase with the store. RevenueCat states that the short-term entitlement lasts **at most 24 hours**.

BreakWave accepts this bounded server-side exception to RC1K's earlier "first Plus grant requires online Google verification" wording only under these conditions:

1. the entitlement arrives through a RevenueCat response whose Trusted Entitlements result is `verified`;
2. the entitlement is otherwise active/eligible;
3. access never outlives the entitlement's own verified expiration;
4. the temporary authorization is never extended beyond **24 hours** from the accepted trusted server time without a later qualifying server-verified RevenueCat state; and
5. `verifiedOnDevice` can never be used to manufacture or extend the temporary grant.

This exception does **not** authorize a local/offline first grant. It accepts a bounded RevenueCat **server-issued** outage grant.

Official reference: https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields

## 4. BreakWave offline ceilings remain mandatory

The RC1K offline safety model remains in force around RevenueCat state:

- a qualifying server-verified Active or canceled-but-still-entitled state may authorize offline Plus for no more than **72 hours** after the accepted trusted verification time and never beyond the entitlement's verified expiration;
- a qualifying server-verified Grace state may authorize offline Plus for no more than **24 hours** and never beyond the entitlement's verified expiration;
- a RevenueCat temporary outage grant may authorize Plus for no more than **24 hours** and never beyond its verified expiration;
- `verifiedOnDevice`, `notRequested`, and `failed` never create or extend a positive offline window;
- Pending, Paused, On Hold, Expired, Revoked, Pending Canceled, Not Entitled, Unverifiable, and equivalent negative/non-entitled states do not receive positive offline authorization;
- a newer trusted negative state outranks an older positive state;
- an older/cached response must not resurrect Plus after a newer accepted state; and
- clock rollback or trusted-time ambiguity fails closed for Plus without affecting Rescue or protected Free recovery features.

WP-03S must implement the minimum local metadata needed to enforce these ceilings without storing raw purchase tokens or recovery data.

## 5. Restore and anonymous identity

BreakWave remains privacy-first and does not require a BreakWave login for the September 2026 paid-launch path.

RevenueCat anonymous App User IDs may be used. RevenueCat project restore behavior must be configured as **Transfer to new App User ID** so a customer can restore eligible purchases after uninstall/reinstall without requiring a BreakWave account.

Restore is a request to refresh authoritative state; it is not itself entitlement proof. A restore result must pass the same Trusted Entitlements and BreakWave state/time checks as any other positive state.

Official reference: https://www.revenuecat.com/docs/projects/restore-behavior

## 6. Service-credential exception and handling

RC1K's prohibition on credentials entering the app repository, APK/AAB, logs, evidence bundles, fixtures, screenshots, or client code remains absolute.

RevenueCat's Google Play integration requires a dedicated Google Play service credential to be supplied to RevenueCat. Therefore this narrowly scoped administrative exception is authorized:

- a Google service-account credential JSON may be generated solely for the RevenueCat/Google Play integration;
- it must be uploaded directly to the RevenueCat project configuration;
- it must **never** be committed to Git, embedded in BreakWave, placed in CI artifacts, evidence ZIPs, logs, chat messages, or screenshots;
- only the minimum permissions required by the current official RevenueCat Google Play credential instructions may be granted;
- the local downloaded credential copy should be securely removed after RevenueCat configuration/validation is complete; and
- rotation/replacement must follow the same handling rules.

No RevenueCat secret/server key may be shipped in the Flutter client. Only the appropriate RevenueCat public SDK key belongs in client configuration when WP-03S reaches that step.

Official reference: https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials

## 7. Existing custom backend classification

The existing WP-03A/B/C custom backend work is **preserved, not deleted**.

### KEEP

- deterministic lifecycle fixtures and security/test reasoning;
- replay/idempotency concepts;
- privacy allowlist/denylist rules;
- token-redaction rules;
- stricter state precedence and offline-ceiling concepts;
- primary repository under 24/3CJ and the Cube23 disaster-recovery mirror.

### ADAPT INTO THE REVENUECAT CLIENT BOUNDARY

- normalized positive/negative state handling;
- stale/newer-state precedence;
- 72-hour/24-hour offline ceilings;
- fail-closed verification behavior;
- restore-as-refresh semantics;
- zero recovery data in billing infrastructure.

### REPLACED ON THE NORMAL LAUNCH PATH BY REVENUECAT

- direct Google Play subscription-verification transport;
- custom production purchase-token verification worker;
- custom production acknowledgement path;
- custom production RTDN ingestion/refresh path;
- custom production Firestore entitlement authority; and
- custom Cloud Run verification endpoint as a September 2026 paid-launch prerequisite.

### DISASTER-RECOVERY / SECURITY REFERENCE

The preserved backend remains a fallback architecture and defense-in-depth reference if RevenueCat later becomes unsuitable or 24/3CJ deliberately chooses to own the full billing-verification stack.

## 8. Play Integrity classification

The existing Play Integrity design is preserved as future defense-in-depth hardening but is **deferred from the September 2026 paid-launch critical path**.

Play Integrity may be reintroduced later for anti-abuse/risk controls, but BreakWave Plus launch must not require deployment of the custom backend solely to preserve the earlier Play Integrity adapter.

## 9. Required global BreakWave Plus indicator

Paid readiness requires the previously planned global Plus access affordance wherever the screen/app-bar architecture permits it:

- **gray Plus icon** when BreakWave Plus is inactive/not entitled;
- tapping gray opens the truthful BreakWave Plus benefits/paywall path;
- **blue Plus icon** when trusted BreakWave Plus entitlement is active;
- tapping blue opens the Plus hub/features;
- Pending remains gray until a qualifying trusted entitlement is accepted;
- expiry/revocation/loss of trusted entitlement returns the indicator to gray;
- no red prohibition/slash treatment is required for the inactive state; and
- Rescue must never be blocked, delayed, obscured, or made dependent on the Plus indicator or billing refresh.

The icon reflects trusted entitlement state. **The icon is never entitlement authority.**

WP-03R records this as a required paid-readiness UX gate; implementation belongs to the later RevenueCat client/Plus UI packages.

## 10. Superwall and paywall experimentation

Superwall is not a September 2026 launch dependency. Baseline purchase, entitlement, restore, offline, and Plus-indicator behavior must be proven before optional remote paywall experimentation is introduced.

## 11. WP-03R closeout result

**RevenueCat architecture fit: GO WITH BREAKWAVE GUARDRAILS.**

The custom backend is removed from the normal paid-launch critical path but retained as disaster-recovery/security reference. The existing app access abstraction remains the integration seam. No production billing dependency or entitlement behavior is introduced by WP-03R itself.

**Next ordered package: WP-03S — RevenueCat SDK Integration.**
