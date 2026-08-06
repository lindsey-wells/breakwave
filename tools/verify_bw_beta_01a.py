#!/usr/bin/env python3
from pathlib import Path
import csv
import sys

ROOT = Path(__file__).resolve().parent.parent
OPERATIONS = ROOT / "docs/beta/BW_BETA_01A_OPERATIONS_FOUNDATION.md"
TEMPLATE = ROOT / "docs/beta/BW_BETA_TESTER_REPORT_TEMPLATE.md"
REGISTER = ROOT / "docs/beta/BW_BETA_ISSUE_REGISTER.csv"

missing = [
    str(path.relative_to(ROOT))
    for path in [OPERATIONS, TEMPLATE, REGISTER]
    if not path.is_file()
]
if missing:
    print("FAIL BW-BETA-01A missing: " + ", ".join(missing))
    sys.exit(1)

operations = OPERATIONS.read_text(encoding="utf-8")
template = TEMPLATE.read_text(encoding="utf-8")

operations_needles = [
    "BW-BETA-01A — Closed-Testing Operations Foundation",
    "The beta register must never contain:",
    "P0 — Release stop / immediate safety concern",
    "P1 — High impact / core workflow failure",
    "P2 — Normal defect or polish",
    "Do not mark an issue Closed merely because code was committed.",
    "main remains unchanged until explicit promotion",
]
template_needles = [
    "BreakWave Closed-Tester Report Template",
    "Tester alias:",
    "Exact steps to reproduce:",
    "Did this block or change Rescue?",
    "Did this expose or alter recovery data?",
    "Did you scrub names, contacts, recovery text, and notification content",
]

failed = False
for needle in operations_needles:
    if needle not in operations:
        print(f"FAIL BW-BETA-01A operations contract missing: {needle}")
        failed = True

for needle in template_needles:
    if needle not in template:
        print(f"FAIL BW-BETA-01A tester template missing: {needle}")
        failed = True

with REGISTER.open("r", encoding="utf-8", newline="") as handle:
    rows = list(csv.reader(handle))

expected_header = [
    "issue_id","date_reported","tester_alias","device_model","android_version",
    "app_version","version_code","build_source","screen_or_flow","report_type",
    "summary","expected_behavior","actual_behavior","reproduction_steps",
    "severity","status","reproducibility","safe_workaround","evidence_reference",
    "triage_owner","assigned_owner","fix_commit","shadow_run","main_run",
    "retest_tester","retest_date","retest_build","retest_result","resolution",
    "linked_issue","notes",
]

if rows != [expected_header]:
    print("FAIL BW-BETA-01A register must contain the locked header and no fake rows.")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-BETA-01A closed-testing operations foundation verified.")
