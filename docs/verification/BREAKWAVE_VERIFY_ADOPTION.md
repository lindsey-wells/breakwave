# BW-VERIFY-01B — Adoption & Enforcement

BW-VERIFY-01A installed the BreakWaveVerify trust engine.

BW-VERIFY-01B makes the repository's CI paths consume that engine directly.

## Enforced adoption

### Shadow CI
Shadow explicitly runs the BreakWaveVerify engine self-test before the full
Shadow runner.

The Shadow runner imports `tools/breakwave_verify.py` and writes
`shadow_evidence/breakwave_verify.json`.

That evidence locks:
- resolved baseline commit;
- exact target commit;
- exact target tree;
- complete changed-file set;
- baseline ancestry;
- raw Git blob SHA-256 for every changed file present at the target.

The Shadow summary schema is version 3 and embeds the same
`breakwave_verify` contract.

This is intentionally multi-commit safe. Repair commits may exist between
the baseline and final Shadow target without weakening the baseline/tree/file
contract.

### Main CI
Main CI explicitly self-tests BreakWaveVerify before running the historical
`verify_bw*.py` suite.

### Delivery packages
BreakWave implementation packages created after this stage should validate
their outer ZIP and `.sha256` pair with:

`python3 tools/breakwave_verify.py package PACKAGE.zip --checksum PACKAGE.zip.sha256`

The checksum file must use only the ZIP basename.

### Promotion/proof harnesses
Future harnesses should call the shared engine for:
- `classify_promotion_state`;
- `verify_proof_isolation`;
- `verify_github_run`;
- `verify_remote_release_refs`;
- detached-worktree preflight.

They should not reimplement those rules.

## Restraint rule

BreakWaveVerify is a consolidation layer, not permission to add arbitrary
new checks. A new verifier belongs in the repository only when it protects a
specific product, policy, release, or regression contract that existing
checks do not already cover.

The objective is fewer duplicated harness rules and fewer human-visible
failures.
