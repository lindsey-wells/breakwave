#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
import zipfile
from pathlib import Path

import breakwave_verify as bw


failed = False


def check(condition: bool, message: str) -> None:
    global failed
    if not condition:
        print("FAIL BW-VERIFY-01A: " + message)
        failed = True


def expect_error(fn, message: str) -> None:
    global failed
    try:
        fn()
    except bw.VerificationError:
        return
    except Exception as exc:
        print(
            "FAIL BW-VERIFY-01A: "
            + message
            + " raised unexpected "
            + type(exc).__name__
            + ": "
            + str(exc)
        )
        failed = True
        return

    print(
        "FAIL BW-VERIFY-01A: "
        + message
        + " did not fail"
    )
    failed = True


def command(*args: str, cwd: Path) -> str:
    result = subprocess.run(
        list(args),
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    return result.stdout.strip()


with tempfile.TemporaryDirectory(
    prefix="bw-verify-01a-"
) as td:
    temp = Path(td)

    # 1. Basename-only checksum generation and strict parsing.
    artifact = temp / "sample.zip"
    artifact.write_bytes(b"sample-package")
    checksum = bw.write_checksum_file(artifact)
    checksum_text = checksum.read_text(
        encoding="utf-8"
    ).strip()

    check(
        checksum_text.endswith("  sample.zip"),
        "checksum writer did not use basename only",
    )
    check(
        "/mnt/" not in checksum_text,
        "checksum writer leaked a path",
    )
    check(
        bw.verify_outer_checksum(
            artifact,
            checksum,
        )
        == hashlib.sha256(
            artifact.read_bytes()
        ).hexdigest(),
        "outer checksum verification failed",
    )

    bad_checksum = temp / "bad.sha256"
    bad_checksum.write_text(
        hashlib.sha256(
            artifact.read_bytes()
        ).hexdigest()
        + "  /mnt/data/sample.zip\n",
        encoding="utf-8",
    )
    expect_error(
        lambda: bw.verify_outer_checksum(
            artifact,
            bad_checksum,
        ),
        "absolute-path checksum",
    )

    # 2. ZIP manifest integrity and traversal protection.
    pkg = temp / "pkg"
    pkg.mkdir()
    payload = pkg / "hello.txt"
    payload.write_bytes(b"hello\n")
    manifest = {
        "files": {
            "hello.txt": hashlib.sha256(
                payload.read_bytes()
            ).hexdigest(),
        }
    }
    (pkg / "manifest.json").write_text(
        json.dumps(
            manifest,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    good_zip = temp / "good.zip"
    with zipfile.ZipFile(
        good_zip,
        "w",
        zipfile.ZIP_DEFLATED,
    ) as archive:
        archive.write(
            pkg / "manifest.json",
            "pkg/manifest.json",
        )
        archive.write(
            payload,
            "pkg/hello.txt",
        )

    good_sha = bw.write_checksum_file(good_zip)
    result = bw.verify_package_zip(
        good_zip,
        checksum_path=good_sha,
    )
    check(
        result["verified_files"]["hello.txt"]
        == hashlib.sha256(b"hello\n").hexdigest(),
        "ZIP manifest hash verification failed",
    )

    traversal_zip = temp / "traversal.zip"
    with zipfile.ZipFile(
        traversal_zip,
        "w",
    ) as archive:
        archive.writestr("../escape.txt", "bad")
        archive.writestr(
            "pkg/manifest.json",
            json.dumps({"files": {}}),
        )
    expect_error(
        lambda: bw.verify_package_zip(
            traversal_zip
        ),
        "ZIP traversal member",
    )

    # 3. Raw Git blob hashing preserves final newline.
    repo = temp / "repo"
    repo.mkdir()
    command("git", "init", cwd=repo)
    command(
        "git",
        "config",
        "user.name",
        "BreakWaveVerify Test",
        cwd=repo,
    )
    command(
        "git",
        "config",
        "user.email",
        "verify@example.invalid",
        cwd=repo,
    )

    newline_file = repo / "newline.txt"
    newline_file.write_bytes(b"line-one\n")
    command("git", "add", "newline.txt", cwd=repo)
    command("git", "commit", "-m", "base", cwd=repo)
    base = command(
        "git",
        "rev-parse",
        "HEAD",
        cwd=repo,
    )

    raw_hash = bw.git_blob_sha256(
        repo,
        base,
        "newline.txt",
    )
    check(
        raw_hash
        == hashlib.sha256(b"line-one\n").hexdigest(),
        "raw Git blob hash changed file bytes",
    )
    check(
        raw_hash
        != hashlib.sha256(b"line-one").hexdigest(),
        "raw Git blob hash stripped final newline",
    )

    # 4. Exact parent/tree/changed-file contract.
    (repo / "feature.txt").write_text(
        "feature\n",
        encoding="utf-8",
    )
    command("git", "add", "feature.txt", cwd=repo)
    command(
        "git",
        "commit",
        "-m",
        "target",
        cwd=repo,
    )
    target = command(
        "git",
        "rev-parse",
        "HEAD",
        cwd=repo,
    )
    target_tree = command(
        "git",
        "rev-parse",
        "HEAD^{tree}",
        cwd=repo,
    )

    contract = {
        "base": base,
        "target": target,
        "target_tree": target_tree,
        "changed_files": ["feature.txt"],
    }
    contract_result = bw.verify_git_contract(
        repo,
        contract,
    )
    check(
        contract_result["changed_files"]
        == ["feature.txt"],
        "exact Git contract returned wrong files",
    )

    bad_contract = dict(contract)
    bad_contract["changed_files"] = ["wrong.txt"]
    expect_error(
        lambda: bw.verify_git_contract(
            repo,
            bad_contract,
        ),
        "wrong changed-file contract",
    )

    # 5. Proof isolation.
    proof_file = (
        repo
        / ".github"
        / "workflows"
        / "proof.yml"
    )
    proof_file.parent.mkdir(
        parents=True,
        exist_ok=True,
    )
    proof_file.write_text(
        "name: proof\n",
        encoding="utf-8",
    )
    command(
        "git",
        "add",
        ".github/workflows/proof.yml",
        cwd=repo,
    )
    command(
        "git",
        "commit",
        "-m",
        "proof",
        cwd=repo,
    )
    proof = command(
        "git",
        "rev-parse",
        "HEAD",
        cwd=repo,
    )

    bw.verify_proof_isolation(
        repo,
        target=target,
        proof_head=proof,
        allowed_files=[
            ".github/workflows/proof.yml",
        ],
    )
    expect_error(
        lambda: bw.verify_proof_isolation(
            repo,
            target=target,
            proof_head=proof,
            allowed_files=["different.yml"],
        ),
        "proof isolation wrong allowlist",
    )

    # 6. Missing remote ref must be None.
    bare = temp / "remote.git"
    command(
        "git",
        "init",
        "--bare",
        str(bare),
        cwd=temp,
    )
    command(
        "git",
        "remote",
        "add",
        "testremote",
        str(bare),
        cwd=repo,
    )
    command(
        "git",
        "push",
        "testremote",
        f"{target}:refs/heads/main",
        cwd=repo,
    )

    check(
        bw.remote_ref(
            repo,
            "testremote",
            "refs/tags/missing",
        )
        is None,
        "missing remote tag was not None",
    )

    command(
        "git",
        "tag",
        "green",
        target,
        cwd=repo,
    )
    command(
        "git",
        "push",
        "testremote",
        "refs/tags/green",
        cwd=repo,
    )
    check(
        bw.remote_ref(
            repo,
            "testremote",
            "refs/tags/green",
        )
        == target,
        "existing remote tag did not resolve",
    )

    # 7. Promotion state.
    check(
        bw.classify_promotion_state(
            base=base,
            target=target,
            local_head=base,
            origin_main=base,
            local_tag=None,
            primary_tag=None,
            backup_main=base,
            backup_tag=None,
        )
        == "ready",
        "ready promotion state misclassified",
    )

    check(
        bw.classify_promotion_state(
            base=base,
            target=target,
            local_head=target,
            origin_main=target,
            local_tag=target,
            primary_tag=target,
            backup_main=target,
            backup_tag=target,
        )
        == "complete",
        "complete promotion state misclassified",
    )

    expect_error(
        lambda: bw.classify_promotion_state(
            base=base,
            target=target,
            local_head=target,
            origin_main=target,
            local_tag=base,
            primary_tag=None,
            backup_main=base,
            backup_tag=None,
        ),
        "wrong-commit tag state",
    )

source = Path(
    __file__
).with_name(
    "breakwave_verify.py"
).read_text(
    encoding="utf-8"
)

for needle in [
    "git_blob_sha256",
    "write_checksum_file",
    "parse_checksum_file",
    "verify_package_zip",
    "remote_ref",
    "verify_git_contract",
    "verify_proof_isolation",
    "classify_promotion_state",
    "verify_github_run",
    "verify_remote_release_refs",
    "detached_worktree_preflight",
]:
    check(
        needle in source,
        "core API missing: " + needle,
    )

for forbidden in [
    "git reset --hard",
    "git clean -fd",
    "git push --force",
    "git push -f",
]:
    check(
        forbidden not in source,
        "forbidden operation: " + forbidden,
    )

if failed:
    raise SystemExit(1)

print(
    "PASS: BW-VERIFY-01A "
    "BreakWaveVerify foundation verified."
)
