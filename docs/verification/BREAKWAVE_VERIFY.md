# BreakWaveVerify™

BreakWaveVerify is the reusable trust layer for BreakWave development,
Shadow CI, proof builds, promotion, tagging, mirroring, and downloaded
delivery packages.

## Incidents converted into permanent rules

BW-NOTIFY-01A/01B exposed harness failures that were not BreakWave app
failures:

1. hashing text after `.rstrip()` changed final-newline bytes;
2. missing Git tags were confused with wrong tags when stderr was treated as
   stdout;
3. checksum files leaked internal `/mnt/data/...` paths;
4. reusing an attachment filename could leave a stale client download;
5. proof-commit tree identity was confused with source-tree identity;
6. closeout needed safe resume-state detection;
7. proof-only commits needed hard exclusion from production promotion.

BreakWaveVerify turns those lessons into reusable machine checks.

## BW-VERIFY-01A core

### Package integrity
- SHA-256 is calculated from raw bytes.
- `.sha256` entries must contain basenames only.
- ZIP members cannot be absolute, duplicate, or traverse with `..`.
- `manifest.json` declares internal file SHA-256 hashes.

### Git integrity
- exact parent;
- exact tree;
- exact changed-file set;
- exact raw Git blob SHA-256 using `git cat-file blob`.

### Ref integrity
- missing refs return `None` based on command return code/output;
- error text can never masquerade as a ref value.

### Proof isolation
Proof heads must descend from the approved target and may change only an
explicit allowlist.

### Promotion state
Safe states are classified before mutation:
`ready`, `main_promoted`, `primary_tagged`, `complete`,
or `resume_required`.

Unapproved commits and wrong-commit tags fail closed.

### Detached preflight
Read-only commands can run against an exact target in a detached worktree.
A verifier that mutates that worktree fails.

### GitHub identity
Runs can be locked to run ID, SHA, branch, workflow, conclusion, artifact ID,
and artifact digest.

### Release refs
Primary main/tag and backup main/tag can be required to resolve to one exact
approved target.

## CLI

```text
python3 tools/breakwave_verify.py selftest

python3 tools/breakwave_verify.py package PACKAGE.zip   --checksum PACKAGE.zip.sha256

python3 tools/breakwave_verify.py contract stage_contract.json   --repo-root .
```

## Rollout

**BW-VERIFY-01A:** installs and validates the common engine.

**BW-VERIFY-01B:** adopts this engine inside Shadow evidence, implementation
packages, proof-build harnesses, promotion, tagging, and mirror finalization.

The goal is not more ceremony. The goal is to make harness mistakes fail
before Sparkles ever sees a command.
