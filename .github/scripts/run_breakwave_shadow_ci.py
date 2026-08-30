#!/usr/bin/env python3
# BreakWave reusable and stage-aware Shadow CI runner.

from __future__ import annotations

import io
import json
import os
import re
import subprocess
import sys
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "shadow_evidence"
TOOLS = ROOT / "tools"

# Historical billing verifiers are phase contracts, not permanent assertions
# about every later repository state. Run them against the locked state where
# those contracts were closed instead of weakening or suppressing them.
PHASE_VERIFIER_REFS = {
    "tools/verify_bw69.py": "bw69-green",
    "tools/verify_bw74.py": "bw74-green",
    "tools/verify_bw87b6p2.py": "bw87b6p2-green",
    "tools/verify_bw88rc1e.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1f.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1g.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1h.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1i.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1j.py": "bw-88rc1k-green",
    "tools/verify_bw88rc1k.py": "bw-88rc1k-green",
    "tools/verify_bw_wp03r.py": "02136802599b5a286cf42d98217da7b4f696e50b",
}


if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

import breakwave_verify as bw_verify


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


def phase_ref_for_verifier(rel: str) -> str:
    return PHASE_VERIFIER_REFS.get(rel, "HEAD")


def export_git_ref(ref: str, destination: Path) -> str:
    resolved = git("rev-parse", "--verify", f"{ref}^{{commit}}")
    archive = subprocess.run(
        ["git", "archive", "--format=tar", resolved],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if archive.returncode != 0:
        raise RuntimeError(
            f"git archive {ref} failed ({archive.returncode}):\n"
            + archive.stderr.decode("utf-8", errors="replace")
        )
    destination.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(archive.stdout), mode="r:") as tar:
        tar.extractall(destination)
    return resolved


def run_phase_aware_verifiers(name: str, verifier_paths: list[str]) -> dict:
    # main() normally creates OUT, but --phase-selftest intentionally bypasses
    # main(). Make the helper independently safe so every entry path can record
    # evidence without depending on main() side effects.
    OUT.mkdir(parents=True, exist_ok=True)

    if not verifier_paths:
        return skipped(
            name,
            "No stage-specific verifier files changed; full verification still runs.",
        )

    blocks: list[str] = []
    failures = 0

    with tempfile.TemporaryDirectory(prefix="breakwave-shadow-ref-") as td:
        temp_root = Path(td)
        exported: dict[str, tuple[Path, str]] = {}

        for rel in verifier_paths:
            ref = phase_ref_for_verifier(rel)
            if ref == "HEAD":
                cwd = ROOT
                resolved = git("rev-parse", "HEAD")
            else:
                if ref not in exported:
                    ref_root = temp_root / f"ref-{len(exported):02d}"
                    resolved_ref = export_git_ref(ref, ref_root)
                    exported[ref] = (ref_root, resolved_ref)
                cwd, resolved = exported[ref]

            verifier = cwd / rel
            if not verifier.is_file():
                blocks.append(
                    f"=== {sys.executable} {rel} | ref={ref}@{resolved} | exit=1 ===\n"
                    f"Verifier missing from selected historical state: {rel}\n"
                )
                failures += 1
                continue

            result = subprocess.run(
                [sys.executable, rel],
                cwd=cwd,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
            )
            blocks.append(
                f"=== {sys.executable} {rel} | ref={ref}@{resolved} "
                f"| exit={result.returncode} ===\n{result.stdout}"
            )
            if result.returncode != 0:
                failures += 1

    output = "\n".join(blocks)
    print(f"\n=== {name} ===\n{output}", flush=True)
    (OUT / f"{name}.log").write_text(output, encoding="utf-8")
    return {
        "name": name,
        "command": verifier_paths,
        "exit_code": 1 if failures else 0,
        "passed": failures == 0,
        "failure_count": failures,
        "phase_aware": True,
    }


