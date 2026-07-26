# BW-88 Audit E — Billing Testing Matrix

## Status

Approved pre-implementation acceptance-test contract for the future
BreakWave Plus Google Play subscription system.

This pass does not install billing code, create products, configure
Google Play subscriptions, deploy a backend, or change current access.

The tests below become mandatory implementation and release evidence
when billing development begins.

## Testing principle

Billing failure must never become recovery failure.

Every test environment and every subscription state must preserve:

- Rescue
- onboarding
- basic logging
- log history and correction
- privacy controls
- basic secular support
- basic Christian support
- emergency and human-support information
- access to the user's own recovery data

No billing test passes if Plus behaves correctly while Rescue, protected
Free access, privacy, or recovery-data ownership is damaged.

## Priorities

- P0: Safety, privacy, entitlement correctness, money, or release blocker
- P1: Required production behavior
- P2: Important resilience, polish, or operational assurance

All P0 and P1 tests must pass before paid release.

There are no waivers for:

- Rescue availability
- false entitlement
- missing entitlement after verified payment
- recovery-data leakage
- raw token or credential leakage
- unacknowledged initial purchases
- fake restore success
- incorrect revocation
- hardcoded price or billing-period claims

## Test layers

### Layer S0 — Static contract verification

Python verifiers and repository scans confirm:

- access taxonomy remains intact
- production UI uses the centralized access service
- no recovery data enters billing contracts
- no hardcoded store prices exist
- no client secret or service-account credential enters the repository
- no local preview flag becomes production entitlement authority

### Layer S1 — Deterministic unit tests

Pure Dart and backend unit tests use controlled fixtures for:

- subscription-state mapping
- entitlement precedence
- signed-snapshot validation
- offline boundaries
- linked-token handling
- acknowledgement decisions
- privacy allowlists and denylists
- user-message selection

### Layer S2 — Integration tests with controlled fakes

The client and backend use fake adapters for:

- Play Billing callbacks
- Developer API responses
- acknowledgement outcomes
- RTDN delivery
- network failure
- duplicate and out-of-order events
- clock and cache behavior

No Google credential is required for S2.

### Layer S3 — Google Play license-tester testing

Use a Play test track, registered license testers, test payment
instruments, and Play Billing Lab.

The Google account making the purchase must be confirmed in the Play
purchase dialog.

A test-track user who is not a license tester may incur a real charge.
No non-license paid test may occur without explicit approval and a
documented refund plan.

### Layer S4 — Production-readiness rehearsal

Use production-like backend infrastructure, least-privilege service
accounts, staging RTDN, signed entitlement snapshots, release-signed app
artifacts, and real physical Android devices.

No production subscription launch may occur until S4 evidence is
approved.

## Required test setup

Before S3 or S4 begins, record:

- app package name
- app version and version code
- commit SHA
- CI run ID
- Play track and release identifier
- tester Google account
- whether the account is a license tester
- account that downloaded the app
- Android device model and OS version
- Play Store version
- Play Billing Lab account and active settings
- backend environment and deployment version
- product, base-plan, and offer identifiers
- RTDN project, topic, and subscription identifiers
- test start and completion timestamps
- screenshots or recordings with sensitive values redacted

Raw purchase tokens, credentials, Personal Why content, logs, triggers,
plans, contacts, and other recovery information must not enter evidence.

## Safety and protected-Free tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| SAF-001 | P0 | S1/S3 | Open Rescue with no subscription | Rescue opens immediately |
| SAF-002 | P0 | S2/S3 | Open Rescue while purchase is pending | No billing overlay, spinner, or gate blocks Rescue |
| SAF-003 | P0 | S2/S3 | Open Rescue during Grace Period | Rescue and Free tools remain available |
| SAF-004 | P0 | S2/S3 | Open Rescue during Account Hold | Rescue remains available while Plus is suspended |
| SAF-005 | P0 | S2/S3 | Open Rescue after Expiration or Revocation | Rescue remains available |
| SAF-006 | P0 | S2 | Backend and Play Billing fail during app startup | Free app starts and Rescue remains reachable |
| SAF-007 | P0 | S2 | Signed entitlement cache is corrupt | Plus fails closed without harming Free data or navigation |
| SAF-008 | P0 | S1/S2 | Exercise all 25 Free and never-paywalled features in every normalized billing state | Every protected feature remains available |

## Product-catalog and pricing tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| CAT-001 | P0 | S1/S3 | Product details load successfully | Only Google Play-provided products, prices, periods, and offers appear |
| CAT-002 | P0 | S2 | Product identifier is unknown or mismatched | Purchase is blocked and no entitlement is granted |
| CAT-003 | P1 | S2 | Product-details request fails | Plus screen remains usable and explains temporary unavailability |
| CAT-004 | P0 | S1 | Search production presentation code | No hardcoded price, trial, discount, or billing period exists |
| CAT-005 | P1 | S3 | Test different Play regions | Price and currency follow Google Play localization |
| CAT-006 | P1 | S2/S3 | Previously loaded catalog becomes stale | App refreshes details before purchase and never presents stale details as authoritative |

