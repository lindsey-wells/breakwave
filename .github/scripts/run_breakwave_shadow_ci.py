#!/usr/bin/env python3
# BreakWave reusable Shadow CI runner.

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "shadow_evidence"
BASELINE = "d432cdc2489967335b66bf526a642b91179b0d4a"
TARGET_TESTS = [
    "test/personal_recovery_plan_screen_characterization_test.dart",
    "test/personal_recovery_plan_screen_import_characterization_test.dart",
]


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
    (OUT / f"{name}.log").write_text(
        result.stdout,
        encoding="utf-8",
    )
    return {
        "name": name,
        "command": command,
        "exit_code": result.returncode,
        "passed": result.returncode == 0,
    }


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    return result.stdout.strip()


def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    steps: list[dict] = []

    identity = {
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "branch": git("branch", "--show-current"),
        "commit": git("rev-parse", "HEAD"),
        "tree": git("rev-parse", "HEAD^{tree}"),
        "baseline": BASELINE,
        "changed_files": git(
            "diff", "--name-only", f"{BASELINE}..HEAD"
        ).splitlines(),
    }
    (OUT / "identity.json").write_text(
        json.dumps(identity, indent=2) + "\n",
        encoding="utf-8",
    )
    (OUT / "stage.diff").write_text(
        git("diff", "--binary", f"{BASELINE}..HEAD") + "\n",
        encoding="utf-8",
    )

    steps.append(run("01_flutter_pub_get", ["flutter", "pub", "get"]))
    steps.append(run(
        "02_targeted_verifier",
        [sys.executable, "tools/verify_bw_mod_01a.py"],
    ))

    verifier_failures = 0
    verifier_log = []
    for verifier in sorted((ROOT / "tools").glob("verify_bw*.py")):
        result = subprocess.run(
            [sys.executable, str(verifier)],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
        )
        verifier_log.append(
            f"=== {verifier.relative_to(ROOT)} | "
            f"exit={result.returncode} ===\n{result.stdout}"
        )
        if result.returncode != 0:
            verifier_failures += 1
    (OUT / "03_historical_verifiers.log").write_text(
        "\n".join(verifier_log),
        encoding="utf-8",
    )
    steps.append({
        "name": "03_historical_verifiers",
        "command": ["python3", "tools/verify_bw*.py"],
        "exit_code": 1 if verifier_failures else 0,
        "passed": verifier_failures == 0,
        "failure_count": verifier_failures,
    })

    steps.append(run(
        "04_flutter_analyze",
        ["flutter", "analyze", "--no-fatal-infos"],
    ))
    steps.append(run(
        "05_targeted_flutter_tests",
        ["flutter", "test", *TARGET_TESTS],
    ))
    steps.append(run(
        "06_full_flutter_tests",
        ["flutter", "test"],
    ))
    steps.append(run(
        "07_build_release_apk",
        ["flutter", "build", "apk", "--release"],
    ))

    apk = ROOT / "build/app/outputs/flutter-apk/app-release.apk"
    if apk.is_file():
        steps.append(run(
            "08_verify_apk_branding",
            [
                sys.executable,
                "tools/verify_bw88rc1a.py",
                "--artifact",
                str(apk),
            ],
        ))
        steps.append(run(
            "09_verify_apk_contract",
            [
                sys.executable,
                "tools/verify_bw88rc1b.py",
                "--artifact",
                str(apk),
            ],
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
            [
                sys.executable,
                "tools/verify_bw88rc1a.py",
                "--artifact",
                str(aab),
            ],
        ))
        steps.append(run(
            "12_verify_aab_contract",
            [
                sys.executable,
                "tools/verify_bw88rc1b.py",
                "--artifact",
                str(aab),
            ],
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
    for rel in identity["changed_files"]:
        path = ROOT / rel
        if path.is_file():
            changed_hashes[rel] = file_sha256(path)

    summary = {
        "schema_version": 1,
        "stage_id": "BW-MOD-01A",
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
