#!/usr/bin/env python3
from __future__ import annotations
import hashlib, json
from pathlib import Path

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def load_one(plans_dir: Path, expected_plan_id: str | None=None):
    active=[]
    for path in sorted(plans_dir.glob('*.json')):
        value=json.loads(path.read_text(encoding='utf-8'))
        if value.get('authoritative') is True:
            active.append((path,value))
    if len(active)!=1:
        raise RuntimeError(f'exactly one authoritative plan required, found {len(active)}')
    path,value=active[0]
    if expected_plan_id and value.get('plan_id')!=expected_plan_id:
        raise RuntimeError('authoritative plan ID mismatch')
    return path,value,sha256(path)
