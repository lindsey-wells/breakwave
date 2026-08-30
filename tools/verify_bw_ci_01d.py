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
    "PRE_WP03W_REF",
    '"b7ef61ed24a9aae1e683c2d8e790e70802f754c4"',
    "PHASE_VERIFIER_REFS",
    '"tools/verify_bw25.py": PRE_WP03W_REF',
    '"tools/verify_bw31.py": PRE_WP03W_REF',
    '"tools/verify_bw36.py": PRE_WP03W_REF',
    '"tools/verify_bw54.py": PRE_WP03W_REF',
    '"tools/verify_bw87a1.py": PRE_WP03W_REF',
    '"tools/verify_bw87a1b.py": PRE_WP03W_REF',
    '"tools/verify_bw87b1.py": PRE_WP03W_REF',
    '"tools/verify_bw87b2b.py": PRE_WP03W_REF',
    '"tools/verify_bw87b3b.py": PRE_WP03W_REF',
    '"tools/verify_bw87b4b.py": PRE_WP03W_REF',
    '"tools/verify_bw87b5b2.py": PRE_WP03W_REF',
    '"tools/verify_bw87b6b1.py": PRE_WP03W_REF',
    '"tools/verify_bw87b6p3b2b.py": PRE_WP03W_REF',
    '"tools/verify_bw89a12a.py": PRE_WP03W_REF',
    '"tools/verify_bw89a12b.py": PRE_WP03W_REF',
    '"tools/verify_bw89a12c.py": PRE_WP03W_REF',
    '"tools/verify_bw89a12d.py": PRE_WP03W_REF',
    '"tools/verify_bw89a12f.py": PRE_WP03W_REF',
    '"tools/verify_bw69.py": "bw69-green"',
    '"tools/verify_bw74.py": "bw74-green"',
    '"tools/verify_bw87b6p2.py": "bw87b6p2-green"',
    '"tools/verify_bw88rc1e.py": "bw-88rc1k-green"',
    '"tools/verify_bw88rc1k.py": "bw-88rc1k-green"',
    '"tools/verify_bw_wp03r.py": "02136802599b5a286cf42d98217da7b4f696e50b"',
    '"tools/verify_bw_wp03w.py": "HEAD"',
    '"tools/verify_bw_ci_01d.py": "HEAD"',
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