## Purchase-flow tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| PUR-001 | P0 | S3 | License tester uses always-approves payment | Plus activates only after backend verification and durable entitlement recording |
| PUR-002 | P0 | S3 | License tester uses always-declines payment | No Plus entitlement is granted |
| PUR-003 | P0 | S3 | Slow test card approves after delay | Purchase remains Pending first, then Plus activates after verified completion |
| PUR-004 | P0 | S3 | Slow test card declines after delay | Purchase remains unentitled and no success message appears |
| PUR-005 | P1 | S3 | User closes or cancels Play purchase dialog | App returns safely with no entitlement change |
| PUR-006 | P0 | S2 | Same purchase callback is delivered twice | Processing is idempotent and no duplicate entitlement is created |
| PUR-007 | P0 | S2/S3 | App is killed after Play completes payment but before UI callback | Startup or resume query recovers and verifies the purchase |
| PUR-008 | P0 | S2 | Token belongs to wrong package or unexpected product | Verification rejects it and records no entitlement |
| PUR-009 | P0 | S2/S3 | Upgrade or downgrade remains pending | Old verified entitlement continues; new benefits are not granted |
| PUR-010 | P0 | S2/S3 | Pending replacement completes | New linked token becomes authoritative only after verification |

## Acknowledgement tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| ACK-001 | P0 | S1/S2 | New verified eligible token is durably recorded | Backend then acknowledges the purchase |
| ACK-002 | P0 | S2 | Verification fails | Purchase is not acknowledged and Plus is not granted |
| ACK-003 | P0 | S2/S3 | Purchase remains Pending | Pending purchase is not acknowledged |
| ACK-004 | P0 | S2 | Acknowledgement call fails temporarily | Entitlement remains recorded and acknowledgement retries idempotently |
| ACK-005 | P1 | S2 | Already-acknowledged token is processed again | No harmful duplicate action occurs |
| ACK-006 | P0 | S1/S2 | Subscription renewal is received | Renewal refreshes entitlement without requiring new acknowledgement |

## Lifecycle-state tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| LIF-001 | P0 | S1/S3 | Subscription is Active | Plus is granted |
| LIF-002 | P1 | S2/S3 | Silent payment retry still reports Active | Plus remains granted without invented warning state |
| LIF-003 | P0 | S1/S3 | Subscription enters Grace Period | Plus remains granted |
| LIF-004 | P0 | S2/S3 | Subscription recovers during Grace Period | Plus continues and state returns to Active |
| LIF-005 | P0 | S1/S3 | Subscription enters Account Hold | Plus is suspended immediately after verification |
| LIF-006 | P0 | S2/S3 | Subscription recovers from Account Hold | Plus returns only after fresh verification |
| LIF-007 | P0 | S1/S3 | User cancels but paid time remains | Plus continues through verified expiry |
| LIF-008 | P1 | S2/S3 | User restarts renewal before expiry | Verified renewal status is stored and Plus continues |
| LIF-009 | P1 | S2/S3 | Pause is scheduled but not effective | Plus continues through current paid period |
| LIF-010 | P0 | S1/S3 | Pause becomes effective | Plus is suspended while Free tools remain available |
| LIF-011 | P0 | S2/S3 | Paused subscription resumes | Plus returns only after verified Active state |
| LIF-012 | P0 | S1/S3 | Subscription expires | Plus is removed |
| LIF-013 | P0 | S1/S3 | Subscription is revoked | Plus is removed immediately |
| LIF-014 | P0 | S2/S4 | Purchase is voided or charged back | New verified negative state removes Plus |
| LIF-015 | P0 | S2/S3 | Initial pending purchase is canceled | No Plus entitlement ever exists |
| LIF-016 | P0 | S2/S3 | Pending replacement is canceled | Old linked subscription retains its independently verified access |

## RTDN and authoritative-refresh tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| RTD-001 | P0 | S2/S4 | SUBSCRIPTION_PURCHASED arrives | Backend queries V2 before granting entitlement |
| RTD-002 | P0 | S2/S4 | RENEWED, RECOVERED, or RESTARTED arrives | Backend queries V2 and stores authoritative state |
| RTD-003 | P0 | S2/S4 | IN_GRACE_PERIOD or ON_HOLD arrives | Backend queries V2 and maps access correctly |
| RTD-004 | P0 | S2/S4 | PAUSED or CANCELED arrives | Backend queries V2 rather than trusting event name alone |
| RTD-005 | P0 | S2/S4 | EXPIRED or REVOKED arrives | Backend verifies and removes Plus when confirmed |
| RTD-006 | P0 | S2 | Same RTDN message is delivered repeatedly | Processing is idempotent |
| RTD-007 | P0 | S2 | Older RTDN arrives after a newer state | Older event cannot overwrite newer verified state |
| RTD-008 | P1 | S2 | Unknown event type or malformed message arrives | Event is rejected or safely ignored without entitlement change |

