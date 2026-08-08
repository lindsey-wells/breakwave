#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENGINE = ROOT / "tools/breakwave_verify.py"
SHADOW_RUNNER = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"
SHADOW_WORKFLOW = ROOT / ".github/workflows/breakwave-shadow-ci.yml"
MAIN_WORKFLOW = ROOT / ".github/workflows/ci.yml"
DOC = ROOT / "docs/verification/BREAKWAVE_VERIFY_ADOPTION.md"
CI_VERIFY = ROOT / "tools/verify_bw_ci_01a.py"

required = [
    ENGINE,
    SHADOW_RUNNER,
    SHADOW_WORKFLOW,
    MAIN_WORKFLOW,
    DOC,
    CI_VERIFY,
]
missing = [str(p.relative_to(ROOT)) for p in required if not p.is_file()]
if missing:
    print("FAIL BW-VERIFY-01B missing: " + ", ".join(missing))
    raise SystemExit(1)

engine = ENGINE.read_text(encoding="utf-8")
runner = SHADOW_RUNNER.read_text(encoding="utf-8")
shadow = SHADOW_WORKFLOW.read_text(encoding="utf-8")
main = MAIN_WORKFLOW.read_text(encoding="utf-8")
doc = DOC.read_text(encoding="utf-8")
ci_verify = CI_VERIFY.read_text(encoding="utf-8")

failed = False


def require(text, needle, label):
    global failed
    if needle not in text:
        print("FAIL BW-VERIFY-01B " + label + " missing: " + needle)
        failed = True


for needle in [
    "def verify_shadow_state(",
    "baseline_is_ancestor",
    "git_blob_sha256",
    'subs.add_parser("shadow-state")',
]:
    require(engine, needle, "engine")

for needle in [
    "import breakwave_verify as bw_verify",
    "bw_verify.verify_shadow_state(",
    'OUT / "breakwave_verify.json"',
    'changed_hashes = verify_state["git_blob_sha256"]',
    '"schema_version": 3',
    '"breakwave_verify": verify_state',
    'os.environ.get("GITHUB_REF_NAME"',
]:
    require(runner, needle, "Shadow runner")

for forbidden in [
    "def file_sha256(",
    "hashlib.sha256(path.read_bytes())",
]:
    if forbidden in runner:
        print(
            "FAIL BW-VERIFY-01B Shadow runner still duplicates hashing: "
            + forbidden
        )
        failed = True

preflight = "python3 tools/breakwave_verify.py selftest"
require(shadow, "BreakWaveVerify engine preflight", "Shadow workflow")
require(shadow, preflight, "Shadow workflow")
require(main, "BreakWaveVerify engine preflight", "main workflow")
require(main, preflight, "main workflow")

for needle in [
    "multi-commit safe",
    "Restraint rule",
    "classify_promotion_state",
    "verify_proof_isolation",
    "verify_remote_release_refs",
]:
    require(doc, needle, "adoption doc")

require(ci_verify, "import re", "BW-CI-01A verifier")
require(ci_verify, "schema_versions =", "BW-CI-01A verifier")
require(
    ci_verify,
    "runner schema version must be 2 or later",
    "BW-CI-01A verifier",
)
if '\'"schema_version": 2\',' in ci_verify:
    print("FAIL BW-VERIFY-01B historical verifier still pins schema 2")
    failed = True

if failed:
    raise SystemExit(1)

print("PASS: BW-VERIFY-01B adoption and enforcement verified.")
