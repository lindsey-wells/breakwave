# BW-88RC1I — Billing Implementation Entry Plan

## Status

Approved entry plan for the future implementation of BreakWave Plus
billing.

This pass introduces:

- no billing dependency
- no production billing code
- no backend deployment
- no Google Play product
- no product identifier
- no price
- no purchase or restore button
- no credential
- no entitlement change

Implementation may begin only through the ordered work packages and
entry gates defined here.

## Governing principle

Billing failure must never become recovery failure.

Billing work must remain subordinate to BreakWave's recovery mission.

At every implementation stage:

- Rescue remains immediately available
- protected Free features remain available
- user recovery data remains owned and accessible by the user
- billing startup cannot block application startup
- billing messages cannot interrupt an active Rescue flow
- local premium state cannot become production entitlement authority
- recovery data cannot enter billing infrastructure

## Green prerequisite chain

Billing implementation depends on the completed BW-88 audit chain:

- Audit A — Free-versus-Plus taxonomy
- Audit B — honest pre-billing language
- Audit C — privacy-first minimal-backend architecture
- Audit D — subscription lifecycle matrix
- Audit E — 98-case billing acceptance-test matrix

A future implementation patch may not weaken those contracts merely to
simplify billing code.

## Implementation-entry gates

| Gate | Required condition |
|---|---|
| GATE-01 | Audits A through E remain green in the complete historical verifier sweep |
| GATE-02 | 24/3CJ LLC confirms production ownership and approval authority |
| GATE-03 | Cube23 development access is documented and limited to the work required |
| GATE-04 | The backend host, region, environments, and operational owner are selected |
| GATE-05 | Google Play Console products, base plans, offers, and tester strategy are approved before code references them |
| GATE-06 | Service-account access follows least privilege and no credential enters the app repository |
| GATE-07 | Staging and production environments are separated |
| GATE-08 | Rollback controls can disable purchase entry without disabling Free BreakWave or Rescue |
| GATE-09 | Audit E evidence storage, redaction, and approval workflow are prepared |
| GATE-10 | The current official Google Play Billing and Developer API documentation is rechecked immediately before implementation |

All ten gates must be explicitly reviewed.

A gate may be marked not applicable only through a written decision from
24/3CJ LLC. Safety, privacy, entitlement, ownership, credential, and
Rescue gates cannot be waived.

## Ownership and responsibility

### Production owner

24/3CJ LLC owns:

- the Google Play developer account
- production billing products
- production Google Cloud resources
- production service accounts
- production secrets
- production subscription records
- paid-release approval
- incident and refund decisions
- final retention and deletion policy

### Development partner

Cube23 LLC may design, implement, test, and document the system under
access granted by 24/3CJ LLC.

Development access must be:

- purpose-limited
- least privilege
- revocable
- documented
- separated from personal Google accounts when practical
- removed when no longer required

### Application repository

The BreakWave application repository may contain:

- client interfaces
- public endpoint configuration
- public product identifiers after approval
- state models
- test fixtures containing no real tokens
- public signing-verification material when required
- documentation and verifier rules

It must not contain:

- service-account JSON
- private signing keys
- Google Cloud credentials
- raw production purchase tokens
- backend database passwords
- webhook or Pub/Sub secrets
- tester passwords
- private user billing records
- recovery data copied into billing fixtures

### Backend repository

The production verification backend should live in a separate private
repository controlled by 24/3CJ LLC.

Its deployment and secret history must not depend on the public or
client-facing application repository.

## Environment model

The implementation must use at least:

- local or deterministic fake environment
- staging verification environment
- production verification environment

The staging environment must have:

- separate credentials
- separate data storage
- separate logging
- separate signing keys
- test-only access controls
- no production purchase-token history

Production data must not be copied into staging for convenience.

## Product and catalog decisions

Before a product identifier is added to application code, 24/3CJ LLC
must approve:

- subscription product structure
- base-plan structure
- billing periods
- renewal behavior
- regional availability
- introductory offers or trials
- eligibility rules
- pause and resubscribe settings
- grace-period and account-hold configuration
- tester accounts
- launch regions

