#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
EXPECTED = "3.44.9"

shadow = ROOT / ".github/workflows/breakwave-shadow-ci.yml"
main_ci = ROOT / ".github/workflows/ci.yml"
runner = ROOT / ".github/scripts/run_breakwave_shadow_ci.py"

for path in (shadow, main_ci, runner):
    if not path.is_file():
        print(f"FAIL BW-CI-01B missing: {path.relative_to(ROOT)}")
        sys.exit(1)

workflow_texts = {
    "shadow": shadow.read_text(encoding="utf-8"),
    "main": main_ci.read_text(encoding="utf-8"),
}

for name, text in workflow_texts.items():
    env_match = re.findall(
        r"^\s*BREAKWAVE_FLUTTER_VERSION:\s*['\"]?([^'\"\s]+)",
        text,
        re.MULTILINE,
    )
    if env_match != [EXPECTED]:
        print(
            f"FAIL BW-CI-01B {name} Flutter env pin mismatch: {env_match}"
        )
        sys.exit(1)

    required = [
        "channel: stable",
        "flutter-version: ${{ env.BREAKWAVE_FLUTTER_VERSION }}",
        "Verify pinned Flutter version",
        'grep -F "Flutter ${BREAKWAVE_FLUTTER_VERSION}"',
    ]
    for token in required:
        if token not in text:
            print(f"FAIL BW-CI-01B {name} missing: {token}")
            sys.exit(1)

    if "flutter-version-file:" in text:
        print(f"FAIL BW-CI-01B {name} must not use flutter-version-file")
        sys.exit(1)

runner_text = runner.read_text(encoding="utf-8")
for token in [
    "resolve_flutter_toolchain",
    '["flutter", "--version", "--machine"]',
    '"BREAKWAVE_FLUTTER_VERSION"',
    '"expected_framework_version": expected',
    '"actual_framework_version": actual',
    '"toolchain": toolchain',
    '"schema_version": 3',
]:
    if token not in runner_text:
        print(f"FAIL BW-CI-01B Shadow evidence missing: {token}")
        sys.exit(1)

if "actual != expected" not in runner_text:
    print("FAIL BW-CI-01B Shadow runner does not fail on version drift")
    sys.exit(1)

print("PASS: BW-CI-01B Flutter toolchain is pinned and evidence-bound.")
print(f"Pinned Flutter version: {EXPECTED}")
print("Shadow/main workflow drift protection: active")