## Restore and device-change tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| RST-001 | P0 | S2/S3 | Restore finds verified Active purchase | Plus is restored |
| RST-002 | P0 | S2/S3 | Restore finds verified Grace Period purchase | Plus is restored with neutral payment-update messaging |
| RST-003 | P0 | S2/S3 | Restore finds canceled but unexpired purchase | Plus is restored only through verified expiry |
| RST-004 | P0 | S2/S3 | Restore finds Paused or Account Hold state | Purchase is identified but Plus remains suspended |
| RST-005 | P0 | S2/S3 | Restore finds only expired purchase or no purchase | No Plus access and no false restore-success message |
| RST-006 | P1 | S2/S3 | Network or backend fails during restore | Valid cache is preserved and user may retry |
| RST-007 | P0 | S3/S4 | App is installed on another device using owning Play account | Current purchase is re-queried and verified before restoration |
| RST-008 | P0 | S3/S4 | Different Play account or multiple linked tokens are returned | No unsupported cross-account claim or duplicate entitlement occurs |

## Offline and signed-snapshot tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| OFF-001 | P0 | S1/S2 | First Plus grant attempted offline | Grant is denied |
| OFF-002 | P0 | S1/S2 | Valid Active snapshot is under 72 hours old | Offline Plus remains available |
| OFF-003 | P0 | S1/S2 | Active snapshot passes 72-hour boundary | Plus is suspended |
| OFF-004 | P0 | S1/S2 | Valid Grace Period snapshot is under 24 hours old | Offline Plus remains available |
| OFF-005 | P0 | S1/S2 | Grace snapshot passes 24-hour boundary | Plus is suspended |
| OFF-006 | P0 | S1/S2 | Verified expiry occurs before cache maximum | Access ends at expiry |
| OFF-007 | P0 | S1/S2 | Scheduled pause boundary occurs before cache maximum | Access ends at pause boundary |
| OFF-008 | P0 | S2 | Newer verified negative state exists | Older positive snapshot cannot restore Plus |
| OFF-009 | P0 | S1/S2 | Device clock is rolled backward | Offline authorization is not extended |
| OFF-010 | P0 | S1/S2 | Snapshot signature, version, or payload is tampered with | Snapshot is rejected and Plus fails closed |

## Security and privacy tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| SEC-001 | P0 | S0/S1 | Inspect billing request schema | Only approved billing allowlist fields are accepted |
| SEC-002 | P0 | S0/S1 | Attempt to send logs, triggers, Personal Why, mode, plan, routines, or contacts | Request is rejected or fields are discarded |
| SEC-003 | P0 | S0/S2 | Inspect app, backend, analytics, and crash logs | Raw purchase tokens are absent |
| SEC-004 | P0 | S0 | Scan repository and CI output | Service-account credentials and signing keys are absent |
| SEC-005 | P0 | S1/S2 | Signed snapshot is modified | Signature validation fails |
| SEC-006 | P0 | S1/S2 | Older valid snapshot is replayed after newer revocation | Replay cannot restore Plus |
| SEC-007 | P1 | S1/S2 | Token lookup and deduplication occur | Redacted or cryptographic token reference is used |
| SEC-008 | P0 | S4 | Backend service account permissions are reviewed | Only least-privilege Android Publisher access is granted |
| SEC-009 | P0 | S2/S4 | Unauthorized client calls verification endpoint | Request is rejected without leaking purchase state |
| SEC-010 | P0 | S2/S4 | Billing exception reaches crash or support reporting | Credentials, raw tokens, and recovery data are scrubbed |

## User experience and accessibility tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| UXS-001 | P0 | S1/S3 | Billing state changes while Rescue is open | No billing message interrupts or covers Rescue |
| UXS-002 | P1 | S1/S3 | Pending purchase is shown | Message says payment is pending without claiming success |
| UXS-003 | P0 | S1/S3 | Restore button is pressed without verified purchase | App does not say restored |
| UXS-004 | P1 | S1/S3 | Canceled-but-unexpired subscription is shown | Exact verified end date and renewal-off status are clear |
| UXS-005 | P1 | S1/S3 | Account Hold or Pause is shown | Message is factual, neutral, and states Free tools remain available |
| UXS-006 | P1 | S1/S3 | Offline authorization expires | Message explains refresh requirement and preserves Rescue |
| UXS-007 | P1 | S1/S3 | TalkBack and large text are used on Plus and subscription-status surfaces | Controls, prices, periods, and status remain understandable |
| UXS-008 | P1 | S3 | User backs out of purchase, restore, or management flow | Navigation returns safely without dead ends or false state |