Prices, localized currency, billing periods, offer text, and eligibility
must come from current Google Play product details.

Production UI must not hardcode those commercial claims.

Product-details objects must be refreshed through Google Play rather
than treated as durable entitlement or long-term catalog authority.

## Runtime control model

Billing must be introduced behind independent controls.

The conceptual controls are:

- billing connection enabled
- product catalog visible
- tester-only purchase entry enabled
- production purchase entry enabled
- restore entry enabled
- backend verification enabled
- RTDN processing enabled
- entitlement enforcement enabled

A single switch must not simultaneously expose products, permit
purchases, enforce paid access, and enable lifecycle processing.

The initial production-safe state is:

- Free BreakWave operational
- Rescue operational
- billing purchase entry disabled
- entitlement enforcement disabled
- existing local preview behavior unchanged until replaced deliberately

A control-plane failure must fail toward the Free application, not
toward application lockout.

## Client/backend contract boundary

The application may send only the billing allowlist required for
verification, such as:

- package name
- approved product identifier
- purchase token
- application version
- platform
- pseudonymous installation or request identifier when approved
- protocol version
- request nonce or integrity material when approved

The application must not send:

- recovery logs
- urges
- triggers
- current focus
- Personal Why content
- recovery mode
- plans
- routines
- Christian journeys
- contacts
- reports
- support messages
- reminder content
- exported recovery data

The backend response may include:

- normalized entitlement state
- feature tier
- verification timestamp
- authorization valid-through timestamp
- verified subscription expiry
- grace, pause, or cancellation metadata required for display
- snapshot version
- signature
- retry guidance
- non-sensitive error category

It must not return Google service credentials, raw internal records, or
another user's billing state.

## Signed entitlement snapshot boundary

A production signed snapshot must be:

- issued only by the verification backend
- cryptographically verifiable by the application
- versioned
- bound to the intended app and entitlement
- bounded by server-authorized time
- replaceable by a newer authoritative result
- invalidated by a newer verified negative state
- incapable of granting first-time offline entitlement
- incapable of extending access through device-clock rollback

Snapshot signing and verification design must be reviewed before client
storage code is merged.

No private signing key may be present in the app.

## Ordered implementation work packages

| Work package | Scope | Billing exposure |
|---|---|---|
| WP-00 | Lock this entry plan and preserve Audits A through E | None |
| WP-01 | Record environment, ownership, Google Cloud, Play Console, product, and tester readiness without adding billing code | None |
| WP-02 | Define versioned client/backend schemas, fixtures, state mapping, privacy allowlist, and threat model | None |
| WP-03 | Build the minimal backend verification core against deterministic fakes, then staging Google APIs | Backend staging only |
| WP-04 | Build signed entitlement snapshots and a production entitlement-source adapter behind disabled controls | No purchase entry |
| WP-05 | Add the current supported Play Billing client adapter and product-catalog loading behind disabled controls | Catalog testing only |
| WP-06 | Add tester-only purchase, pending, acknowledgement, and restore flows | License testers only |
| WP-07 | Add RTDN ingestion, deduplication, authoritative refresh, linked-token processing, and lifecycle updates | Staging lifecycle only |
| WP-08 | Implement and execute the Audit E automated, license-tester, Play Billing Lab, device, privacy, and failure tests | Controlled testing |
| WP-09 | Assemble paid-launch evidence, review rollback, approve products, and perform a limited production rollout | Explicit approval required |

Work packages must be completed in order unless a written dependency
review proves that a later package can be prepared without exposing
users or weakening an earlier gate.

No work package may silently combine backend deployment, client purchase
entry, entitlement enforcement, and paid rollout.

## WP-01 — Environment readiness

WP-01 is the next executable milestone after this plan.

It must record decisions without installing billing code.

Required outputs include:

- chosen backend platform
- staging and production regions
- production owner
- development operators
- deployment method
- secret-management method
- logging and retention boundaries
- Google Cloud project ownership
- Android Publisher API access model
- Pub/Sub ownership model
- Play Console product decision status
- package-name confirmation
- license-tester list status
- Play Billing Lab readiness
- incident owner
- rollback owner
- cost-review owner
- unresolved decisions and blockers

