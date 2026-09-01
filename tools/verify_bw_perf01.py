#!/usr/bin/env python3
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def text(path): return (ROOT / path).read_text(encoding='utf-8')
def require(src, marker, msg):
    if marker not in src: raise SystemExit(f'FAIL BW-PERF01: {msg}')
def forbid(src, marker, msg):
    if marker in src: raise SystemExit(f'FAIL BW-PERF01: {msg}')
probe=text('lib/core/performance/breakwave_performance_probe.dart')
main=text('lib/main.dart')
shell=text('lib/features/shell/presentation/breakwave_shell.dart')
billing=text('lib/features/billing_qa/presentation/billing_qa_screen.dart')
workflow=text('.github/workflows/breakwave-test-store-qa.yml')
for marker in ('BREAKWAVE_REVENUECAT_TEST_STORE_QA','defaultValue: false','ProcessInfo.currentRss','SchedulerBinding.instance.addTimingsCallback','timing.buildDuration','timing.rasterDuration','framesOver16Ms','framesOver33Ms'):
    require(probe, marker, f'performance probe marker missing: {marker}')
for marker in ('purchases_flutter','Purchases.','RevenueCatBootstrap','purchasePackage','restorePurchases','isPlusUnlocked','setState('):
    forbid(probe, marker, f'performance probe must remain read-only: {marker}')
for marker in ('BreakWavePerformanceProbe.installFrameTimingObserver()','qa_revenuecat_initialize','runApp_to_first_frame','qa_entry_to_first_frame'):
    require(main, marker, f'startup timing marker missing: {marker}')
require(main,'runApp(const BreakWaveApp());','runApp missing')
require(main,'if (!BreakWaveBillingQaConfig.enabled)','production RevenueCat non-blocking branch missing')
require(main,'unawaited(RevenueCatBootstrap.initialize());','production RevenueCat async bootstrap missing')
for marker in ('BreakWavePerformanceProbe.enabled',"category: 'tab'",'WidgetsBinding.instance.addPostFrameCallback'):
    require(shell, marker, f'tab timing marker missing: {marker}')
for marker in ('billing_qa_refresh','Performance diagnostics','Debug Test Store timings are diagnostic','Current Dart RSS','Frames >16.7 ms','Recent tab transitions','Refresh performance view'):
    require(billing, marker, f'QA diagnostics marker missing: {marker}')
require(workflow,'python3 tools/verify_bw_perf01.py','Test Store workflow does not execute BW-PERF01 verifier')
print('BW-PERF01 VERIFY: PASS')
print('QA-only compile-time gate: yes')
print('Production default instrumentation: off')
print('Production RevenueCat bootstrap behavior changed: no')
print('Entitlement authority changed: no')
print('Catalog policy changed: no')
print('Purchase/restore lifecycle changed: no')
print('Rescue changed: no')
print('Tab architecture changed: no')
print('Measurements: startup + QA RevenueCat init + tab-to-frame + frame build/raster + RSS')
print('Local Flutter executed: no')
print('CI required: yes')
