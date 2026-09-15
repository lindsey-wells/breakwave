import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:breakwave/core/storage/storage_keys.dart';
import 'package:breakwave/features/rescue/presentation/rescue_safe_screen.dart';

Future<void> _scrollToText(WidgetTester tester,String text) async { await tester.scrollUntilVisible(find.text(text),320,scrollable:find.byType(Scrollable).first); await tester.pump(); }

void main(){
  setUp(()=>SharedPreferences.setMockInitialValues(<String,Object>{}));
  testWidgets('Rescue-safe renders generic tools without protected recovery content',(WidgetTester tester) async {
    bool unlockRequested=false; bool backRequested=false;
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:RescueSafeScreen(onUnlock:(){unlockRequested=true;},onBackToLock:(){backRequested=true;}))));
    expect(find.text('Rescue-safe access'),findsOneWidget); expect(find.text('Urge Intensity'),findsOneWidget); expect(find.text('Calm Reset'),findsOneWidget);
    await _scrollToText(tester,'60-second pause'); expect(find.text('60-second pause'),findsOneWidget);
    await _scrollToText(tester,'Move to a different room'); expect(find.text('Move to a different room'),findsOneWidget);
    await _scrollToText(tester,'Still strong'); expect(find.text('Wave is easing'),findsOneWidget); expect(find.text('Still strong'),findsOneWidget);
    await tester.tap(find.text('Still strong')); await tester.pumpAndSettle();
    expect(find.textContaining('Stay with the generic tools'),findsOneWidget);
    expect(find.text('Queued for your recovery history after you unlock BreakWave.'),findsOneWidget);
    final SharedPreferences prefs=await SharedPreferences.getInstance(); expect(prefs.getStringList(BreakWaveStorageKeys.rescueSafePendingOutcomes),hasLength(1));
    await _scrollToText(tester,'Unlock BreakWave'); await tester.tap(find.text('Unlock BreakWave')); await tester.pump();
    expect(unlockRequested,isTrue); expect(backRequested,isFalse); expect(find.text('Personal Why'),findsNothing); expect(find.text('Log'),findsNothing); expect(find.text('BreakWave Plus'),findsNothing);
  });
  testWidgets('Rescue-safe back action returns to privacy lock',(WidgetTester tester) async { bool backRequested=false; await tester.pumpWidget(MaterialApp(home:Scaffold(body:RescueSafeScreen(onUnlock:(){},onBackToLock:(){backRequested=true;})))); await _scrollToText(tester,'Back to privacy lock'); await tester.tap(find.text('Back to privacy lock')); await tester.pump(); expect(backRequested,isTrue); });
}
