#!/usr/bin/env python3
"""Permanent regression gate for phase-aware Shadow verifier execution."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
RUNNER = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"

if not RUNNER.is_file():
    print("FAIL BW-CI-01D missing Shadow runner")
    raise SystemExit(1)

source = RUNNER.read_text(encoding="utf-8")

required = (
    "PHASE_VERIFIER_REFS",
    '"tools/verify_bw87b6p2.py": "bw87b6p2-green"',
    '"tools/verify_bw88rc1e.py": "bw-88rc1k-green"',
    '"tools/verify_bw88rc1k.py": "bw-88rc1k-green"',
    '"tools/verify_bw_wp03r.py": "02136802599b5a286cf42d98217da7b4f696e50b"',
    "def run_phase_aware_verifiers",
    "def phase_routing_selftest",
    '"verifier_phase_refs": PHASE_VERIFIER_REFS',
    'if sys.argv[1:] == ["--phase-selftest"]',
)
for marker in required:
    if marker not in source:
        print(f"FAIL BW-CI-01D runner marker missing: {marker}")
        raise SystemExit(1)

for forbidden in (
    '[[sys.executable, rel] for rel in changed_verifiers]',
    'run_many("03_historical_verifiers"',
):
    if forbidden in source:
        print(f"FAIL BW-CI-01D stale current-tree verifier path remains: {forbidden}")
        raise SystemExit(1)

result = subprocess.run(
    [sys.executable, str(RUNNER), "--phase-selftest"],
    cwd=ROOT,
    text=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
)
print(result.stdout, end="")
if result.returncode != 0:
    print("FAIL BW-CI-01D phase-routing execution selftest failed")
    raise SystemExit(result.returncode)

if "PASS: Shadow phase-aware billing verifier routing selftest." not in result.stdout:
    print("FAIL BW-CI-01D expected phase-routing PASS marker missing")
    raise SystemExit(1)

print(
    "PASS: BW-CI-01D Shadow verifier phase routing preserves "
    "pre-billing contracts at their locked historical states."
)
