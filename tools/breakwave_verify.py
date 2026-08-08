#!/usr/bin/env python3
"""BreakWaveVerify: reusable verification primitives for BreakWave delivery."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path
from typing import Iterable, Mapping, Sequence


class VerificationError(RuntimeError):
    pass


_SHA256 = re.compile(r"^[0-9a-fA-F]{64}$")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def _run(command, *, cwd: Path, text: bool, check: bool = True):
    result = subprocess.run(
        list(command),
        cwd=cwd,
        text=text,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if check and result.returncode != 0:
        stdout = result.stdout if text else result.stdout.decode(errors="replace")
        stderr = result.stderr if text else result.stderr.decode(errors="replace")
        raise VerificationError(
            f"Command failed ({result.returncode}): {' '.join(command)}\n"
            f"{stdout}{stderr}"
        )
    return result


def git_text(repo: Path, *args: str, check: bool = True) -> str:
    return _run(
        ["git", *args],
        cwd=repo,
        text=True,
        check=check,
    ).stdout.strip()


def git_bytes(repo: Path, *args: str, check: bool = True) -> bytes:
    return _run(
        ["git", *args],
        cwd=repo,
        text=False,
        check=check,
    ).stdout


def git_blob_sha256(repo: Path, commit: str, relpath: str) -> str:
    """Hash exact Git blob bytes. Never decode or strip file content."""
    return sha256_bytes(
        git_bytes(repo, "cat-file", "blob", f"{commit}:{relpath}")
    )


def write_checksum_file(
    artifact: Path,
    checksum_path: Path | None = None,
) -> Path:
    artifact = artifact.resolve()
    target = checksum_path or artifact.with_name(artifact.name + ".sha256")
    target.write_text(
        f"{sha256_file(artifact)}  {artifact.name}\n",
        encoding="utf-8",
    )
    return target


def parse_checksum_file(
    checksum_path: Path,
    *,
    expected_basename: str,
) -> dict:
    lines = [
        line.strip()
        for line in checksum_path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(lines) != 1:
        raise VerificationError(
            "Checksum file must contain exactly one non-empty line."
        )

    match = re.fullmatch(r"([0-9a-fA-F]{64})[ \t]+\*?(.+)", lines[0])
    if not match:
        raise VerificationError("Checksum is not valid sha256sum format.")

    digest = match.group(1).lower()
    name = match.group(2).strip()

    if (
        "/" in name
        or "\\" in name
        or Path(name).is_absolute()
        or Path(name).name != name
    ):
        raise VerificationError(
            "Checksum must contain a basename only, never a directory path."
        )

    if name != expected_basename:
        raise VerificationError(
            f"Checksum basename {name!r} does not match "
            f"{expected_basename!r}."
        )

    return {"digest": digest, "basename": name}


def verify_outer_checksum(artifact: Path, checksum_path: Path) -> str:
    parsed = parse_checksum_file(
        checksum_path,
        expected_basename=artifact.name,
    )
    actual = sha256_file(artifact)
    if actual != parsed["digest"]:
        raise VerificationError(
            f"Artifact SHA-256 mismatch: expected {parsed['digest']}, "
            f"got {actual}."
        )
    return actual


def _safe_zip_name(name: str) -> None:
    if not name or "\x00" in name:
        raise VerificationError("ZIP contains an invalid member name.")
    normalized = name.replace("\\", "/")
    path = Path(normalized)
    if normalized.startswith("/") or path.is_absolute():
        raise VerificationError(f"ZIP contains absolute member: {name}")
    if any(part == ".." for part in path.parts):
        raise VerificationError(f"ZIP contains traversal member: {name}")


def _manifest_location(names: Sequence[str]) -> tuple[str, str]:
    candidates = []
    for name in names:
        normalized = name.replace("\\", "/")
        if normalized == "manifest.json":
            candidates.append((normalized, ""))
        elif (
            normalized.count("/") == 1
            and normalized.endswith("/manifest.json")
        ):
            candidates.append(
                (normalized, normalized[: -len("manifest.json")])
            )

    if len(candidates) != 1:
        raise VerificationError(
            "ZIP must contain exactly one root or single-top-level "
            "manifest.json."
        )
    return candidates[0]


def verify_package_zip(
    zip_path: Path,
    *,
    checksum_path: Path | None = None,
) -> dict:
    if checksum_path is not None:
        verify_outer_checksum(zip_path, checksum_path)

    with zipfile.ZipFile(zip_path) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise VerificationError("ZIP contains duplicate member names.")
        for name in names:
            _safe_zip_name(name)

        manifest_name, prefix = _manifest_location(names)
        manifest = json.loads(
            archive.read(manifest_name).decode("utf-8")
        )
        files = manifest.get("files")
        if not isinstance(files, dict):
            raise VerificationError(
                "manifest.json must contain a files object."
            )

        verified = {}
        for rel, wanted in sorted(files.items()):
            if not isinstance(rel, str) or not isinstance(wanted, str):
                raise VerificationError(
                    "Manifest hashes must use string paths and strings."
                )
            _safe_zip_name(rel)
            if not _SHA256.fullmatch(wanted):
                raise VerificationError(
                    f"Invalid SHA-256 in manifest for {rel}."
                )

            member = prefix + rel
            if member not in names:
                raise VerificationError(
                    f"Manifest-declared member missing: {member}"
                )

            actual = sha256_bytes(archive.read(member))
            if actual != wanted.lower():
                raise VerificationError(
                    f"Manifest SHA-256 mismatch for {rel}: "
                    f"expected {wanted}, got {actual}."
                )
            verified[rel] = actual

    return {
        "zip": zip_path.name,
        "sha256": sha256_file(zip_path),
        "manifest": manifest_name,
        "verified_files": verified,
    }


def remote_ref(repo: Path, remote: str, ref: str) -> str | None:
    """Missing ref returns None. Stderr is never mistaken for a ref value."""
    result = _run(
        ["git", "ls-remote", remote, ref],
        cwd=repo,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise VerificationError(
            f"Unable to inspect {remote} {ref}:\n{result.stderr}"
        )
    line = result.stdout.strip()
    if not line:
        return None
    parts = line.split()
    if len(parts) < 2:
        raise VerificationError(f"Malformed ls-remote output: {line!r}")
    return parts[0]


def local_ref(repo: Path, ref: str) -> str | None:
    result = _run(
        ["git", "show-ref", "--verify", "--quiet", ref],
        cwd=repo,
        text=True,
        check=False,
    )
    if result.returncode == 1:
        return None
    if result.returncode != 0:
        raise VerificationError(f"Unable to inspect local ref {ref}.")
    return git_text(repo, "rev-parse", ref)


def exact_changed_files(
    repo: Path,
    base: str,
    target: str,
) -> list[str]:
    output = git_text(
        repo,
        "diff",
        "--name-only",
        f"{base}..{target}",
    )
    return output.splitlines() if output else []


def verify_git_contract(repo: Path, contract: Mapping) -> dict:
    base = str(contract["base"])
    target = str(contract["target"])
    expected_tree = str(contract["target_tree"])
    expected_files = sorted(
        str(item) for item in contract["changed_files"]
    )

    parent = git_text(repo, "rev-parse", f"{target}^")
    if parent != base:
        raise VerificationError(
            f"Target parent mismatch: expected {base}, got {parent}."
        )

    tree = git_text(repo, "rev-parse", f"{target}^{{tree}}")
    if tree != expected_tree:
        raise VerificationError(
            f"Target tree mismatch: expected {expected_tree}, got {tree}."
        )

    changed = sorted(exact_changed_files(repo, base, target))
    if changed != expected_files:
        raise VerificationError(
            "Changed-file contract mismatch.\n"
            f"Expected: {expected_files}\nActual: {changed}"
        )

    blob_hashes = {}
    for rel in changed:
        exists = _run(
            ["git", "cat-file", "-e", f"{target}:{rel}"],
            cwd=repo,
            text=True,
            check=False,
        )
        if exists.returncode == 0:
            blob_hashes[rel] = git_blob_sha256(
                repo,
                target,
                rel,
            )

    validation_branch = contract.get("validation_branch")
    if validation_branch:
        primary_remote = str(
            contract.get("primary_remote", "origin")
        )
        actual = remote_ref(
            repo,
            primary_remote,
            f"refs/heads/{validation_branch}",
        )
        if actual != target:
            raise VerificationError(
                "Validation branch mismatch: "
                f"expected {target}, got {actual}."
            )

    return {
        "base": base,
        "target": target,
        "tree": tree,
        "changed_files": changed,
        "git_blob_sha256": blob_hashes,
    }


def verify_proof_isolation(
    repo: Path,
    *,
    target: str,
    proof_head: str,
    allowed_files: Iterable[str],
) -> dict:
    ancestor = _run(
        ["git", "merge-base", "--is-ancestor", target, proof_head],
        cwd=repo,
        text=True,
        check=False,
    )
    if ancestor.returncode != 0:
        raise VerificationError(
            "Proof head does not descend from approved target."
        )

    actual = sorted(
        exact_changed_files(repo, target, proof_head)
    )
    allowed = sorted(set(allowed_files))
    if actual != allowed:
        raise VerificationError(
            "Proof isolation failed.\n"
            f"Allowed: {allowed}\nActual: {actual}"
        )

    return {
        "target": target,
        "proof_head": proof_head,
        "allowed_files": allowed,
    }


def classify_promotion_state(
    *,
    base: str,
    target: str,
    local_head: str,
    origin_main: str,
    local_tag: str | None,
    primary_tag: str | None,
    backup_main: str | None,
    backup_tag: str | None,
) -> str:
    for label, value in {
        "local_head": local_head,
        "origin_main": origin_main,
    }.items():
        if value not in {base, target}:
            raise VerificationError(
                f"{label} is at unapproved commit {value}."
            )

    for label, value in {
        "local_tag": local_tag,
        "primary_tag": primary_tag,
        "backup_tag": backup_tag,
    }.items():
        if value not in {None, target}:
            raise VerificationError(
                f"{label} points to unapproved commit {value}."
            )

    if backup_main not in {None, base, target}:
        raise VerificationError(
            f"backup_main is at unapproved commit {backup_main}."
        )

    if (
        local_head == target
        and origin_main == target
        and local_tag == target
        and primary_tag == target
        and backup_main == target
        and backup_tag == target
    ):
        return "complete"

    if (
        local_head == target
        and origin_main == target
        and primary_tag == target
    ):
        return "primary_tagged"

    if local_head == target and origin_main == target:
        return "main_promoted"

    if local_head == base and origin_main == base:
        return "ready"

    return "resume_required"


def verify_github_run(
    *,
    repo_root: Path,
    repo_full_name: str,
    run_id: int,
    expected: Mapping,
    artifacts: Mapping[str, Mapping] | None = None,
) -> dict:
    fields = (
        "databaseId,status,conclusion,headSha,headBranch,"
        "workflowName,event,url,jobs"
    )
    result = _run(
        [
            "gh",
            "run",
            "view",
            str(run_id),
            "--repo",
            repo_full_name,
            "--json",
            fields,
        ],
        cwd=repo_root,
        text=True,
    )
    data = json.loads(result.stdout)

    for key, wanted in expected.items():
        if data.get(key) != wanted:
            raise VerificationError(
                f"Run {run_id} {key}={data.get(key)!r}, "
                f"expected {wanted!r}."
            )

    artifact_data = None
    if artifacts is not None:
        result = _run(
            [
                "gh",
                "api",
                f"repos/{repo_full_name}/actions/runs/"
                f"{run_id}/artifacts",
            ],
            cwd=repo_root,
            text=True,
        )
        artifact_data = json.loads(result.stdout)
        found = {
            item.get("name"): item
            for item in artifact_data.get("artifacts", [])
            if not item.get("expired")
        }

        for name, expected_artifact in artifacts.items():
            item = found.get(name)
            if item is None:
                raise VerificationError(
                    f"Required artifact missing: {name}"
                )
            if (
                "id" in expected_artifact
                and int(item.get("id"))
                != int(expected_artifact["id"])
            ):
                raise VerificationError(
                    f"Artifact ID mismatch: {name}"
                )
            if (
                "digest" in expected_artifact
                and item.get("digest")
                != expected_artifact["digest"]
            ):
                raise VerificationError(
                    f"Artifact digest mismatch: {name}"
                )

    return {"run": data, "artifacts": artifact_data}


def verify_remote_release_refs(
    repo: Path,
    *,
    target: str,
    tag: str,
    primary_remote: str,
    backup_remote: str,
) -> dict:
    refs = {
        "primary_main": remote_ref(
            repo,
            primary_remote,
            "refs/heads/main",
        ),
        "primary_tag": remote_ref(
            repo,
            primary_remote,
            f"refs/tags/{tag}",
        ),
        "backup_main": remote_ref(
            repo,
            backup_remote,
            "refs/heads/main",
        ),
        "backup_tag": remote_ref(
            repo,
            backup_remote,
            f"refs/tags/{tag}",
        ),
    }

    for label, value in refs.items():
        if value != target:
            raise VerificationError(
                f"{label} mismatch: expected {target}, got {value}."
            )
    return refs


def detached_worktree_preflight(
    repo: Path,
    *,
    target: str,
    commands: Sequence[Sequence[str]],
) -> list[dict]:
    """Run read-only commands against an exact target in a detached worktree."""
    parent = Path(tempfile.mkdtemp(prefix="breakwave-verify-"))
    worktree = parent / "target"
    added = False
    results = []

    try:
        _run(
            [
                "git",
                "worktree",
                "add",
                "--detach",
                str(worktree),
                target,
            ],
            cwd=repo,
            text=True,
        )
        added = True

        for command in commands:
            result = _run(
                list(command),
                cwd=worktree,
                text=True,
                check=False,
            )
            results.append(
                {
                    "command": list(command),
                    "exit_code": result.returncode,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                }
            )
            if result.returncode != 0:
                raise VerificationError(
                    "Detached-worktree preflight failed: "
                    + " ".join(command)
                    + "\n"
                    + result.stdout
                    + result.stderr
                )

        if git_text(
            worktree,
            "status",
            "--short",
            "-uall",
        ):
            raise VerificationError(
                "Detached verification modified the target worktree."
            )

        return results

    finally:
        if added:
            removal = _run(
                [
                    "git",
                    "worktree",
                    "remove",
                    str(worktree),
                ],
                cwd=repo,
                text=True,
                check=False,
            )
            if removal.returncode != 0:
                raise VerificationError(
                    "Unable to remove detached verification "
                    "worktree cleanly."
                )
        shutil.rmtree(parent, ignore_errors=True)


def _cli_package(args):
    result = verify_package_zip(
        Path(args.zip),
        checksum_path=(
            Path(args.checksum)
            if args.checksum
            else None
        ),
    )
    print(json.dumps(result, indent=2, sort_keys=True))


def _cli_contract(args):
    contract = json.loads(
        Path(args.contract).read_text(encoding="utf-8")
    )
    result = verify_git_contract(
        Path(args.repo_root),
        contract,
    )
    print(json.dumps(result, indent=2, sort_keys=True))


def _cli_selftest(_):
    sample = b"BreakWaveVerify\n"
    if sha256_bytes(sample) != hashlib.sha256(sample).hexdigest():
        raise VerificationError("SHA-256 smoke test failed.")
    print("PASS: BreakWaveVerify core self-test.")


def build_parser():
    parser = argparse.ArgumentParser(
        prog="breakwave_verify"
    )
    subs = parser.add_subparsers(
        dest="command",
        required=True,
    )

    package = subs.add_parser("package")
    package.add_argument("zip")
    package.add_argument("--checksum")
    package.set_defaults(func=_cli_package)

    contract = subs.add_parser("contract")
    contract.add_argument("contract")
    contract.add_argument("--repo-root", default=".")
    contract.set_defaults(func=_cli_contract)

    selftest = subs.add_parser("selftest")
    selftest.set_defaults(func=_cli_selftest)
    return parser


def main():
    args = build_parser().parse_args()
    try:
        args.func(args)
    except VerificationError as exc:
        print(f"FAIL: {exc}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
