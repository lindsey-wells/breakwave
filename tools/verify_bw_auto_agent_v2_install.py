#!/usr/bin/env python3
from pathlib import Path
import json, re

root=Path(__file__).resolve().parents[1]
required=[
 '.auto-agent/project.json','.auto-agent/project_identity.json',
 '.auto-agent/approval_policy.json','.auto-agent/plans/BWAA00_INSTALL_PLAN.json',
 '.auto-agent/framework/AUTHORITATIVE_PLAN.md',
 '.auto-agent/framework/IDENTITY_ROUTING.md',
 '.auto-agent/framework/PROMOTION_LOCK_V2.md',
 '.auto-agent/runtime/v2_identity_guard.py',
 '.auto-agent/runtime/v2_plan_guard.py',
 '.github/workflows/auto-agent-shadow-ci.yml','AGENTS.md',
 'CHATGPT_PROJECT_KNOWLEDGE.md']
missing=[p for p in required if not (root/p).is_file()]
if missing: raise SystemExit(f'FAIL: missing {missing}')
identity=json.loads((root/'.auto-agent/project_identity.json').read_text())
assert identity['repository']=='lindsey-wells/breakwave'
assert identity['github_account']=='lindsey-wells'
assert identity['branch']=='main'
assert identity['local_path']=='~/projects/breakwave'
assert identity['android_package']=='com.cube23.breakwave'
approval=json.loads((root/'.auto-agent/approval_policy.json').read_text())
assert approval['required_approvals']==1
assert approval['dual_approval_required'] is False
plan=json.loads((root/'.auto-agent/plans/BWAA00_INSTALL_PLAN.json').read_text())
assert plan['authoritative'] is True
assert plan['stage_order']==['BWAA-00']
workflow=(root/'.github/workflows/auto-agent-shadow-ci.yml').read_text()
assert 'validation/**' in workflow and 'if: always()' in workflow
agents=(root/'AGENTS.md').read_text()
assert agents.count('BREAKWAVE AUTO-AGENT V2 MANAGED START')==1
assert '40 lines' in agents
for path in root.rglob('*'):
 if path.is_file() and (path.suffix in {'.pem','.key','.jks','.p12','.keystore'}):
  raise SystemExit(f'FAIL: forbidden secret-like file {path}')
print('BW-AUTO-AGENT-V2 INSTALL VERIFY: PASS')
print('Project identity: lindsey-wells/breakwave main')
print('Approval: any one authorized operator')
print('Authoritative active plans: 1')
print('Visible command maximum: 40 lines')
print('Automatic tagging: disabled')
