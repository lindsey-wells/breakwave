# BW-88RC1J — Billing Environment Readiness

## Status

Approved environment decision and readiness register for the future
BreakWave Plus billing system.

Readiness verdict:

READY FOR WP-02 CONTRACT AND THREAT-MODEL DESIGN.

NOT READY FOR BILLING CODE, CLOUD PROVISIONING, PURCHASE ENTRY,
ENTITLEMENT ENFORCEMENT, OR PAID LAUNCH.

This pass creates:

- no Google Cloud project
- no Cloud Billing account
- no backend service
- no database
- no Pub/Sub topic
- no service account
- no credential
- no signing key
- no Play Console product
- no product identifier
- no price
- no billing dependency
- no production billing code
- no entitlement change

## Confirmed application identity

Confirmed Android package name: com.cube23.breakwave

The package name must match the Google Play Console application and every
future Developer API verification request.

A package mismatch is a stop condition.

## Governing principle

Billing failure must never become recovery failure.

Every environment and deployment decision must preserve:

- immediate Rescue access
- protected Free features
- access to the user's recovery data
- privacy controls
- local recovery-data ownership
- app startup when billing services are unavailable
- clean rollback to the Free application

Recovery data is prohibited from billing infrastructure.

## Locked environment decisions

| ID | Decision | Locked direction |
|---|---|---|
| ENV-01 | Cloud provider | Google Cloud, owned through 24/3CJ LLC |
| ENV-02 | Project separation | Separate staging and production Google Cloud projects |
| ENV-03 | Primary region | us-east1, South Carolina |
| ENV-04 | Compute platform | Cloud Run services |
| ENV-05 | Billing datastore | Firestore in Native mode, regional us-east1 |
| ENV-06 | Lifecycle messaging | Google Cloud Pub/Sub |
| ENV-07 | RTDN ownership | One production-owned Play RTDN ingress topic for the BreakWave Android app |
| ENV-08 | Secret storage | Secret Manager with environment separation and pinned versions |
| ENV-09 | Snapshot signing | Cloud KMS asymmetric signing; private signing material never enters the app |
| ENV-10 | Deployment authentication | GitHub Actions Workload Identity Federation; no stored service-account JSON |
| ENV-11 | Runtime identity | Dedicated user-managed service identity for each backend responsibility |
| ENV-12 | Google Play API identity | Dedicated server-side service account with app-scoped Play Console permissions |
| ENV-13 | Operational logging | Structured, redacted Cloud Logging only |
| ENV-14 | Application-log retention | Initial 30-day application-log retention, reviewed before production |
| ENV-15 | Cost controls | Separate staging and production budgets and alerts before provisioning |
| ENV-16 | Data boundary | Billing metadata only; recovery data allowed is zero |
| ENV-17 | Service boundary | Public minimal client API separated from private billing worker |
| ENV-18 | Rollback boundary | Purchase entry and entitlement enforcement remain independently disableable |

These decisions may be changed only through a written architecture
revision with verifier updates.

## Why Google Cloud is selected

Google Cloud is selected because the required billing infrastructure is
already centered on:

- Google Play Developer API
- Google Cloud Pub/Sub for RTDN
- service-account and IAM access
- server-side workload identity
- managed regional compute and storage
- managed signing and secret services

This reduces cross-provider credential movement and allows the billing
backend to use Google-managed service identity rather than downloaded
private service-account keys.

This is an architecture decision, not an authorization to provision
resources.

## Project model

Two separate projects are required.

### Staging project

Provisional naming pattern:

breakwave-billing-stg-<owner-approved-suffix>

Purpose:

- deterministic and license-tester integration
- synthetic fixtures
- staging Cloud Run services
- staging Firestore records
- staging KMS key
- staging secrets
- staging logs
- staging budget
- no production purchase history

### Production project

Provisional naming pattern:

breakwave-billing-prod-<owner-approved-suffix>

Purpose:

- production verification
- production RTDN ingress
- production Cloud Run services
- production Firestore records
- production KMS signing key
- production secrets
- production logs
- production budget

Exact globally unique project IDs must be chosen during owner-controlled
provisioning.

They are intentionally not committed here.

## Ownership

### Production ownership

24/3CJ LLC must own or control:

- the Google Cloud organization or controlling account
- Cloud Billing
- staging and production projects
- Google Play developer access
- production service accounts
- production KMS keys
- production Secret Manager resources
- Pub/Sub resources
- production Firestore data
- production deployment approval
- budget alerts
- paid-launch approval
- incident, refund, and rollback authority