## Operational and release-evidence tests

| ID | Priority | Layer | Scenario | Required result |
|---|---|---|---|---|
| OPS-001 | P0 | S3 | License tester setup is reviewed | Purchasing account, downloader account, and tester status are documented |
| OPS-002 | P1 | S3 | Test-track artifact is installed from Google Play | Package, signing, version, and track match evidence |
| OPS-003 | P1 | S3 | Play Billing Lab moves test subscription through Grace and Hold | Backend and app follow authoritative refreshed states |
| OPS-004 | P1 | S3/S4 | Behavior depending on pause or resubscribe configuration is tested | At least one non-license configuration check confirms real Console behavior |
| OPS-005 | P0 | S4 | Staging RTDN delivery is exercised | Delivery, authentication, deduplication, retry, and V2 refresh evidence exists |
| OPS-006 | P0 | S4 | Evidence bundle is assembled | Test ID, expected result, actual result, timestamp, device, commit, and redacted proof exist |
| OPS-007 | P0 | S4 | Billing rollout is disabled or rolled back | Free app and Rescue continue without billing startup dependency |
| OPS-008 | P0 | S4 | Paid-launch review is held | No open P0 or P1 test, privacy, acknowledgement, restore, or entitlement defect remains |

## Required automated suites

Before S3 begins, implementation must provide automated tests for:

- all normalized subscription states
- every access-policy tier
- pending purchase and pending replacement behavior
- acknowledgement eligibility and retry
- linked-token precedence
- duplicate and out-of-order RTDN
- signed-snapshot validation
- 72-hour Active offline boundary
- 24-hour Grace Period offline boundary
- expiry and pause boundaries
- clock rollback
- restore-result mapping
- privacy allowlist and denylist
- Rescue and protected-Free access in every state

## Required Google Play test runs

The S3 evidence set must include:

1. always-approves initial subscription
2. always-declines initial subscription
3. slow card that approves after Pending
4. slow card that declines after Pending
5. renewal success
6. renewal payment failure
7. Grace Period with recovery
8. Grace Period flowing into Account Hold
9. recovery from Account Hold
10. cancellation with paid time remaining
11. expiration
12. scheduled pause and effective pause
13. resume from pause
14. pending plan replacement
15. canceled pending replacement
16. Restore Purchases on the original device
17. restoration on another device using the owning Play account
18. different-account restoration failure
19. acknowledged test purchase
20. deliberately unacknowledged controlled test proving Play reversal
    behavior without risking production users

## Evidence format

Every executed test must record:

- test ID
- priority
- layer
- app commit SHA
- app version and version code
- backend version
- Play track
- product and base-plan identifier
- device and Android version
- tester-account classification
- setup
- action
- expected result
- actual result
- pass or fail
- timestamps
- redacted logs
- screenshots or recording when useful
- linked defect or remediation commit when failed

Evidence must not contain raw purchase tokens, credentials, recovery logs,
triggers, Personal Why content, plans, contacts, or support messages.

## Exit criteria

Billing implementation may enter paid release review only when:

- every P0 test passes
- every P1 test passes
- all historical BreakWave verifiers pass
- Flutter tests and Android builds pass in CI
- automated billing tests pass
- license-tester evidence is complete
- RTDN evidence is complete
- acknowledgement evidence is complete
- restore and device-change evidence is complete
- offline-boundary evidence is complete
- privacy scans report zero prohibited recovery fields
- Rescue and protected-Free tests pass in every state
- no active entitlement defect remains
- no raw credential or purchase-token leak remains
- 24/3CJ LLC approves the release evidence

## Stop-ship conditions

Paid launch must stop for any of the following:

- Rescue can be blocked by billing
- a Pending purchase grants Plus
- a verified purchase fails to grant Plus
- an expired, held, paused, revoked, or voided state incorrectly retains
  Plus beyond its approved boundary
- Restore Purchases claims success without verification
- initial purchases are not acknowledged reliably
- recovery data enters billing infrastructure
- raw tokens or credentials enter logs or evidence
- prices or billing periods are hardcoded
- device-clock manipulation extends offline Plus
- duplicate or out-of-order RTDN corrupts entitlement
- client-local state becomes production billing authority

## Current official technical basis

Implementation and execution must be checked against current official
Google documentation again when billing code is introduced:

- https://developer.android.com/google/play/billing/test
- https://developer.android.com/google/play/billing/integrate
- https://developer.android.com/google/play/billing/security
- https://developer.android.com/google/play/billing/subscriptions
- https://developer.android.com/google/play/billing/lifecycle/subscriptions
- https://developer.android.com/google/play/billing/rtdn-reference
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2
