# BW-88RC1K — Billing Contracts and Threat Model

## Status

WP-02 contract and threat-model design for the future BreakWave Plus billing system.

Baseline: `8805a2231577c9ca59d308cda0c4b2edbfdf4988` (`bw-edu-01a-green`).

This pass introduces no billing dependency, no production billing code, no backend deployment, no Google Cloud provisioning, no Google Play product or price, no purchase or restore entry, no credential, and no entitlement change.

**Governing principle: billing failure must never become recovery failure.**

Rescue and every protected Free recovery capability remain available regardless of billing state. Recovery data allowed in billing infrastructure is zero.

## Current official technical review

Reviewed 2026-08-11 against current official Google documentation before defining this contract:

- Google Play secure-backend guidance: purchase verification belongs on a secure backend; Pending purchases must not grant entitlement; subscriptions should be verified with `purchases.subscriptionsv2.get`; duplicate purchase-token processing must be prevented.
- Google Play subscription lifecycle: `purchases.subscriptionsv2.get` is the source of truth for subscription state; current V2 states include `UNSPECIFIED`, `PENDING`, `ACTIVE`, `PAUSED`, `IN_GRACE_PERIOD`, `ON_HOLD`, `CANCELED`, `EXPIRED`, and `PENDING_PURCHASE_CANCELED`.
- RTDN: notifications are change signals only; the backend must query the Developer API for complete authoritative state and deduplicate Pub/Sub `messageId` values.
- Google Play Developer API release notes current through 2026-07-06, including the newer on-hold and grace-period state contexts.
- Play Integrity standard requests may be used as app-integrity input and include replay protections; BreakWave still maintains its own request-id/nonce deduplication boundary.
- Cloud KMS recommends `EC_SIGN_P256_SHA256` for elliptic-curve digital signatures; KMS returns ECDSA signatures in DER form.

Billing implementation must recheck current official documentation again at the work package that introduces code.

## Contract files

WP-02 locks these machine-readable contracts:

1. `client_verification_request.schema.json`
2. `client_verification_response.schema.json`
3. `entitlement_snapshot.schema.json`
4. `normalized_lifecycle.json`
5. deterministic Audit D contract fixtures
6. Audit E 98-case traceability

All JSON contracts use strict schemas and reject unknown top-level fields unless a later protocol version explicitly permits them.

## Protocol versioning

Protocol identifier: `bw.billing.verify.v1`.

Rules:

- A v1 client sends exactly a v1 request.
- The backend rejects unsupported major versions with `unsupported_protocol` and no entitlement change.
- Optional compatible additions require a new documented minor contract; v1 schemas remain immutable after paid launch.
- The client must not infer success from HTTP 2xx alone. Entitlement comes only from a verified signed snapshot.
- Unknown response fields are not accepted by the v1 production parser.
- A protocol error never blocks app startup, Rescue, or protected Free features.

## Client → backend verification request

Allowed request data is billing-only:

- schema version
- request ID
- request nonce
- request purpose
- package name
- platform
- app version and version code
- pseudonymous installation reference when enabled
- approved product identifier when available from Play
- raw purchase token, transiently and only because the Developer API requires it
- Play Integrity standard token and request hash when production policy requires it

The raw purchase token is classified **secret billing material**. It may exist in TLS-protected request memory and private worker memory only. It must not enter application logs, Cloud Logging, analytics, crash reports, support exports, screenshots, fixtures, evidence bundles, or shell history.

The v1 contract does not authorize durable plaintext purchase-token storage.

Persistent token identity uses:

`tokenRef = HMAC-SHA-256(environment-scoped secret, UTF8(purchaseToken))`

The environment secret never enters the app. `tokenRef` may be stored and logged where the allowlist permits it. Staging and production use different HMAC secrets, so references are not portable across environments.

If WP-03 determines that durable acknowledgement retries require recoverable token material, a written architecture revision must approve a sealed/encrypted representation before implementation. RC1K does not silently authorize one.

## Request authentication and replay controls

The production public verification endpoint is reachable by the Android app but is not anonymously trusted.

Required controls:

