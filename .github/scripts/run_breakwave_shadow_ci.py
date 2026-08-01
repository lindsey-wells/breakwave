#!/usr/bin/env python3
# BreakWave reusable and stage-aware Shadow CI runner.

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "shadow_evidence"


def run(name: str, command: list[str]) -> dict:
    print(f"\n=== {name} ===", flush=True)
    result = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
    )
    print(result.stdout, flush=True)
    (OUT / f"{name}.log").write_text(result.stdout, encoding="utf-8")
    return {
        "name": name,
        "command": command,
        "exit_code": result.returncode,
        "passed": result.returncode == 0,
    }


def skipped(name: str, message: str) -> dict:
    text = message + "\n"
    print(f"\n=== {name} ===\n{text}", flush=True)
    (OUT / f"{name}.log").write_text(text, encoding="utf-8")
    return {
        "name": name,
        "command": [],
        "exit_code": 0,
        "passed": True,
        "skipped": True,
        "message": message,
    }


def run_many(name: str, commands: list[list[str]]) -> dict:
    if not commands:
        return skipped(name, "No stage-specific files changed; full verification still runs.")

    blocks: list[str] = []
    failures = 0
    for command in commands:
        result = subprocess.run(
            command,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
        )
        blocks.append(
            f"=== {' '.join(command)} | exit={result.returncode} ===\n{result.stdout}"
        )
        if result.returncode != 0:
            failures += 1

    output = "\n".join(blocks)
    print(f"\n=== {name} ===\n{output}", flush=True)
    (OUT / f"{name}.log").write_text(output, encoding="utf-8")
    return {
        "name": name,
        "command": commands,
        "exit_code": 1 if failures else 0,
        "passed": failures == 0,
        "failure_count": failures,
    }


def git(*args: str, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if check and result.returncode != 0:
        raise RuntimeError(
            f"git {' '.join(args)} failed ({result.returncode}):\n{result.stdout}"
        )
    return result.stdout.strip()


def ensure_origin_main() -> None:
    if git("rev-parse", "--verify", "origin/main", check=False):
        return
    subprocess.run(
        ["git", "fetch", "origin", "main:refs/remotes/origin/main", "--no-tags"],
        cwd=ROOT,
        check=True,
    )


def resolve_baseline() -> str:
    ensure_origin_main()
    head = git("rev-parse", "HEAD")
    origin_main = git("rev-parse", "origin/main")
    if head == origin_main:
        parent = git("rev-parse", "HEAD^", check=False)
        return parent or head
    return git("merge-base", "HEAD", "origin/main")


def resolve_stage_id() -> str:
    supplied = os.environ.get("BW_SHADOW_STAGE_ID", "").strip()
    if supplied:
        return supplied

    subject = git("log", "-1", "--pretty=%s")
    match = re.search(r"\b(BW-[A-Z0-9]+(?:-[A-Z0-9]+)+)\b", subject)
    if match:
        return match.group(1)

    branch = git("branch", "--show-current")
    match = re.search(r"validation/(bw-[a-z0-9]+-[0-9]+[a-z0-9]*)", branch)
    if match:
        return match.group(1).upper()

    return "BW-SHADOW"


def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    steps: list[dict] = []

    baseline = resolve_baseline()
    stage_id = resolve_stage_id()
    changed_files = git("diff", "--name-only", f"{baseline}..HEAD").splitlines()
    changed_verifiers = sorted(
        rel for rel in changed_files
        if rel.startswith("tools/verify_bw") and rel.endswith(".py")
    )
    changed_tests = sorted(
        rel for rel in changed_files
        if rel.startswith("test/") and rel.endswith("_test.dart")
    )

    identity = {
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "stage_id": stage_id,
        "branch": git("branch", "--show-current"),
        "commit": git("rev-parse", "HEAD"),
        "commit_subject": git("log", "-1", "--pretty=%s"),
        "tree": git("rev-parse", "HEAD^{tree}"),
        "baseline": baseline,
        "origin_main": git("rev-parse", "origin/main"),
        "changed_files": changed_files,
        "changed_verifiers": changed_verifiers,
        "changed_tests": changed_tests,
        "github": {
            "event_name": os.environ.get("GITHUB_EVENT_NAME", ""),
            "ref_name": os.environ.get("GITHUB_REF_NAME", ""),
            "run_id": os.environ.get("GITHUB_RUN_ID", ""),
            "workflow": os.environ.get("GITHUB_WORKFLOW", ""),
        },
    }
    (OUT / "identity.json").write_text(
        json.dumps(identity, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    (OUT / "stage.diff").write_text(
        git("diff", "--binary", f"{baseline}..HEAD") + "\n",
        encoding="utf-8",
    )

    steps.append(run("01_flutter_pub_get", ["flutter", "pub", "get"]))
    steps.append(run_many(
        "02_changed_verifiers",
        [[sys.executable, rel] for rel in changed_verifiers],
    ))

    verifier_commands = [
        [sys.executable, str(path.relative_to(ROOT))]
        for path in sorted((ROOT / "tools").glob("verify_bw*.py"))
    ]
    steps.append(run_many("03_historical_verifiers", verifier_commands))
    steps.append(run("04_flutter_analyze", ["flutter", "analyze", "--no-fatal-infos"]))
    steps.append(run_many(
        "05_changed_flutter_tests",
        [["flutter", "test", rel] for rel in changed_tests],
    ))
    steps.append(run("06_full_flutter_tests", ["flutter", "test"]))
    steps.append(run("07_build_release_apk", ["flutter", "build", "apk", "--release"]))

    apk = ROOT / "build/app/outputs/flutter-apk/app-release.apk"
    if apk.is_file():
        steps.append(run(
            "08_verify_apk_branding",
            [sys.executable, "tools/verify_bw88rc1a.py", "--artifact", str(apk)],
        ))
        steps.append(run(
            "09_verify_apk_contract",
            [sys.executable, "tools/verify_bw88rc1b.py", "--artifact", str(apk)],
        ))
    else:
        steps.append({
            "name": "08_09_verify_apk",
            "command": [],
            "exit_code": 1,
            "passed": False,
            "message": "APK was not produced.",
        })

    steps.append(run(
        "10_build_release_aab",
        ["flutter", "build", "appbundle", "--release"],
    ))

    aab = ROOT / "build/app/outputs/bundle/release/app-release.aab"
    if aab.is_file():
        steps.append(run(
            "11_verify_aab_branding",
            [sys.executable, "tools/verify_bw88rc1a.py", "--artifact", str(aab)],
        ))
        steps.append(run(
            "12_verify_aab_contract",
            [sys.executable, "tools/verify_bw88rc1b.py", "--artifact", str(aab)],
        ))
    else:
        steps.append({
            "name": "11_12_verify_aab",
            "command": [],
            "exit_code": 1,
            "passed": False,
            "message": "AAB was not produced.",
        })

    changed_hashes = {}
    for rel in changed_files:
        path = ROOT / rel
        if path.is_file():
            changed_hashes[rel] = file_sha256(path)

    summary = {
        "schema_version": 2,
        "stage_id": stage_id,
        "identity": identity,
        "steps": steps,
        "changed_file_sha256": changed_hashes,
        "passed": all(step.get("passed", False) for step in steps),
    }
    (OUT / "summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    if not summary["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