### Product and incident coordination

Don, also called Sparkles, remains BreakWave's primary product operator
and project lead.

24/3CJ LLC retains final financial, credential, production-access, and
paid-release authority.

### Development partner

Cube23 LLC may receive purpose-limited development access.

Cube23 access must be:

- named
- documented
- least privilege
- environment-specific
- revocable
- reviewed before production rollout
- removed when no longer required

Developer account passwords must never be shared.

## Backend service topology

The planned logical topology is:

    BreakWave Android app
        |
        | minimal versioned verification request
        v
    Public billing API on Cloud Run
        |
        | authenticated internal request
        v
    Private billing worker on Cloud Run
        |
        +--> Google Play Developer API
        +--> Firestore
        +--> Cloud KMS
        +--> Secret Manager

    Google Play RTDN
        |
        v
    Production-owned Pub/Sub topic
        |
        | authenticated push
        v
    Private RTDN ingress or billing worker
        |
        +--> authoritative Developer API refresh
        +--> idempotent lifecycle processing
        +--> environment-safe routing

The public API exists only because the Android application must reach a
backend endpoint.

Public network reachability does not mean anonymous trust.

WP-02 must define:

- request authentication
- nonce and replay controls
- protocol versioning
- rate limits
- abuse protection
- application-integrity input
- error behavior
- request-size limits
- strict schema validation

The private worker must not be directly callable by the Android app.

## RTDN environment boundary

Google Play configures RTDN for the Android application through one
topic name.

The selected direction is:

- the RTDN ingress topic is owned by the production project
- delivery uses authenticated Pub/Sub push
- the notification is treated only as a change signal
- the ingress queries the Google Play Developer API
- authoritative test-purchase status determines test routing
- verified license-test events may enter the staging lifecycle path
- production events remain in the production lifecycle path
- no production purchase token may be copied into staging
- duplicate message IDs must be idempotent
- out-of-order delivery must not overwrite a newer state

The exact router contract is deferred to WP-02.

No RTDN topic or subscription is created by this pass.

## Firestore decision

Firestore in Native mode is selected for minimal billing records.

The selected region is us-east1 to co-locate with Cloud Run.

Firestore may store only approved billing records such as:

- cryptographic token reference
- normalized subscription state
- product and base-plan reference
- verified expiry
- acknowledgement state
- test-purchase marker
- linked-token reference
- RTDN message deduplication record
- snapshot version
- verification timestamps
- retry state
- non-sensitive operational error category

Firestore must not store:

- recovery logs
- urges
- triggers
- Personal Why content
- current focus
- recovery mode
- plans
- routines
- Christian journeys
- contacts
- reminders
- support messages
- exported reports
- private reflection content

Firestore location cannot be casually changed after creation.

The production location must therefore be re-confirmed before the first
database is provisioned.

## Cloud KMS signing decision

Signed entitlement snapshots will use a production asymmetric signing
key in Cloud KMS.

The production worker may receive only permission to use the approved
key for signing.

Key administration and key usage should remain separable.

The Android application receives only the public verification material.

The application must never contain:

- the KMS private key
- a private signing key export
- a KMS administrator credential
- a service-account private key

Staging and production must use different keys and different public
verification material.

Key algorithm, rotation, version selection, snapshot canonicalization,
and emergency revocation rules are deferred to WP-02.

## Secret Manager decision

Secret Manager is selected for sensitive backend configuration that
cannot use native service identity alone.

Secrets must be:

- environment-specific
- accessed through a dedicated runtime identity
- granted individually where practical
- pinned to a reviewed version during deployment
- rotated through a controlled release
- absent from application source
- absent from Git history
- absent from screenshots
- absent from Termux history
- absent from CI logs
- absent from test evidence

The application must not receive backend secrets.

Service-account JSON files are not an approved deployment method.

## Deployment decision

Backend deployment will use a separate private backend repository
controlled by 24/3CJ LLC.

GitHub Actions will authenticate to Google Cloud through Workload
Identity Federation.

Separate deployment identities are required for staging and production.

The trust policy must restrict:

- repository
- organization or owner
- branch or protected deployment environment
- intended workflow
- intended Google Cloud project
- permitted service account

Production deployment must require an approval gate.

No long-lived Google Cloud key is to be stored as a GitHub secret.

The application repository remains separate from backend deployment
history.

## Runtime service identities

Each environment should use separate user-managed service accounts for:

- deployment
- public billing API runtime
- private billing worker runtime
- authenticated Pub/Sub push
- operational break-glass use when approved

