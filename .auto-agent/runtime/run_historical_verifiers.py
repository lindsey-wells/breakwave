#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys

root = Path.cwd()
files = sorted((root / "tools").glob("verify_*.py"))
for path in files:
    if path.name == "verify_bw_auto_agent_v2_install.py":
        continue
    print(f"Running {path}", flush=True)
    result = subprocess.run([sys.executable, str(path)], cwd=root)
    if result.returncode != 0:
        raise SystemExit(result.returncode)
print(f"PASS: {len(files) - 1} historical verifier files completed")
