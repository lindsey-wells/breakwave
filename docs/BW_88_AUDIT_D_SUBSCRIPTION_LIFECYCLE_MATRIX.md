# BW-88 Audit D — Subscription Lifecycle Matrix

## Status

Approved lifecycle, restoration, offline-access, and failure-behavior
contract for the future BreakWave Plus Google Play subscription system.

This pass does not install Google Play Billing, create products, enable
purchases, change entitlement, or deploy a backend.

## Governing principle

Billing failure must never become recovery failure.

Every billing state preserves:

- Rescue
- onboarding
- basic logging and log history
- privacy controls
- basic secular support
- basic Christian support
- emergency and human-support information
- access to the user's own recovery data

A billing problem may suspend BreakWave Plus. It must not suspend the
protected Free recovery experience.

## Authoritative-state rule

The Google Play Developer API SubscriptionPurchaseV2 resource is the
authoritative subscription record.

RTDN, an Android purchase callback, queryPurchasesAsync, a cached
snapshot, and a local premium flag are inputs or signals. None of them
alone is final production entitlement authority.

For every relevant purchase or lifecycle signal, the verification
backend must query purchases.subscriptionsv2.get and map the returned
state through this contract.

## State precedence

When records conflict, BreakWave applies this order:

1. A newer verified explicit revocation, expiration, account hold, or
   effective pause overrides an older positive snapshot.
2. A newer signed entitlement snapshot overrides an older snapshot.
3. The newest verified purchase token in a linked-token chain is the
   current subscription record.
4. RTDN receipt time does not override the API resource.
5. An unknown response or temporary verification outage must not create
   a new entitlement.
6. A temporary outage must not erase a still-valid signed positive
   snapshot unless an explicit newer negative state was verified.
7. Local PremiumStateStore data never overrides production state.

## Primary subscription lifecycle matrix

| Play or BreakWave state | Plus access | Backend behavior | User-facing behavior |
|---|---|---|---|
| Never purchased | Not granted | Store no entitlement | Plus may be reviewed; purchasing language follows the pre-billing or live-store state |
| Initial purchase pending | Not granted | Record pending token without granting or acknowledging | Your purchase is pending in Google Play. Plus will activate after payment is completed and verified. |
| Pending purchase completed | Grant after verification | Query V2, durably record entitlement, then acknowledge the new token | Activate Plus only after verified state is eligible |
| Active | Granted | Store active state and verified expiry | BreakWave Plus is active. |
| Active with acknowledgement pending | Granted after durable entitlement recording | Retry acknowledgement until confirmed or Play returns a newer state | Do not repeatedly interrupt the user; show a status only when needed |
| Renewal completed | Granted | Refresh expiry; no renewal acknowledgement required | Continue without a success popup on every renewal |
| Silent payment-retry period still reported Active | Granted | Follow the authoritative Active state | Do not invent a payment-warning state that Google has not returned |
| Grace period | Granted | Store grace state and shortened cache limit; continue entitlement | Plus is still available. Google Play needs an updated payment method to avoid interruption. |
| User canceled, paid time remains | Granted until verified expiry | Store canceled state and expiry; stop assuming renewal | Plus remains active until {date}. Renewal is turned off. |
| Cancellation restored before expiry | Granted | Re-query the same purchase token and store renewed status | BreakWave Plus will continue renewing. |
| Pause scheduled but not effective | Granted until pause takes effect | Continue Active entitlement through the current paid period | Plus remains active until {date}, then pauses. |
| Paused | Suspended | Store paused state and auto-resume time when provided | Your Plus subscription is paused. Free BreakWave tools remain available. |
| Account hold | Suspended | Store hold state; invalidate positive access immediately | Plus is temporarily unavailable because Google Play could not complete renewal. Free BreakWave tools remain available. |
| Recovered from grace, hold, or pause | Granted after verification | Query V2 and issue a new signed positive snapshot | BreakWave Plus is active again. |
| Expired | Revoked | Store expired state and invalidate positive snapshots | Plus has ended. Free BreakWave tools remain available. |
| Revoked or voided | Revoked immediately | Record explicit negative state and invalidate positive snapshots | Plus access is no longer active. Free BreakWave tools remain available. |
| Pending purchase canceled | No new entitlement | Query the affected token; inspect linkedPurchaseToken when present | The pending purchase was not completed. No charge-confirmation or Plus-success message is shown. |
| State unspecified or unverifiable | Not newly granted | Retry safely; preserve only an independently valid signed snapshot | We could not verify Plus right now. Free BreakWave tools remain available. |
| Test purchase | Follow verified test state | Mark test status and isolate it from production reporting | Test purchase — BreakWave Plus active for testing. |

## Pending plan changes and linked purchase tokens

A pending upgrade, downgrade, top-up, or replacement must not remove a
still-valid old entitlement merely because a new purchase is pending.

While the replacement is pending:

- preserve the verified entitlement associated with the old token
- do not grant benefits that belong only to the pending replacement
- do not retire the old token
- do not acknowledge the pending token
- explain that the requested plan change is pending only when relevant

When the new purchase completes:

1. query the new token through subscriptionsv2.get
2. inspect linkedPurchaseToken
3. verify and record the new entitlement
4. acknowledge the new token when required
5. retire the old token from current-authority status
6. preserve an auditable linkage without exposing raw tokens in logs

When a pending replacement is canceled, query the linked old token and
preserve whatever entitlement that verified old subscription still has.

## Pause behavior

A scheduled pause does not suspend access immediately.

Access continues through the already-paid period while the authoritative
subscription state remains Active.

When the pause takes effect and the state becomes Paused:

- suspend Plus
- preserve all local recovery data
- preserve all Free features
- show the expected auto-resume date when available
- provide a Google Play management or resume route outside Rescue
- require fresh verification before Plus becomes active again

If payment fails when a pause attempts to resume, map the resulting
Account Hold state rather than treating the subscription as active.

## Cancellation, expiration, and revocation

Cancellation stops future renewal but does not automatically remove
already-paid access.

For a canceled subscription with a future verified expiry:

- keep Plus through that expiry
- clearly state that renewal is off
- do not describe the subscription as expired
- allow Google Play restoration before expiry when supported

Expiration removes Plus after the verified paid period has ended.

Revocation or a verified voided purchase removes Plus immediately,
regardless of the previous expiry date.

User-facing wording should remain neutral. It must not accuse the user,
mention fraud, or infer a refund reason that the verified record does not
provide.

## Acknowledgement behavior

A new purchase token must be acknowledged only after:

1. Google Play verification succeeds
2. the state is eligible for entitlement
3. the entitlement record is durably stored

Initial purchases, re-signups, and plan changes that produce a new token
require acknowledgement when the verified acknowledgement state is
pending.

Normal renewals do not require acknowledgement.

An initial Pending purchase must not be acknowledged.

If acknowledgement temporarily fails after entitlement was durably
recorded:

- retain the verified entitlement
- retry acknowledgement idempotently
- surface no repeated purchase-success messages
- alert operations before the acknowledgement deadline
- accept a later Play refund or revocation as authoritative

## RTDN handling matrix

| RTDN signal | Required response |
|---|---|
| SUBSCRIPTION_PURCHASED | Query V2, verify, record, grant when eligible, and acknowledge a new token |
| SUBSCRIPTION_RENEWED | Query V2 and refresh state and expiry |
| SUBSCRIPTION_RECOVERED | Query V2 and restore Plus only from the verified result |
| SUBSCRIPTION_RESTARTED | Query V2 and record that renewal resumed |
| SUBSCRIPTION_IN_GRACE_PERIOD | Query V2, retain access, and shorten offline authorization |
| SUBSCRIPTION_ON_HOLD | Query V2 and suspend Plus if hold is confirmed |
| SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED | Query V2; keep access while state remains Active |
| SUBSCRIPTION_PAUSED | Query V2 and suspend Plus if pause is effective |
| SUBSCRIPTION_CANCELED | Query V2 and retain access only through verified expiry |
| SUBSCRIPTION_REVOKED | Query V2 and revoke Plus immediately when confirmed |
| SUBSCRIPTION_EXPIRED | Query V2 and revoke Plus when expiration is confirmed |
| SUBSCRIPTION_PENDING_PURCHASE_CANCELED | Query the affected token and linkedPurchaseToken before deciding old access |
| SUBSCRIPTION_DEFERRED | Query V2 and update the verified expiry |
| Price or offer notification | Query V2 when relevant; do not change entitlement merely from the event name |
| Duplicate or out-of-order message | Process idempotently and keep the newest authoritative verified state |

RTDN processing must be idempotent.

A notification is never interpreted as complete entitlement proof.

## Restore Purchases matrix

| Restore result | Access result | User-facing result |
|---|---|---|
| Verified active purchase found | Grant Plus | BreakWave Plus was restored. |
| Verified grace-period purchase found | Grant Plus | Plus was restored. Google Play needs an updated payment method to avoid interruption. |
| Verified canceled but unexpired purchase found | Grant until expiry | Plus was restored through {date}. Renewal is turned off. |
| Verified paused or on-hold purchase found | Keep Plus suspended | Purchase found, but Plus is currently paused or needs a payment update. |
| Verified expired purchase found | Do not grant | No active BreakWave Plus purchase was found for this Google Play account. |
| No purchase returned by Play | Do not grant | No active BreakWave Plus purchase was found for this Google Play account. |
| Network or backend failure | Preserve only valid cache | We could not check purchases right now. Try again when connected. |
| Multiple tokens returned | Verify each and resolve linked-token precedence | Never grant duplicate or stacked Plus access |
| Different Google Play account | Do not claim restoration | Explain that restoration depends on the Google Play account that owns the purchase |

The app must not say “restored” merely because the restore button was
pressed or because Play returned an unverified token.