WP-01 must not request that secrets be pasted into ChatGPT, Termux
history, repository files, screenshots, or test evidence.

## WP-02 — Contracts and threat model

Before backend or client billing code:

- define request and response schemas
- define normalized lifecycle enum
- define error categories
- define snapshot payload and signature rules
- define protocol-version behavior
- define token redaction and deduplication
- define replay prevention
- define linked-purchase-token precedence
- define RTDN message-ID deduplication
- define privacy allowlist and denylist
- define retention and deletion behavior
- create deterministic fixtures for every Audit D state
- map every contract to Audit E test IDs

Fixtures must use synthetic values only.

## WP-03 — Verification backend

The first backend implementation must:

- accept only the versioned billing contract
- reject malformed and unauthorized requests
- verify subscriptions with the current Google Play Developer API
- treat RTDN as a signal rather than entitlement proof
- record normalized authoritative state
- record token references without exposing raw tokens in logs
- acknowledge eligible initial subscriptions only after durable recording
- remain idempotent
- issue signed entitlement snapshots
- exclude all recovery data
- provide health and operational evidence without leaking secrets

The backend must be testable against deterministic fakes before real
Google credentials are attached.

## WP-04 — Entitlement source and snapshots

The client must replace temporary local premium authority through the
existing boundary:

BreakWaveAccessService
to BreakWaveAccessPolicy
to production BreakWaveEntitlementSource

The production entitlement source must:

- validate signed snapshots
- honor Audit D time boundaries
- fail closed for Plus
- fail open for the protected Free application
- refresh asynchronously
- avoid blocking application startup
- avoid blocking Rescue
- preserve local recovery data when Plus is suspended
- coexist with the temporary source until controlled migration is proven

The temporary local source must not be removed in the same patch that
introduces untested production entitlement behavior.

## WP-05 — Billing client and catalog

The Play Billing adapter must be isolated from feature-access policy.

Its responsibilities include:

- establish and recover the Play Billing connection
- query current subscription product details
- expose current Play-provided price and offer information
- query current purchases at startup and resume
- detect pending and completed purchases
- send tokens to the verification backend
- never grant Plus directly
- never store ProductDetails as entitlement authority
- never block Rescue when Play Billing is unavailable

The current supported Billing Library version must be selected from
official documentation at implementation time and pinned deliberately.

## WP-06 — Tester-only transactional flows

Purchase and restore entry must first be limited to approved testers.

Tester-only work must prove:

- approved product selection
- purchase launch
- canceled purchase dialog
- pending purchase
- delayed approval
- delayed decline
- verified entitlement
- durable recording
- acknowledgement
- acknowledgement retry
- restoration
- no-purchase restoration
- process death and resume recovery
- accurate user messaging
- no interruption of Rescue

Production purchase entry remains disabled.

## WP-07 — RTDN and lifecycle

RTDN implementation must:

- authenticate delivery
- decode and validate messages
- deduplicate by message identity
- tolerate retries and out-of-order delivery
- query the authoritative Developer API resource
- process linked purchase tokens
- preserve a valid old entitlement during a pending replacement
- apply Grace Period, Account Hold, Pause, Cancellation, Expiration,
  Revocation, and recovery rules from Audit D
- issue updated snapshots
- invalidate older positive snapshots after verified negative state
- keep recovery data completely outside the event pipeline

## WP-08 — Audit E execution

No paid rollout may begin until Audit E execution provides evidence for:

- 98 documented billing cases
- every P0 case
- every P1 case
- automated state mapping
- acknowledgement behavior
- pending purchases
- linked-token behavior
- duplicate and out-of-order RTDN
- restore on original and replacement devices
- offline Active and Grace boundaries
- clock rollback
- snapshot tampering and replay
- privacy allowlist and denylist
- raw-token log scans
- Rescue and protected-Free behavior in every state

Failed evidence must link to a remediation commit and rerun.

