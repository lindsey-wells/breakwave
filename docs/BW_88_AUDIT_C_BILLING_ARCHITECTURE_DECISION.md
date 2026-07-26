# BW-88 Audit C — Billing Architecture Decision

## Status

Approved architecture decision for the future BreakWave Plus billing
implementation.

This decision does not install Google Play Billing, create subscription
products, enable purchases, deploy a backend, or change current access.

## Decision

BreakWave will use a privacy-first minimal-backend architecture.

The Android client will display Play-provided offers and launch the
Google Play purchase flow. The device will not be the authoritative
source of production Plus access.

Production access will require a backend-verified entitlement.

Architecture flow:

    Google Play Billing client
            |
            | purchase token
            v
    BreakWave verification backend
            |
            | Google Play Developer API
            v
    Verified entitlement record
            |
            | signed entitlement snapshot
            v
    Production BreakWaveEntitlementSource
            |
            v
    BreakWaveAccessService
            |
            v
    BreakWaveAccessPolicy

## Rejected approach

BreakWave rejects permanent client-only billing authority.

Production Plus access must never depend solely on:

- a local Boolean unlock
- SharedPreferences
- an Android purchase callback
- an order identifier
- an unverified cached purchase
- presentation code
- a debug or preview switch

PremiumStateStore remains temporary testing compatibility only.

## Android-client responsibilities

The Android client may eventually:

1. connect to Google Play Billing
2. request current Play-provided product details
3. display only Play-provided prices and billing periods
4. launch the Play purchase flow
5. receive purchase updates
6. query purchases at startup and resume
7. offer Restore Purchases
8. send eligible purchase tokens to the verification backend
9. receive a signed entitlement snapshot
10. expose the snapshot through BreakWaveEntitlementSource

The Android client must not:

- grant Plus directly from a purchase callback
- grant Plus while a purchase is pending
- acknowledge an unverified purchase
- contain service-account credentials
- contain backend signing keys
- send recovery information to billing infrastructure
- treat local premium state as production truth

## Verification-backend responsibilities

The minimal backend will:

1. receive the package name, product identifier, and purchase token
2. reject malformed or unexpected products
3. verify the token using the Google Play Developer API
4. confirm the token belongs to BreakWave
5. evaluate the current subscription state
6. prevent duplicate token use
7. record entitlement before initial acknowledgement
8. acknowledge eligible initial purchases
9. return a signed entitlement snapshot
10. process lifecycle notifications idempotently
11. re-query Google Play after lifecycle notifications
12. handle linked purchase tokens safely
13. suspend or revoke Plus when required

The backend is not a recovery-data backend, analytics platform, social
service, advertising platform, or general BreakWave account database.

## Purchase-verification rule

A Play purchase callback is evidence that a Play flow changed. It is not
final entitlement proof.

BreakWave Plus will be granted only after the backend verifies the
purchase token and records the entitlement.

Pending purchases must not grant Plus.

Initial purchases must be acknowledged only after verification and
entitlement recording succeed.

## Lifecycle notifications

Real-time developer notifications, or RTDN, will notify the backend that
purchase state may have changed.

An RTDN is a signal to refresh state. It is not final entitlement proof.

For each relevant notification, the backend will:

1. reject duplicate message processing
2. identify the affected purchase token
3. query the Google Play Developer API
4. read the current authoritative subscription state
5. update the entitlement record
6. issue the resulting entitlement state

## Initial entitlement mapping

Audit D will define the complete lifecycle matrix.

Audit C establishes these architecture rules:

| Verified state | Plus access |
|---|---|
| Active | Granted |
| Grace period | Granted |
| Canceled but paid time remains | Granted until verified expiry |
| Pending | Not granted |
| Account hold | Suspended |
| Paused | Suspended |
| Expired | Revoked |
| Revoked or voided | Revoked |
| Unknown or unverifiable | Not newly granted |

Free and never-paywalled features remain available in every state.

## Restore Purchases

Restore Purchases will not grant access merely because the user pressed
the button.

The restore flow will:

1. query current purchases through Google Play
2. collect eligible purchase tokens
3. send those tokens to the verification backend
4. receive a verified entitlement snapshot
5. refresh BreakWaveAccessService
6. report successful restoration only after verified Plus access returns

A new device may restore an active purchase when Google Play returns that
purchase for the account on the new device.

BreakWave will not claim cross-account, cross-store, or cross-platform
restoration unless those systems are separately built and tested.

## User identity

A mandatory BreakWave recovery account is not required for the first
Google Play subscription implementation.

The purchase token will be the primary billing-record identifier.

