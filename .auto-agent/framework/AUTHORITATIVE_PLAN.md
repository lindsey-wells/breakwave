# Authoritative Plan Rule

A project has exactly one active authoritative plan for a controlled operation.

The plan binds project identity, baseline, branch, stage order, payload allowlists, verifier commands, commit messages, validation branch, safety branch, approval policy, and no-tag/no-force-push rules.

A Shadow manifest is generated from the authoritative plan after stage commits exist. It is derived evidence input, not a second independent plan.

Production promotion must reject a manifest or lock whose plan hash differs from the authoritative plan hash.
