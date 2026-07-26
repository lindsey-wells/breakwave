#!/usr/bin/env python3
# BreakWave BW-MOD-01A characterization verifier.

from __future__ import annotations

import ast
import hashlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASELINE = "d432cdc2489967335b66bf526a642b91179b0d4a"
ALLOWED = {
    ".github/scripts/run_breakwave_shadow_ci.py",
    ".github/workflows/breakwave-shadow-ci.yml",
    "test/helpers/personal_recovery_plan_test_harness.dart",
    "test/personal_recovery_plan_screen_characterization_test.dart",
    "test/personal_recovery_plan_screen_import_characterization_test.dart",
    "tools/verify_bw_mod_01a.py",
}
LOCKED = {
    "lib/features/personal_plan/presentation/personal_recovery_plan_screen.dart":
        "2331d3e35a4fb19fba135b72b7a9a32a21584dd0b978e04899f4af3e9cd2f330",
    "lib/features/personal_plan/data/personal_recovery_plan_store.dart":
        "ad7bc81f6fbfa7bad62ad331f1f9f5bfba56c59668da088140fb56490958bcd5",
    "lib/features/personal_plan/domain/personal_recovery_plan.dart":
        "18df7d8df06864ae1660a3c308d1093ab90a92bee4e7aae1283b9dcf5664d52d",
    "lib/features/personal_plan/domain/personal_recovery_plan_prefill.dart":
        "3719bbfc683b92c881df95150c6c000250bf6f166503f79bfa2779ad723c7152",
    "test/personal_recovery_plan_refresh_test.dart":
        "97bc997b5aa9e341720e27ba10487a84172e9ba17f125460c997e9a57ba52eff",
}


def fail(message: str) -> None:
    print(f"FAIL BW-MOD-01A: {message}")
    raise SystemExit(1)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.returncode != 0:
        fail(f"git command failed: {' '.join(args)}\n{result.stdout}")
    return result.stdout.strip()


for rel, expected in LOCKED.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing locked file: {rel}")
    if digest(path) != expected:
        fail(f"locked source changed: {rel}")

for rel in ALLOWED:
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing stage file: {rel}")
    lines = len(path.read_text(encoding="utf-8").splitlines())
    if lines > 400:
        fail(f"stage file exceeds 400 lines: {rel} ({lines})")

screen = (ROOT / "lib/features/personal_plan/presentation/"
          "personal_recovery_plan_screen.dart").read_text(encoding="utf-8")
for token in (
    "CircularProgressIndicator",
    "Plan unavailable",
    "Try again",
    "Unsaved changes",
    "Discard unsaved changes?",
    "Refresh from current BreakWave choices",
    "Personal recovery plan saved on this device.",
    "RecoveryMode.christian",
):
    if token not in screen:
        fail(f"screen characterization token missing: {token}")

combined_tests = "\n".join(
    (ROOT / rel).read_text(encoding="utf-8")
    for rel in ALLOWED
    if rel.startswith("test/") and rel.endswith("_test.dart")
)
for token in (
    "empty secular plan settles into the local editor",
    "malformed log storage shows unavailable state",
    "saved plan loads into fields",
    "empty save is rejected",
    "editing marks the draft dirty",
    "back navigation warns",
    "refresh imports current choices",
    "suggestion chips populate",
    "Christian mode exposes faith support",
    "Rescue completion",
):
    if token not in combined_tests:
        fail(f"characterization coverage marker missing: {token}")

workflow = (
    ROOT / ".github/workflows/breakwave-shadow-ci.yml"
).read_text(encoding="utf-8")
for token in (
    "name: BreakWave Shadow CI",
    "validation/bw-mod-*",
    "run_breakwave_shadow_ci.py",
    "if: always()",
    "bw-mod-01a-shadow-evidence",
):
    if token not in workflow:
        fail(f"Shadow workflow marker missing: {token}")

runner_path = (
    ROOT / ".github/scripts/run_breakwave_shadow_ci.py"
)
runner = runner_path.read_text(encoding="utf-8")


def literal_string_lists(source: str) -> set[tuple[str, ...]]:
    tree = ast.parse(source)
    commands: set[tuple[str, ...]] = set()
    for node in ast.walk(tree):
        if not isinstance(node, ast.List):
            continue
        values: list[str] = []
        for item in node.elts:
            if not isinstance(item, ast.Constant) or not isinstance(
                item.value,
                str,
            ):
                values = []
                break
            values.append(item.value)
        if values:
            commands.add(tuple(values))
    return commands


commands = literal_string_lists(runner)
for command in (
    ("flutter", "pub", "get"),
    ("flutter", "analyze", "--no-fatal-infos"),
    ("flutter", "test"),
    ("flutter", "build", "apk", "--release"),
    ("flutter", "build", "appbundle", "--release"),
):
    if command not in commands:
        fail(
            "Shadow runner command missing: "
            + " ".join(command)
        )

for token in (
    "verify_bw88rc1a.py",
    "verify_bw88rc1b.py",
):
    if token not in runner:
        fail(f"Shadow runner artifact verifier missing: {token}")

head = git("rev-parse", "HEAD")
if head == BASELINE:
    changed = set(
        filter(
            None,
            git("ls-files", "--others", "--exclude-standard").splitlines(),
        )
    )
else:
    changed = set(
        filter(
            None,
            git("diff", "--name-only", f"{BASELINE}..HEAD").splitlines(),
        )
    )

if changed != ALLOWED:
    fail(
        "changed-file allowlist mismatch: "
        f"expected={sorted(ALLOWED)} actual={sorted(changed)}"
    )

print("PASS: BW-MOD-01A characterization and Shadow CI contract verified.")