A runtime service identity must receive only the permissions required by
its service.

Broad Owner and Editor roles are not approved runtime roles.

The billing worker is the only ordinary runtime component expected to
need:

- Google Play Developer API access
- Firestore billing-record access
- KMS signing permission
- selected Secret Manager access

The public API should not receive direct Google Play order-management
permissions merely because it receives mobile requests.

## Google Play Developer API access

A dedicated server-side service account must be created in the
appropriate 24/3CJ LLC Google Cloud project.

It must then be invited through Google Play Console Users and
permissions.

Access must be limited to the BreakWave application where Play Console
supports app-level scoping.

The required billing capabilities are expected to include:

- viewing financial data, orders, and cancellation information
- managing orders and subscriptions

Permissions must be rechecked against current official documentation
during provisioning.

No personal Google account should act as the ordinary production
runtime identity.

No service-account credential may be embedded in the Android app.

## Logging and privacy boundary

Application logs must be structured and allowlisted.

Permitted examples include:

- normalized state
- test-purchase marker
- redacted or cryptographic token reference
- event category
- message-ID hash
- protocol version
- retry count
- acknowledgement status
- verification duration
- HTTP status class
- non-sensitive error code
- deployment version

Prohibited examples include:

- raw purchase token
- service-account credential
- authorization header
- KMS private material
- Google order identifier when not operationally required
- email address
- recovery log
- trigger
- Personal Why
- plan
- contact
- report
- support message
- free-form user recovery text

Initial application-log retention is 30 days.

Security and administrative audit-log retention follows the approved
Google Cloud configuration and must be reviewed for cost and incident
needs before production.

Data Access audit logging should be evaluated selectively because it can
increase log volume and cost.

## Billing-record retention

The exact retention period for verified entitlement and order-reference
records is not yet approved.

Before WP-03 production storage is implemented, 24/3CJ LLC must approve:

- operational retention need
- accounting and tax need
- refund and dispute need
- deletion behavior
- token-reference retirement
- expired-subscription retention
- test-record cleanup
- legal review when warranted

The default rule is data minimization.

Recovery data remains prohibited regardless of retention policy.

## Cost posture

No exact monthly cost is claimed before load and retention assumptions
are measured.

Expected cost drivers include:

- Cloud Run requests and compute
- Firestore reads, writes, storage, and backups
- Pub/Sub delivery
- Cloud KMS signing operations
- Secret Manager access
- Cloud Logging volume and retention
- Artifact Registry
- network traffic
- CI deployment activity

Before provisioning:

- staging must receive its own budget
- production must receive its own budget
- alert recipients must belong to 24/3CJ LLC
- alert thresholds must be approved
- anomaly monitoring should be enabled when available
- service quotas and maximum scaling must be reviewed

A Cloud Billing budget is an alerting mechanism, not a guaranteed
spending cap.

No automated response may disable Free BreakWave or Rescue.

## Play Console commercial readiness

The following decisions remain pending owner approval:

- subscription product structure
- monthly base plan
- annual base plan
- whether both billing periods launch together
- trial or introductory offer
- regional launch scope
- grace-period configuration
- account-hold configuration
- pause availability
- resubscribe behavior
- pricing
- localized commercial copy
- product and base-plan identifiers

No identifier or price should enter production code before those
decisions are approved and configured in Google Play.

Current status:

- product created: no
- base plan created: no
- offer created: no
- price approved: no
- production purchase entry enabled: no

## Testing-account readiness

Existing closed testers are not assumed to be configured as Google Play
license testers.

Before tester-only purchase work:

- identify approved tester Google accounts
- add required accounts to license testing
- confirm which account downloaded the app
- confirm which account appears in the purchase dialog
- install Play Billing Lab where required
- document test payment instruments
- separate test accounts from production operations
- warn that non-license test purchases may create real charges
- define refund cleanup for any explicitly approved real-charge test

Current status:

- license-tester list verified: no
- Play Billing Lab verified: no
- slow approval instrument verified: no
- slow decline instrument verified: no
- tester evidence template prepared: yes, through Audit E

## Environment action register