## Device-change behavior

A new device receives no Plus access from copied local preferences.

On a new device:

1. connect to Google Play
2. query purchases for the current Play account
3. send returned tokens to the verification backend
4. verify linked-token precedence
5. receive a signed entitlement snapshot
6. grant Plus only from that verified result

No mandatory BreakWave recovery account is required for this first
Google Play implementation.

Restoration is not guaranteed across a different Google Play account,
another app store, or iOS.

## Exact offline entitlement policy

### First grant

A first-time Plus grant always requires online backend verification.

A local flag or stale snapshot cannot create first-time access.

### Active and canceled-but-unexpired snapshots

A signed positive snapshot for Active or canceled-but-unexpired access
may authorize offline Plus for no more than 72 hours after its backend
verification time.

It must also end no later than:

- the verified subscription expiry
- the scheduled pause-effective boundary when known
- the server-authorized valid-through timestamp
- any newer explicit negative verification

The earliest boundary wins.

### Grace-period snapshots

A signed Grace Period snapshot may authorize offline Plus for no more
than 24 hours after verification.

It must never extend beyond its server-authorized valid-through time.

### Suspended and negative states

Paused, Account Hold, Expired, Revoked, Voided, and explicit
not-entitled states do not receive a positive offline authorization.

Recovery from one of those states requires fresh online verification.

### Verification outage with valid cache

When verification is unavailable but a valid signed positive snapshot
remains:

- continue Plus until the snapshot boundary
- do not silently extend the boundary
- avoid repeated warnings
- allow a manual retry outside Rescue
- keep all Free features available

### Verification outage after cache expiry

When no valid positive snapshot remains:

- suspend Plus
- keep all recovery data on the device
- keep every Free and never-paywalled feature available
- show: We could not refresh Plus right now. Your free BreakWave tools,
  including Rescue, are still available. Reconnect and try again.
- do not display this message inside Rescue or interrupt an active urge

### Clock safety

Changing the device clock must not extend offline Plus.

Implementation must preserve the latest trusted server time and fail
closed when an impossible backward-clock condition would otherwise
extend a snapshot.

## App-start and resume behavior

At app start and resume:

1. open the Free application path without waiting for billing
2. keep Rescue immediately reachable
3. load and cryptographically validate any signed snapshot
4. apply a valid cached state
5. refresh subscription status asynchronously
6. replace the cache only with a newer verified response
7. invalidate access immediately for a newer explicit negative state
8. avoid blocking navigation with a billing spinner

Billing startup failure is not an application-start failure.

## User-message rules

Billing messages must be:

- factual
- brief
- neutral
- nonjudgmental
- free from countdown pressure
- free from shame or recovery-pressure tactics
- clear about what remains available
- based on verified state
- dismissible unless the user is actively completing a Play flow

Billing messages must not appear inside Rescue, cover Rescue, delay
Rescue, or interrupt an active urge response.

A billing problem must never be presented as a recovery failure.

## Analytics and privacy

Recovery data allowed in lifecycle processing: zero.

Billing lifecycle telemetry may record only allowlisted operational
facts such as:

- normalized subscription state
- test-purchase marker
- acknowledgement status
- event type
- retry count
- redacted token reference
- verification timing
- error category without raw credentials or tokens

It must not contain triggers, logs, Personal Why content, mode choice,
plans, routines, journeys, contacts, reports, or support messages.

## Audit E handoff

Audit E must turn every lifecycle row into explicit tests.

At minimum, Audit E must cover:

- every SubscriptionPurchaseV2 state
- pending initial purchases
- pending plan replacements
- acknowledgement success, retry, and deadline risk
- duplicate and out-of-order RTDN
- linked purchase tokens
- restore success, no purchase, and outage
- device change
- 72-hour Active offline boundary
- 24-hour Grace Period offline boundary
- expired-cache behavior
- clock rollback
- Free and Rescue access in every state
- absence of recovery data from billing payloads and logs

## Current official technical basis

The implementation must be checked against current official Google
documentation again when billing code is introduced:

- https://developer.android.com/google/play/billing/lifecycle/subscriptions
- https://developer.android.com/google/play/billing/rtdn-reference
- https://developer.android.com/google/play/billing/integrate
- https://developer.android.com/google/play/billing/security
- https://developer.android.com/google/play/billing/subscriptions
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2

## Audit E testing decision

BW-88RC1H defines the mandatory billing acceptance-test contract in
BW_88_AUDIT_E_BILLING_TESTING_MATRIX.md.

The matrix covers static contracts, deterministic unit tests,
integration tests with controlled fakes, Google Play license-tester
testing, Play Billing Lab state transitions, and production-readiness
rehearsal.

Every P0 and P1 test must pass before paid release. Rescue availability,
entitlement correctness, acknowledgement, restoration, privacy, and
recovery-data isolation cannot be waived.

Audit E remains a pre-implementation contract and introduces no billing
dependency or production billing code.
