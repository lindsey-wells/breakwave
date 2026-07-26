# BreakWave Plus — Paid Launch Gate

BreakWave Plus must not accept payment merely because billing integration is available.

Paid access remains disabled until the product delivers a substantial, repeatable recovery system that clearly exceeds the free MVP.

## Required before any paid launch

### 1. Meaningful insights

- Working 30-day and 90-day recovery history
- Trigger-frequency and risky-time patterns
- Weekly summaries generated from real recovery logs
- Clear explanations of what the data means
- No fabricated, placeholder, or demonstration data

### 2. Personal recovery plan

The user must be able to create, save, review, and update a plan containing:

- Primary triggers
- Dangerous times and situations
- Reasons for change
- Redirect actions
- Trusted support
- Phone and environment boundaries
- An after-slip reset plan

### 3. Guided routines

At least five complete routines must be usable repeatedly:

- Bedtime protection
- Stress
- Loneliness
- Phone boundaries
- After-slip recovery

Each routine must provide saved progress or a meaningful completion state.

### 4. Accountability tools

- User-controlled check-in templates
- Shareable summaries based on selected recovery information
- Ready-to-send support messages
- Clear privacy controls before anything leaves the device

### 5. Christian depth

Christian depth must be more than static reading cards.

It must include multi-step recovery journeys with:

- Scripture or a clear faith anchor
- Reflection
- A practical action
- Prayer
- Saved progress
- Optional journaling
- Connections to Rescue and the personal recovery plan

Core themes should include shame, secrecy, loneliness, nighttime temptation, rebuilding integrity, after-slip restoration, and relationship repair.

### 6. Meaningful exports

Paid exports must include selected recovery information such as:

- Recovery history
- Trigger and risky-time summaries
- Weekly summaries
- Personal-plan information
- Accountability reports

Exporting only email-preference data does not satisfy this requirement.

### 7. Subscription readiness

Before billing is enabled:

- Google Play Billing must be implemented and tested
- Purchases and entitlement restoration must work
- Cancellation and renewal language must be clear
- Monthly and annual plans must include the same core recovery features
- Annual pricing may provide a discount, but must not gate essential recovery tools
- No debug unlock or local preview flag may grant paid entitlement
- Internal, closed, and production testing must pass

## Product standard

A Plus subscriber should receive value they can return to weekly.

Static copy, placeholder gates, future-feature promises, or a small collection of reading cards are not sufficient grounds for charging a subscription.

### 8. Verified billing architecture

Before paid launch:

- The Android client must not be the production entitlement authority
- Purchase tokens must be verified through a minimal secure backend
- Initial purchases must be acknowledged only after verification and
  entitlement recording
- Pending purchases must not grant Plus
- RTDN must trigger an authoritative Google Play API refresh
- RTDN processing must be idempotent
- Restore Purchases must re-verify current Play purchases
- A signed entitlement snapshot must replace local premium authority
- Raw purchase tokens and backend credentials must not enter app logs
- No recovery data may enter billing infrastructure
- Free and never-paywalled features must survive every billing failure
- Audit D lifecycle rules and Audit E test coverage must be complete

The approved design is documented in
docs/BW_88_AUDIT_C_BILLING_ARCHITECTURE_DECISION.md.

### 9. Subscription lifecycle readiness

Before paid launch:

- Active, Grace Period, Canceled, Paused, Account Hold, Expired,
  Revoked, Pending, and unknown states must follow the Audit D matrix
- Pending purchases must never grant Plus
- A pending plan change must preserve the verified old entitlement
- Canceled subscriptions must retain access only through verified expiry
- Effective pauses and account hold must suspend Plus
- Expiration and revocation must remove Plus
- Restore Purchases must report success only after verification
- Active offline access must stop after its 72-hour authorization limit
- Grace Period offline access must stop after its 24-hour limit
- Clock rollback must not extend offline access
- Duplicate and out-of-order RTDN must be safe
- Billing status must refresh without blocking app launch or Rescue
- Every state must preserve Free and never-paywalled features
- Audit E must test every lifecycle and failure row

The approved lifecycle matrix is documented in
docs/BW_88_AUDIT_D_SUBSCRIPTION_LIFECYCLE_MATRIX.md.

### 10. Billing test evidence

Before paid launch:

- Every Audit E P0 and P1 test must pass
- Automated state, precedence, snapshot, privacy, and access tests must
  run in CI
- License-tester purchase, Pending, renewal, Grace, Hold, cancellation,
  pause, expiration, and restore evidence must be complete
- RTDN delivery, deduplication, ordering, and authoritative refresh must
  be proven
- Initial-purchase acknowledgement and retry must be proven
- Restore Purchases must be verified on the original and another device
- Active and Grace offline boundaries must be proven
- Clock rollback must not extend Plus
- Raw credentials and purchase tokens must be absent from logs
- Recovery data must be absent from billing payloads and evidence
- Rescue and protected-Free access must pass in every billing state
- No P0 or P1 defect may remain open
- 24/3CJ LLC must approve the release evidence

The approved testing contract is documented in
docs/BW_88_AUDIT_E_BILLING_TESTING_MATRIX.md.

### 11. Billing implementation sequencing

Before paid launch:

- All ten BW-88RC1I implementation-entry gates must be reviewed
- Work packages WP-00 through WP-09 must remain ordered and evidenced
- Backend, client adapter, transactions, RTDN, testing, and rollout must
  remain separable
- Product and commercial decisions must be approved before identifiers
  or claims enter production code
- Staging and production environments must remain separate
- Purchase entry and entitlement enforcement must be independently
  controllable
- Rollback must preserve Free BreakWave, Rescue, and recovery data
- No credential may enter the application repository
- No recovery data may enter billing infrastructure
- Every implementation patch must preserve Audits A through E
- 24/3CJ LLC must approve paid-release evidence

The approved sequencing plan is documented in
docs/BW_88RC1I_BILLING_IMPLEMENTATION_ENTRY_PLAN.md.

### 12. Billing environment readiness

Before paid launch:

- 24/3CJ LLC must control the Google Cloud and Cloud Billing resources
- Staging and production must use separate projects and identities
- Cloud Run and Firestore regions must be confirmed before creation
- Production RTDN ingress must be owned through the production project
- Test and production purchase events must remain isolated
- GitHub deployment must use Workload Identity Federation rather than a
  stored service-account key
- Secret Manager and KMS permissions must use least privilege
- Runtime identities must not use broad Owner or Editor roles
- The app must receive public verification material only
- Billing records must exclude all recovery data
- Raw purchase tokens and credentials must be absent from logs
- Staging and production budgets and alerts must exist
- Billing-record retention must be approved
- Product, base-plan, offer, tester, and pricing decisions must be
  approved in Google Play Console
- Pending environment actions must be closed before their dependent work
  package
- Environment failure must preserve Free BreakWave and Rescue
- 24/3CJ LLC must approve production provisioning and paid rollout

The approved readiness register is documented in
docs/BW_88RC1J_BILLING_ENVIRONMENT_READINESS.md.
