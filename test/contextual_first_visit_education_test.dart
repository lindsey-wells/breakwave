import 'package:breakwave/core/education/contextual_first_visit_education.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host({
  required BreakWaveEducationSurface surface,
  required String title,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ContextualFirstVisitEducationCard(
          key: ValueKey<String>('education-${surface.name}'),
          surface: surface,
          eyebrow: 'First visit',
          title: title,
          body: 'Short contextual guidance.',
        ),
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await BreakWaveContextualEducationStore.clear();
  });

  testWidgets(
    'dismissal persists per surface and does not dismiss another surface',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          surface: BreakWaveEducationSurface.rescue,
          title: 'Rescue education',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('contextual-first-visit-rescue'),
        ),
        findsOneWidget,
      );
      expect(find.text('Rescue education'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'contextual-first-visit-got-it-rescue',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rescue education'), findsNothing);
      expect(
        await BreakWaveContextualEducationStore.shouldShow(
          BreakWaveEducationSurface.rescue,
        ),
        isFalse,
      );
      expect(
        await BreakWaveContextualEducationStore.shouldShow(
          BreakWaveEducationSurface.log,
        ),
        isTrue,
      );

      await tester.pumpWidget(
        _host(
          surface: BreakWaveEducationSurface.rescue,
          title: 'Rescue education',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rescue education'), findsNothing);

      await tester.pumpWidget(
        _host(
          surface: BreakWaveEducationSurface.log,
          title: 'Log education',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log education'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'building a card never dismisses it automatically',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          surface: BreakWaveEducationSurface.support,
          title: 'Support education',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Support education'), findsOneWidget);
      expect(
        await BreakWaveContextualEducationStore.shouldShow(
          BreakWaveEducationSurface.support,
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