1. TLS only.
2. Exact package-name match: `com.cube23.breakwave`.
3. Strict JSON schema and body-size limit.
4. Cryptographically random request nonce with at least 128 bits of entropy.
5. UUID request ID.
6. Server-side deduplication of request ID + nonce hash for 15 minutes; a replay receives no entitlement response and the client must create a new request.
7. Production Play Integrity standard token bound to a canonical request hash when enabled. The v1 `requestHash` is unpadded base64url SHA-256 over RFC 8785 JCS bytes containing `schemaVersion`, `requestId`, `requestNonce`, `requestPurpose`, `packageName`, `appVersionCode`, optional `productId` (or null), and `purchaseTokenSha256`. The raw purchase token is never placed in the integrity hash payload.
8. Verify package/certificate/app-recognition inputs from the integrity verdict before returning a positive snapshot.
9. Rate limiting using non-recovery operational signals only.
10. Replayed, malformed, unauthorized, or integrity-rejected requests return no billing state beyond the minimum error category.

No device clock value is trusted to grant or extend entitlement.

## Privacy allowlist

Billing infrastructure may process/store only what is required for billing operations, including:

- protocol version
- request ID / nonce hash for short-lived replay control
- package name / platform / app version
- pseudonymous installation reference when approved
- product/base-plan references after owner approval
- `tokenRef`
- normalized lifecycle state
- entitlement tier
- verified expiry / pause / grace boundaries
- acknowledgement state
- test-purchase marker
- linked-token reference
- RTDN message-ID hash
- verification timestamps
- snapshot ID/version/sequence/key ID
- retry count and non-sensitive error category
- deployment/environment version

## Privacy denylist

Billing infrastructure must reject, discard, or prevent collection of:

- recovery logs or log history
- urges or urge intensity
- triggers
- slip/victory/reflection content
- Personal Why content or image
- Current Focus
- Christian or Secular recovery-mode choice
- recovery plans
- guided routines
- Christian journeys
- trusted contacts
- reminder content or reminder schedules
- support messages
- exported recovery reports
- email address unless a future separately approved billing requirement proves it necessary
- free-form recovery text
- raw purchase tokens in logs, evidence, or any durable storage authorized by this pass
- Google order IDs unless a later operational requirement explicitly allowlists them
- service-account credentials, authorization headers, private keys, or signing secrets

Schema-level `additionalProperties: false` is part of the privacy boundary, not just a convenience.

## Normalized lifecycle contract

BreakWave normalizes Google/operational inputs into these states:

- `not_entitled`
- `pending`
- `active`
- `grace`
- `canceled_active`
- `pause_scheduled_active`
- `paused`
- `on_hold`
- `expired`
- `revoked`
- `pending_canceled`
- `unverifiable`

State is distinct from acknowledgement status and test-purchase status.

Authoritative mapping rules preserve Audit D:

- `SUBSCRIPTION_STATE_PENDING` → `pending`; Plus not granted.
- `SUBSCRIPTION_STATE_ACTIVE` → `active` unless a verified scheduled pause boundary is represented as `pause_scheduled_active`; Plus granted while within verified paid time.
- `SUBSCRIPTION_STATE_IN_GRACE_PERIOD` → `grace`; Plus granted with the shorter offline boundary.
- `SUBSCRIPTION_STATE_CANCELED` with future expiry → `canceled_active`; Plus granted only through verified expiry.
- `SUBSCRIPTION_STATE_PAUSED` → `paused`; Plus suspended.
- `SUBSCRIPTION_STATE_ON_HOLD` → `on_hold`; Plus suspended.
- `SUBSCRIPTION_STATE_EXPIRED` → `expired`; Plus revoked.
- `SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED` → `pending_canceled`; do not grant the canceled purchase; query `linkedPurchaseToken` when present before deciding old access.
- `SUBSCRIPTION_STATE_UNSPECIFIED`, malformed, unsupported, or temporarily unverifiable responses → `unverifiable`; never create first-time Plus.
- a verified void/revocation signal → `revoked`; older positive snapshots are invalidated.

A renewal or recovery event is not a separate entitlement state; it results in a freshly verified normalized state.

## Linked purchase-token precedence

