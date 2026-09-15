import 'package:flutter_test/flutter_test.dart';
import 'package:breakwave/features/rescue/domain/pending_rescue_outcome.dart';
void main(){
  test('PendingRescueOutcome round-trips only approved fields',(){ const o=PendingRescueOutcome(id:'p1',entryType:'Victory',intensity:4,genericOutcomeTag:'lower_now',genericAction:'Move to a different room',createdAtIso:'2026-09-14T21:00:00.000'); final m=o.toMap(); expect(m.keys.toSet(),<String>{'id','entryType','intensity','genericOutcomeTag','genericAction','createdAtIso'}); expect(PendingRescueOutcome.fromMap(m).id,'p1'); });
  test('PendingRescueOutcome rejects unexpected personalized fields',(){ expect(()=>PendingRescueOutcome.fromMap(<String,dynamic>{'id':'p1','entryType':'Urge','intensity':3,'genericOutcomeTag':'still_strong','genericAction':'','createdAtIso':'2026-09-14T21:00:00.000','notes':'private'}),throwsFormatException); });
}
