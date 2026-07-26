#!/usr/bin/env python3
from __future__ import annotations
import json, shutil, subprocess
from pathlib import Path
from urllib.parse import urlparse

class Unavailable(RuntimeError): pass
class Rejected(RuntimeError): pass

def run(args, cwd=None):
    return subprocess.run(args, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def slug(url):
    value=url.strip().rstrip('/')
    if value.startswith('git@github.com:'): path=value.split(':',1)[1]
    else:
        parsed=urlparse(value)
        if (parsed.hostname or '').lower()!='github.com': return value.lower()
        path=parsed.path.lstrip('/')
    return path[:-4].lower() if path.endswith('.git') else path.lower()

def verify(repo: Path, identity: dict, expected_head: str | None, require_clean=True):
    branch=run(['git','branch','--show-current'],repo).stdout.strip()
    head=run(['git','rev-parse','HEAD'],repo).stdout.strip()
    origin=run(['git','remote','get-url','origin'],repo).stdout.strip()
    dirty=run(['git','status','--porcelain'],repo).stdout.strip()
    if branch != identity['branch']: raise Rejected(f'wrong branch: {branch}')
    if slug(origin) != identity['repository'].lower(): raise Rejected(f'wrong origin: {origin}')
    if expected_head and head != expected_head: raise Rejected(f'wrong HEAD: {head}')
    if require_clean and dirty: raise Rejected('working tree is not clean')
    if shutil.which('gh'):
        result=run(['gh','api','user','--jq','.login'],repo)
        if result.returncode: raise Unavailable(result.stdout or 'GitHub account unavailable')
        if result.stdout.strip()!=identity['github_account']:
            raise Rejected(f'wrong GitHub account: {result.stdout.strip()}')
    fetched=run(['git','fetch','--prune','origin',identity['branch']],repo)
    if fetched.returncode: raise Unavailable(fetched.stdout or 'origin unavailable')
    remote=run(['git','rev-parse',f"origin/{identity['branch']}"],repo).stdout.strip()
    if remote != head: raise Rejected(f'HEAD/origin mismatch: {head} != {remote}')
    return {'branch':branch,'head':head,'origin':origin,'origin_head':remote,'clean':not bool(dirty)}
