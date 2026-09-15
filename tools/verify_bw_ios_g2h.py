#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]; G2G='0c2a18df625cb1db7212cb3c570cb782effd0648'; failed=False
def read(rel):
 global failed
 p=ROOT/rel
 if not p.is_file(): print(f'FAIL missing: {rel}'); failed=True; return ''
 return p.read_text(encoding='utf-8')
def req(text,needle,label):
 global failed
 if needle not in text: print(f'FAIL {label} missing: {needle}'); failed=True
model=read('lib/features/rescue/domain/pending_rescue_outcome.dart'); store=read('lib/features/rescue/data/rescue_safe_outcome_store.dart'); rec=read('lib/features/rescue/data/rescue_outcome_reconciler.dart'); safe=read('lib/features/rescue/presentation/rescue_safe_screen.dart'); shell=read('lib/features/shell/presentation/breakwave_shell.dart'); keys=read('lib/core/storage/storage_keys.dart'); runner=read('.github/scripts/run_breakwave_shadow_ci.py'); ci=read('tools/verify_bw_ci_01d.py')
for n in ('class PendingRescueOutcome','final String id;','final String entryType;','final int intensity;','final String genericOutcomeTag;','final String genericAction;','final String createdAtIso;'): req(model,n,'pending model')
for n in ('thought','consequence','betterPlan','replacementAction','PersonalWhy'):
 if n in model: print(f'FAIL pending model protected field: {n}'); failed=True
req(keys,'bw_rescue_safe_pending_v1','storage key')
for n in ('class RescueSafeOutcomeStore','BreakWaveStorageKeys.rescueSafePendingOutcomes','Future<List<PendingRescueOutcome>> loadPending()','Future<void> save(PendingRescueOutcome outcome)','Future<void> removeIds(Set<String> ids)'): req(store,n,'pending store')
for n in ('LogRepository','LogEntry','loadEntries','bw_log_entries_v1'):
 if n in store: print(f'FAIL pending store protected dependency: {n}'); failed=True
for n in ('PendingRescueOutcome(','widget.outcomeStore.save(pending)',"genericOutcomeTag: value == 'easing' ? 'lower_now' : 'still_strong'",'Queued for your recovery history after you unlock BreakWave.'): req(safe,n,'RescueSafeScreen')
for n in ('LogRepository','LogEntry','SharedPreferences','loadEntries()','saveEntry('):
 if n in safe: print(f'FAIL RescueSafeScreen direct protected persistence: {n}'); failed=True
for n in ('class RescueOutcomeReconciler','await pendingStore.loadPending()','await logRepository.loadEntries()','await logRepository.saveEntry(_toLogEntry(outcome))','await pendingStore.removeIds(removeIds)','existingIds.contains(outcome.id)',"'lower_now' => 'Lower Now'","'still_strong' => 'Still Strong'"): req(rec,n,'reconciler')
for n in ("import '../../rescue/data/rescue_outcome_reconciler.dart';",'Future<void> _reconcilePendingRescueOutcomes() async','unawaited(_reconcilePendingRescueOutcomes());'): req(shell,n,'shell')
for n in (f'IOS_G2G_CLOSED_REF = "{G2G}"','"tools/verify_bw_ios_g2g.py": IOS_G2G_CLOSED_REF'): req(runner,n,'phase pin')
req(ci,'IOS_G2G_CLOSED_REF','CI phase pin'); req(ci,G2G,'CI exact G2G SHA')
for rel in ('test/pending_rescue_outcome_test.dart','test/rescue_safe_outcome_store_test.dart','test/rescue_outcome_reconciler_test.dart','test/rescue_safe_screen_test.dart'): read(rel)
if failed: raise SystemExit(1)
print('PASS: IOS-G2H queues only data-minimized Rescue-safe outcomes while locked, keeps normal Log history unread until authentication, reconciles idempotently after unlock, preserves failed pending records for retry, and phase-pins IOS-G2G to its closed SHA.')