| Action | Status | Owner | Required before |
|---|---|---|---|
| Confirm 24/3CJ LLC Cloud Billing account | Pending | 24/3CJ LLC | Project creation |
| Select globally unique staging project ID | Pending | 24/3CJ LLC | Staging provisioning |
| Select globally unique production project ID | Pending | 24/3CJ LLC | Production provisioning |
| Confirm us-east1 organizational policy compatibility | Pending | 24/3CJ LLC / Cube23 | Database creation |
| Create staging budget and alerts | Pending | 24/3CJ LLC | Staging resource creation |
| Create production budget and alerts | Pending | 24/3CJ LLC | Production resource creation |
| Configure environment-specific Workload Identity Federation | Pending | Cube23 with owner approval | First deployment |
| Create dedicated runtime service identities | Pending | Cube23 with owner approval | First deployment |
| Enable Google Play Developer API | Pending | 24/3CJ LLC | API integration |
| Grant app-scoped Play Console permissions | Pending | 24/3CJ LLC | Real verification |
| Approve billing-record retention | Pending | 24/3CJ LLC | WP-03 storage |
| Approve product and base-plan structure | Pending | 24/3CJ LLC | WP-05 catalog |
| Configure license testers | Pending | 24/3CJ LLC | WP-06 transactions |
| Verify Play Billing Lab accounts | Pending | QA operators | WP-06 transactions |
| Finalize RTDN test-versus-production routing contract | Pending | Cube23 / 24/3CJ LLC | WP-07 |
| Configure Play Console RTDN topic | Blocked until backend ingress exists | 24/3CJ LLC | WP-07 |
| Assign incident coordinator | Don/Sparkles designated | 24/3CJ LLC | Staging deployment |
| Assign production rollback approver | Pending formal confirmation | 24/3CJ LLC | Production deployment |

No action in this table requires sharing a secret with ChatGPT.

## Entry-gate review

| Gate | Review result |
|---|---|
| GATE-01 Audits A through E remain green | Passed |
| GATE-02 Production ownership confirmed | Passed: 24/3CJ LLC |
| GATE-03 Development role documented | Passed: Cube23 LLC, least privilege |
| GATE-04 Backend host, region, environments, and owner selected | Design passed; provisioning pending |
| GATE-05 Play products and tester strategy approved | Pending |
| GATE-06 Least-privilege service-account design | Design passed; provisioning pending |
| GATE-07 Staging and production separation | Design passed |
| GATE-08 Rollback controls preserve Free and Rescue | Design passed |
| GATE-09 Audit E evidence workflow prepared | Contract passed; storage location pending |
| GATE-10 Current official documentation reviewed | Passed for BW-88RC1J; repeat before implementation |

The pending gates prevent billing code and paid launch.

They do not prevent WP-02 synthetic contract and threat-model work.

## Readiness outcome

BreakWave is ready to proceed to:

BW-88RC1K — Billing Contracts and Threat Model

That milestone may define:

- versioned client request schema
- versioned backend response schema
- normalized lifecycle enum
- signed snapshot schema
- canonical serialization
- nonce and replay rules
- token hashing and redaction
- RTDN routing contract
- privacy allowlist and denylist
- deterministic synthetic fixtures
- threat model
- Audit E test mappings

BW-88RC1K must use synthetic values only.

It must not provision Google Cloud, install Play Billing, deploy a
backend, create a product, enable purchase entry, or change entitlement.

## Stop conditions

Environment work stops when:

- a credential is requested for chat or source control
- a service-account JSON file is downloaded without an approved need
- staging and production are mixed
- a production token is copied into staging
- a broad Owner or Editor role is used as normal runtime access
- a private signing key enters the app
- a raw purchase token enters logs
- recovery data enters billing storage
- project ownership is outside 24/3CJ LLC control
- billing can disable Free BreakWave
- billing can delay or block Rescue
- commercial identifiers are invented before Play Console approval
- provisioning begins without budgets and owner approval
- current official documentation has not been rechecked

Stopping environment setup must leave the current BreakWave application
unchanged and usable.

## Current official technical basis

This decision was reviewed against current official material including:

- https://developers.google.com/android-publisher/getting_started
- https://developer.android.com/google/play/billing/backend
- https://developer.android.com/google/play/billing/getting-ready
- https://developer.android.com/google/play/billing/rtdn-reference
- https://cloud.google.com/run/docs/locations
- https://cloud.google.com/run/docs/authenticating/overview
- https://cloud.google.com/run/docs/securing/service-identity
- https://cloud.google.com/firestore/docs/locations
- https://cloud.google.com/secret-manager/docs/best-practices
- https://cloud.google.com/kms/docs/create-validate-signatures
- https://cloud.google.com/billing/docs/how-to/budgets
- https://github.com/google-github-actions/auth

Official behavior and permissions must be rechecked at the work package
where each service is actually provisioned.