def phase_routing_selftest() -> None:
    expected = {
        "tools/verify_bw69.py": "bw69-green",
        "tools/verify_bw74.py": "bw74-green",
        "tools/verify_bw87b6p2.py": "bw87b6p2-green",
        "tools/verify_bw88rc1e.py": "bw-88rc1k-green",
        "tools/verify_bw88rc1k.py": "bw-88rc1k-green",
        "tools/verify_bw_wp03r.py": "02136802599b5a286cf42d98217da7b4f696e50b",
        "tools/verify_bw_wp03s.py": "HEAD",
        "tools/verify_bw01.py": "HEAD",
    }
    for rel, ref in expected.items():
        actual = phase_ref_for_verifier(rel)
        if actual != ref:
            raise RuntimeError(
                f"phase mapping mismatch for {rel}: expected {ref}, got {actual}"
            )

    result = run_phase_aware_verifiers(
        "phase_routing_selftest",
        [
            "tools/verify_bw69.py",
            "tools/verify_bw74.py",
            "tools/verify_bw87b6p2.py",
            "tools/verify_bw88rc1k.py",
            "tools/verify_bw_wp03r.py",
            "tools/verify_bw_wp03s.py",
        ],
    )
    if not result["passed"]:
        raise RuntimeError("phase-aware verifier execution selftest failed")

    print("PASS: Shadow phase-aware billing verifier routing selftest.")


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



def resolve_flutter_toolchain() -> dict:
    expected = os.environ.get("BREAKWAVE_FLUTTER_VERSION", "").strip()
    result = subprocess.run(
        ["flutter", "--version", "--machine"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.returncode != 0:
        raise RuntimeError(
            "flutter --version --machine failed: " + result.stdout
        )
    try:
        machine = json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            "Could not decode Flutter machine-version output"
        ) from exc

    actual = str(machine.get("frameworkVersion", "")).strip()
    if not expected:
        raise RuntimeError(
            "BREAKWAVE_FLUTTER_VERSION is not configured"
        )
    if actual != expected:
        raise RuntimeError(
            f"Flutter toolchain drift: expected {expected}, got {actual}"
        )

    return {
        "expected_framework_version": expected,
        "actual_framework_version": actual,
        "channel": machine.get("channel"),
        "framework_revision": machine.get("frameworkRevision"),
        "engine_revision": machine.get("engineRevision"),
        "dart_sdk_version": machine.get("dartSdkVersion"),
    }

def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    steps: list[dict] = []

    baseline = resolve_baseline()
    stage_id = resolve_stage_id()
    toolchain = resolve_flutter_toolchain()
    changed_files = git("diff", "--name-only", f"{baseline}..HEAD").splitlines()
    changed_verifiers = sorted(
        rel for rel in changed_files
        if rel.startswith("tools/verify_bw") and rel.endswith(".py")
    )
    changed_tests = sorted(
        rel for rel in changed_files
        if rel.startswith("test/") and rel.endswith("_test.dart")
    )

    verify_state = bw_verify.verify_shadow_state(
        ROOT,
        baseline=baseline,
        target="HEAD",
        expected_changed_files=changed_files,
    )
    (OUT / "breakwave_verify.json").write_text(
        json.dumps(verify_state, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    identity = {
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "stage_id": stage_id,
        "branch": (
            os.environ.get("GITHUB_REF_NAME", "").strip()
            or git("branch", "--show-current")
        ),
        "commit": git("rev-parse", "HEAD"),
        "commit_subject": git("log", "-1", "--pretty=%s"),
        "tree": git("rev-parse", "HEAD^{tree}"),
        "baseline": baseline,
        "origin_main": git("rev-parse", "origin/main"),
        "toolchain": toolchain,
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
    steps.append(run_phase_aware_verifiers(
        "02_changed_verifiers",
        changed_verifiers,
    ))

    verifier_paths = [
        str(path.relative_to(ROOT))
        for path in sorted((ROOT / "tools").glob("verify_bw*.py"))
    ]
    steps.append(run_phase_aware_verifiers(
        "03_historical_verifiers",
        verifier_paths,
    ))
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

    changed_hashes = verify_state["git_blob_sha256"]

    summary = {
        "schema_version": 3,
        "stage_id": stage_id,
        "identity": identity,
        "breakwave_verify": verify_state,
        "steps": steps,
        "verifier_phase_refs": PHASE_VERIFIER_REFS,
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
    if sys.argv[1:] == ["--phase-selftest"]:
        phase_routing_selftest()
    else:
        main()