1. A pending replacement never removes a still-valid old entitlement.
2. Pending new benefits are not granted.
3. Once a new linked token is verified eligible, it becomes current authority for the chain.
4. The old token reference is retired from current-authority status but linkage remains auditable.
5. A canceled pending replacement requires re-query of the linked old token.
6. Raw linked tokens are never logged; persistent linkage uses `tokenRef` values.
7. A token chain may have only one current-authority record.

## RTDN contract

RTDN is a signal, never entitlement proof.

For every accepted subscription notification:

1. authenticate Pub/Sub delivery;
2. validate envelope and package name;
3. hash and deduplicate Pub/Sub `messageId`;
4. extract the purchase token in private memory;
5. call `purchases.subscriptionsv2.get`;
6. apply linked-token precedence;
7. map the authoritative response to normalized state;
8. issue a new snapshot only after authoritative processing;
9. acknowledge the Pub/Sub message according to the worker contract.

Duplicate messages are idempotent. An older RTDN arriving after a newer event cannot overwrite newer verified state merely because of arrival order. Event name and receipt time never outrank the current Developer API resource.

Unknown or malformed notifications produce no entitlement change.

## Signed entitlement snapshot

Production snapshots use an asymmetric Cloud KMS signing key separate from staging.

Locked algorithm: `EC_SIGN_P256_SHA256`.

Signing format:

- payload serialized as RFC 8785 JSON Canonicalization Scheme (JCS) UTF-8 bytes;
- SHA-256 digest signed by Cloud KMS using `EC_SIGN_P256_SHA256`;
- KMS DER-encoded ECDSA signature represented in the API as unpadded base64url;
- public verification key may ship in the app; private signing material never does;
- signature metadata includes algorithm and non-secret key version ID.

The signed payload binds:

- snapshot schema version
- snapshot payload schema version
- snapshot ID
- environment
- package name
- entitlement tier
- normalized state
- entitled boolean
- subscription-chain reference
- monotonic entitlement sequence
- verified server time
- authorization valid-through time
- verified subscription expiry when present
- pause-effective boundary when present
- test-purchase marker

Offline limits from Audit D remain mandatory:

- first Plus grant requires online verification;
- Active and canceled-but-unexpired positive snapshots authorize offline Plus for no more than 72 hours after verification;
- Grace positive snapshots authorize offline Plus for no more than 24 hours;
- verified expiry, pause-effective time, server `validThrough`, or a newer explicit negative state may end access earlier;
- Paused, On Hold, Expired, Revoked, Pending, Pending Canceled, Not Entitled, and Unverifiable do not receive positive offline authorization;
- device-clock rollback cannot extend access.

The client stores the highest accepted entitlement sequence and latest trusted server time for the current chain. A lower-sequence snapshot cannot restore Plus after a newer accepted state.

## Error categories

The backend exposes only coarse non-sensitive categories:

- `none`
- `malformed_request`
- `unsupported_protocol`
- `unauthorized_client`
- `integrity_unavailable`
- `integrity_rejected`
- `package_mismatch`
- `product_mismatch`
- `purchase_token_invalid`
- `purchase_token_expired`
- `purchase_token_reused`
- `play_not_found`
- `play_unavailable`
- `rate_limited`
- `state_unverifiable`
- `internal_retryable`

Errors never include a raw token, order ID, credential, another user's state, recovery data, or Google profile details.

## Retention and deletion contract

- Application billing logs: 30 days initially, per RC1J.
- Request ID / nonce replay records: 15-minute TTL in v1. A retry after a rejected/replayed request must use a new request ID and nonce.
- RTDN message-ID dedup records: 30 days unless staging evidence proves a shorter safe window.
- Synthetic fixtures: repository-retained; contain no real user, account, token, or order data.
- `tokenRef` and normalized entitlement records: retain only for the operational/refund/dispute period approved by 24/3CJ LLC before production storage; exact production retention remains an owner gate from RC1J.
- Raw purchase token: no durable plaintext retention authorized by RC1K.
- Deletion/retirement must preserve only the minimum legally/operationally required billing record and never require deletion of local recovery history.

## Threat model

