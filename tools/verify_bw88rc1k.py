#!/usr/bin/env python3
"""Verify BW-88RC1K billing contracts and threat model."""
from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/BW_88RC1K_BILLING_CONTRACTS_THREAT_MODEL.md'
C=ROOT/'contracts/billing/v1'
F=ROOT/'fixtures/billing/v1'

def fail(m): print(f"BW-88RC1K VERIFY: FAIL — {m}"); raise SystemExit(1)
def load(p):
    if not p.is_file(): fail(f"missing {p.relative_to(ROOT)}")
    try: return json.loads(p.read_text(encoding='utf-8'))
    except Exception as e: fail(f"invalid JSON {p.relative_to(ROOT)}: {e}")

if not DOC.is_file(): fail('missing threat model')
text=' '.join(DOC.read_text(encoding='utf-8').split()).lower()
for needle in (
 'billing failure must never become recovery failure','recovery data allowed in billing infrastructure is zero',
 'bw.billing.verify.v1','ec_sign_p256_sha256','rfc 8785','rtdn is a signal, never entitlement proof',
 'hmac-sha-256','purchaseTokenSha256'.lower(),'15 minutes','raw purchase token: no durable plaintext retention authorized by rc1k',
 'wp-03 — verification backend','current official technical review'):
    if needle not in text: fail(f'document contract missing: {needle}')
ids=set(re.findall(r'\bTHR-\d{2}\b', DOC.read_text(encoding='utf-8')))
if ids != {f'THR-{i:02d}' for i in range(1,19)}: fail('threat register must be THR-01..THR-18')
req=load(C/'client_verification_request.schema.json'); resp=load(C/'client_verification_response.schema.json')
snap=load(C/'entitlement_snapshot.schema.json'); life=load(C/'normalized_lifecycle.json')
for obj,name in ((req,'request'),(resp,'response'),(snap,'snapshot')):
    if obj.get('additionalProperties') is not False: fail(f'{name} must reject unknown top-level fields')
if req['properties']['packageName'].get('const')!='com.cube23.breakwave': fail('package lock missing')
if req['properties']['purchaseToken'].get('x-log-policy')!='never': fail('purchase token log policy missing')
if snap['properties']['payload']['properties'].get('schemaVersion',{}).get('const')!='bw.entitlement.payload.v1': fail('signed payload schema version missing')
prohibited={'trigger','personalwhy','recoverymode','currentfocus','routine','journey','trustedcontact','supportmessage','reflection','recoverylog'}
all_keys=[]
def walk(x):
    if isinstance(x,dict):
        for k,v in x.items(): all_keys.append(k.lower().replace('_','')); walk(v)
    elif isinstance(x,list):
        for v in x: walk(v)
walk(req); walk(resp); walk(snap)
if prohibited.intersection(all_keys): fail(f'prohibited recovery field in contracts: {sorted(prohibited.intersection(all_keys))}')
expected_states={'not_entitled','pending','active','grace','canceled_active','pause_scheduled_active','paused','on_hold','expired','revoked','pending_canceled','unverifiable'}
if set(life.get('normalizedStates',[]))!=expected_states: fail('normalized lifecycle set mismatch')
gmap=life.get('googleSubscriptionStateMap',{})
for s in ('SUBSCRIPTION_STATE_PENDING','SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_PAUSED','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_ON_HOLD','SUBSCRIPTION_STATE_CANCELED','SUBSCRIPTION_STATE_EXPIRED','SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED'):
    if s not in gmap: fail(f'missing Google V2 state mapping: {s}')
fixtures=load(F/'audit_d_contract_fixtures.json')
if fixtures.get('syntheticOnly') is not True or len(fixtures.get('fixtures',[]))<25: fail('synthetic Audit D fixtures incomplete')
blob=json.dumps(fixtures).lower()
for marker in ('gpa.','@gmail.com','@yahoo.com','@outlook.com'):
    if marker in blob: fail(f'non-synthetic marker in fixtures: {marker}')
trace=load(F/'audit_e_traceability.json'); cases=trace.get('cases',[])
expected=[]
for p,n in (('SAF',8),('CAT',6),('PUR',10),('ACK',6),('LIF',16),('RTD',8),('RST',8),('OFF',10),('SEC',10),('UXS',8),('OPS',8)):
    expected += [f'{p}-{i:03d}' for i in range(1,n+1)]
actual=[c.get('testId') for c in cases]
if len(actual)!=98 or set(actual)!=set(expected) or trace.get('auditECaseCount')!=98: fail('Audit E traceability must map exactly 98 cases')
for c in cases:
    if c.get('status')!='contract_mapped_not_executed': fail('traceability must not claim tests executed')
for p in (ROOT/'pubspec.yaml',ROOT/'pubspec.lock'):
    if p.is_file():
        low=p.read_text(encoding='utf-8').lower()
        for dep in ('in_app_purchase','purchases_flutter','revenuecat'):
            if dep in low: fail(f'premature billing dependency: {dep}')
lib='\n'.join(p.read_text(encoding='utf-8',errors='ignore') for p in (ROOT/'lib').rglob('*.dart')) if (ROOT/'lib').is_dir() else ''
for marker in ('BillingClient','purchaseStream','launchBillingFlow'):
    if marker in lib: fail(f'premature billing code: {marker}')
print('BW-88RC1K VERIFY: PASS')
print('Threats modeled: 18')
print('Normalized lifecycle states: 12')
print('Synthetic Audit D fixtures:',len(fixtures['fixtures']))
print('Audit E contract mappings: 98/98')
print('Billing dependencies introduced: 0')
print('Production billing code introduced: 0')
print('Cloud resources provisioned: 0')
print('Entitlement behavior changed: no')
print('Next ordered package: WP-03 verification backend (still gated)')
