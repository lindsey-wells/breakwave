#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
workflow_path = ROOT / ".github/workflows/breakwave-shadow-ci.yml"
runner_path = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"
legacy_path = ROOT / "tools/verify_bw_mod_01a.py"

for path in [workflow_path, runner_path, legacy_path]:
    if not path.is_file():
        print(f"FAIL BW-CI-01A missing file: {path.relative_to(ROOT)}")
        sys.exit(1)

workflow = workflow_path.read_text(encoding="utf-8")
runner = runner_path.read_text(encoding="utf-8")
legacy = legacy_path.read_text(encoding="utf-8")

for token in [
    "run-name:",
    "validation/bw-*",
    "workflow_dispatch:",
    "run_label:",
    "Derive Shadow metadata",
    "id: shadow_metadata",
    "BW_SHADOW_STAGE_ID",
    "steps.shadow_metadata.outputs.artifact_prefix",
]:
    if token not in workflow:
        print(f"FAIL BW-CI-01A workflow missing: {token}")
        sys.exit(1)

for forbidden in ["validation/bw-mod-*", "bw-mod-01a-shadow-evidence", "bw-mod-01a-shadow-apk", "bw-mod-01a-shadow-aab"]:
    if forbidden in workflow:
        print(f"FAIL BW-CI-01A stale workflow marker remains: {forbidden}")
        sys.exit(1)

for token in [
    "resolve_baseline",
    "resolve_stage_id",
    "origin/main",
    "changed_verifiers",
    "changed_tests",
    '"stage_id": stage_id',
    '"schema_version": 2',
]:
    if token not in runner:
        print(f"FAIL BW-CI-01A runner missing: {token}")
        sys.exit(1)

for forbidden in ['BASELINE =', 'TARGET_TESTS =', '"stage_id": "BW-MOD-01A"']:
    if forbidden in runner:
        print(f"FAIL BW-CI-01A stale runner marker remains: {forbidden}")
        sys.exit(1)

if "validation/bw-*" not in legacy or "validation/bw-mod-*" in legacy:
    print("FAIL BW-CI-01A legacy BW-MOD verifier was not generalized")
    sys.exit(1)

print("PASS: BW-CI-01A generalized Shadow triggers, labels, artifacts, and evidence.")