| ID | Threat | Boundary | Required mitigation |
|---|---|---|---|
| THR-01 | Forged client claims Plus | app → public API | Signed snapshots only; backend verification; no local flag authority |
| THR-02 | Stolen purchase token replay | app → API | TLS, integrity input, nonce/request dedup, tokenRef dedup, no token logging |
| THR-03 | Pending purchase grants Plus | worker | Authoritative V2 mapping; pending never entitled |
| THR-04 | Snapshot tampering | backend → app | KMS P-256 signature over canonical payload |
| THR-05 | Old positive snapshot replay | app cache | Monotonic entitlement sequence + trusted server time + newer-negative precedence |
| THR-06 | Device-clock rollback | app cache | Server-authorized boundaries; clock rollback cannot extend validThrough |
| THR-07 | Fake/spoofed RTDN | Pub/Sub → worker | Authenticated Pub/Sub delivery; schema/package validation; V2 refresh |
| THR-08 | Duplicate RTDN | worker | message-ID hash dedup + idempotent state writes |
| THR-09 | Out-of-order RTDN | worker | Event order never authoritative; re-query V2; versioned state writes |
| THR-10 | Linked-token double entitlement | worker/store | One current tokenRef per chain; verified precedence and retirement |
| THR-11 | Token/credential leakage | logs/evidence | strict redaction/denylist; secret scanning; raw-token log scans |
| THR-12 | Recovery-data leakage into billing | app/API/store | strict allowlist, additionalProperties=false, S0/S1 denylist tests |
| THR-13 | Staging/production crossover | environments | separate projects/keys/secrets; environment-scoped tokenRef |
| THR-14 | Overprivileged public API | public API → private worker | private worker isolation; least privilege; public API lacks order-management permissions |
| THR-15 | Billing outage blocks recovery | app/runtime | async refresh; Free-first startup; Rescue never depends on billing |
| THR-16 | Rate/DoS pressure degrades app | public API | backend rate limits and bounded requests; app never blocks on billing |
| THR-17 | Unknown protocol/state grants access | protocol | fail closed for Plus, fail open for protected Free app |
| THR-18 | Evidence reveals sensitive billing/user data | QA/release | synthetic fixtures, redacted evidence, verifier scans |

## STRIDE summary

- Spoofing: forged app/client, spoofed Pub/Sub, stolen token.
- Tampering: modified request, modified snapshot, altered lifecycle state.
- Repudiation: ambiguous retry/acknowledgement history; mitigated with non-sensitive audit metadata and sequence IDs.
- Information disclosure: raw token, credentials, Google profile data, recovery data.
- Denial of service: Play/backend outage or endpoint abuse must not become app/Rescue outage.
- Elevation of privilege: local flags, stale snapshots, public-service IAM, or linked-token mistakes must not create Plus.

## Deterministic fixtures

The repository fixtures are synthetic only. They cover Audit D lifecycle and edge scenarios including Pending, Active, Grace, canceled-but-unexpired, scheduled pause, Paused, On Hold, Expired, Revoked, Pending Purchase Canceled, Unverifiable, acknowledgement pending, test purchase, renewal, recovery, linked replacement pending/completed/canceled, offline Active/Grace boundaries, and clock rollback.

Fixtures never contain a token that can be sent to Google Play.

## Audit E traceability

Every one of the 98 Audit E cases maps to at least one RC1K contract area. Traceability does not mark those future tests as executed; it only proves the contract has a defined test owner.

All P0 and P1 tests remain mandatory before paid release.

## Stop conditions

Stop future billing implementation immediately if:

- Rescue is delayed, covered, gated, or made billing-dependent;
- Pending grants Plus;
- client-local state becomes production authority;
- RTDN is treated as entitlement proof;
- a raw purchase token enters logs/evidence;
- a credential/private key enters the app repository;
- recovery data enters billing infrastructure;
- a stale/older snapshot can restore Plus after a newer negative state;
- staging and production token references, keys, or data are mixed;
- prices/trials/billing periods are hardcoded;
- implementation requires durable raw token material without a written storage architecture revision;
- current official Google behavior has not been rechecked before code.

Stopping billing work must leave existing Free BreakWave and Rescue usable.

## Exit decision

BW-88RC1K is a contract-only WP-02 milestone. Its completion does not authorize billing code or cloud provisioning.

After RC1K is green, the next ordered work package is **WP-03 — Verification Backend**, but WP-03 entry remains subject to all RC1I/J gates and any explicit token-storage architecture decision required by durable acknowledgement retry.