## WP-09 — Paid-launch review

The paid-launch review must confirm:

- approved Play products are active
- production backend is healthy
- production RTDN is healthy
- production signing keys are protected
- production purchase entry is independently controllable
- rollback has been rehearsed
- no P0 or P1 Audit E defect remains
- no open entitlement discrepancy remains
- no recovery-data leak exists
- no raw-token or credential leak exists
- support and refund responsibilities are assigned
- 24/3CJ LLC approves the evidence

A paid launch begins with a limited controlled rollout.

It is not bundled with a broad user-interface redesign.

## Required implementation patch discipline

Every billing implementation patch must:

1. start from a known green commit
2. create a safety branch
3. define one narrow purpose
4. change only intended files
5. add or update a targeted verifier
6. run relevant unit and widget tests
7. run the complete historical verifier sweep
8. run CI
9. preserve rollback controls
10. remain untagged until the milestone and evidence are approved

No giant billing patch is permitted.

Backend, client adapter, purchase flow, RTDN, and paid rollout must not
arrive in one commit.

## Stop conditions

Implementation stops immediately when:

- Rescue is delayed, covered, gated, or made billing-dependent
- a pending purchase grants Plus
- a local preference grants production Plus
- the client treats RTDN as authoritative proof
- a purchase is acknowledged before verification and durable recording
- a verified purchase cannot be restored
- a negative lifecycle state fails to remove Plus at the approved boundary
- device-clock manipulation extends entitlement
- raw purchase tokens enter logs or evidence
- credentials enter source control
- recovery data enters billing infrastructure
- prices, trials, or billing periods are hardcoded
- one feature flag can lock the Free application
- production and staging secrets or data are mixed
- an implementation patch weakens Audits A through E
- current official API behavior has not been rechecked

Stopping billing work must leave the existing Free application usable.

## Rollback requirements

Before tester purchase entry is enabled, BreakWave must be able to:

- hide purchase entry
- disable new purchase launch
- disable entitlement enforcement
- keep restore diagnostics available to approved testers when safe
- continue Free operation
- continue Rescue
- preserve local recovery data
- revoke compromised snapshots through a newer authoritative response
- rotate backend signing material
- disable RTDN processing without crashing the app
- return to the last green app release

Rollback must not require deletion of the user's recovery history.

## Evidence requirements

Each work package must record:

- milestone identifier
- commit SHA
- CI run ID
- changed files
- verifier results
- automated test results
- environment affected
- flags enabled
- flags disabled
- secrets accessed by role, never by value
- unresolved risks
- rollback instructions
- approval status

Screenshots and logs must redact accounts, credentials, order IDs, and
purchase tokens.

## Next milestone

The next safe milestone is:

BW-88RC1J — Billing Environment Readiness

BW-88RC1J remains a planning and configuration-readiness pass.

It must not install the billing package, deploy a production backend,
create live purchase entry, or change entitlement behavior.

## Current official technical basis

Implementation must recheck the current official documentation at every
relevant work package:

- https://developer.android.com/google/play/billing/backend
- https://developer.android.com/google/play/billing/integrate
- https://developer.android.com/google/play/billing/security
- https://developer.android.com/google/play/billing/lifecycle
- https://developer.android.com/google/play/billing/lifecycle/subscriptions
- https://developer.android.com/google/play/billing/rtdn-reference
- https://developer.android.com/google/play/billing/test
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2/get

## BW-88RC1J environment readiness decision

BW-88RC1J selects Google Cloud with separate staging and production
projects, Cloud Run, regional Firestore in us-east1, Pub/Sub, Secret
Manager, Cloud KMS asymmetric signing, and GitHub Actions Workload
Identity Federation.

The confirmed Android package name is com.cube23.breakwave.

Environment architecture is ready for synthetic contract and
threat-model design.

Cloud provisioning, product decisions, license-tester configuration,
retention approval, and production permissions remain pending.

The next milestone is BW-88RC1K Billing Contracts and Threat Model.

BW-88RC1K adds no billing dependency, product, price, credential,
backend deployment, purchase entry, or entitlement change.