BreakWave will not invent an account identifier solely to populate
Google Play account-obfuscation fields.

If a real BreakWave account is introduced later, an obfuscated account
identifier will require a separate privacy review.

## Signed entitlement snapshot

The backend will return a signed entitlement snapshot containing only
the minimum billing information needed by the app:

- entitlement tier
- verified subscription state
- product identifier
- verification timestamp
- entitlement expiry or valid-through timestamp
- offline-cache limit
- test-purchase marker when applicable
- snapshot version
- cryptographic signature

The signing key remains server-side.

The Android application may contain only public verification material.

The snapshot must contain no recovery data.

## Offline behavior

A first-time Plus grant requires online backend verification.

After verification, BreakWave may use a signed server-authorized
entitlement snapshot for a limited offline period.

Audit D will decide the exact duration and state behavior.

An offline snapshot must never:

- extend itself
- exceed its authorized limit
- override a newer verified revocation
- grant Plus for the first time
- affect Free or never-paywalled access

When status cannot be refreshed, Plus may fail closed while Rescue and
protected Free features remain available.

## Billing-data allowlist

Billing infrastructure may store only information needed to verify,
acknowledge, restore, and synchronize purchases:

- package name
- Play product identifier
- base-plan or offer identifier when returned
- purchase token protected at rest
- cryptographic token hash
- linked purchase token when returned
- subscription state
- acknowledgement state
- purchase and expiry timestamps
- test-purchase marker
- RTDN message identifier and event timestamp
- backend verification timestamps
- signed entitlement-snapshot metadata

## Billing-data denylist

The following must never enter billing requests, entitlement records,
purchase-token logs, RTDN processing, or billing analytics:

- recovery logs
- urge, slip, victory, or check-in entries
- triggers
- risky times
- Personal Why text or images
- recovery mode
- Christian or secular selection
- personal recovery plans
- guided-routine progress
- Christian-journey progress
- recovery reports or exports
- trusted-contact information
- email preferences
- reminder settings
- privacy-lock PINs
- support messages
- notes or CBT reflections
- diagnoses or medical information

## Secrets and logging

Google Play API credentials and backend signing keys must remain outside:

- the Android application
- the Git repository
- GitHub Actions logs
- client crash reports
- user-visible diagnostics

Raw purchase tokens must not appear in normal application logs,
analytics, crash reports, or support emails.

Backend logs should use redacted or cryptographic token references.

## Ownership and access

Google Play products, Play Console permissions, billing credentials,
backend infrastructure, and production secrets belong under the
24/3CJ LLC production environment.

Cube23 LLC may implement and maintain the technical system as the
development partner without becoming the owner of user purchases or
production billing credentials.

Production access must follow least-privilege rules.

## Failure containment

Billing failure must never become recovery failure.

Failures involving Play Billing, Google APIs, RTDN, the verification
backend, entitlement storage, or the network must not block:

- Rescue
- onboarding
- basic logging
- privacy controls
- basic secular support
- basic Christian support
- emergency and human-support information
- access to the user's own recovery data

Plus may fail closed. Recovery safety remains open.

## Implementation boundary

BW-88RC1F adds an architecture decision only.

It does not introduce:

- a Flutter billing package
- native BillingClient code
- product identifiers
- prices
- trials
- purchase buttons
- Restore Purchases controls
- backend deployment
- Pub/Sub configuration
- service-account credentials
- entitlement changes
- Play Console configuration

## Deferred decisions

The following remain deferred:

- Flutter billing-package selection
- backend runtime or cloud provider
- entitlement database
- entitlement signing format
- exact offline duration
- product and base-plan identifiers
- monthly, annual, trial, or introductory offers
- Play Console grace-period configuration
- account-hold configuration
- refund-support procedures
- cross-platform account architecture

## Implementation review sources

Current official Google Play Billing and Android Publisher documentation
must be checked again when implementation begins.

## Audit D lifecycle decision

BW-88RC1G defines the exact state, restoration, failure, and offline
behavior in BW_88_AUDIT_D_SUBSCRIPTION_LIFECYCLE_MATRIX.md.

The lifecycle contract grants Plus during Active, Grace Period, and a
canceled-but-unexpired paid term. It suspends Plus during an effective
Pause or Account Hold and revokes Plus after Expiration, Revocation, or
a verified voided purchase.

A signed Active or canceled-but-unexpired snapshot may authorize offline
Plus for at most 72 hours and never beyond verified expiry. A signed
Grace Period snapshot may authorize offline Plus for at most 24 hours.

A first-time grant always requires online verification. Billing messages
must never block or appear inside Rescue.
