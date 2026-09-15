import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:breakwave/core/storage/storage_keys.dart';
import 'package:breakwave/features/rescue/data/rescue_safe_outcome_store.dart';
import 'package:breakwave/features/rescue/domain/pending_rescue_outcome.dart';
void main(){ const store=RescueSafeOutcomeStore(); setUp(()=>SharedPreferences.setMockInitialValues(<String,Object>{BreakWaveStorageKeys.logEntries:<String>['protected-log-sentinel']}));
  test('locked queue writes only isolated Rescue-safe key',() async { const o=PendingRescueOutcome(id:'p1',entryType:'Urge',intensity:5,genericOutcomeTag:'still_strong',genericAction:'Drink a glass of water',createdAtIso:'2026-09-14T21:00:00.000'); await store.save(o); final prefs=await SharedPreferences.getInstance(); expect(prefs.getStringList(BreakWaveStorageKeys.logEntries),<String>['protected-log-sentinel']); expect(prefs.getStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes),hasLength(1)); expect((await store.loadPending()).single.id,'p1'); });
  test('same pending id replaces instead of duplicating',() async { await store.save(const PendingRescueOutcome(id:'p1',entryType:'Urge',intensity:3,genericOutcomeTag:'still_strong',genericAction:'',createdAtIso:'2026-09-14T21:00:00.000')); await store.save(const PendingRescueOutcome(id:'p1',entryType:'Victory',intensity:2,genericOutcomeTag:'lower_now',genericAction:'Move to a different room',createdAtIso:'2026-09-14T21:01:00.000')); final p=await store.loadPending(); expect(p,hasLength(1)); expect(p.single.entryType,'Victory'); });
}
