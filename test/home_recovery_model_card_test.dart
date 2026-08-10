import 'package:breakwave/features/home/presentation/widgets/home_recovery_model_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Home recovery model card stays compact and maps the model to the app',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 360,
                    child: HomeRecoveryModelCard(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey<String>('home-recovery-model-card'),
        ),
        findsOneWidget,
      );
      expect(find.text('Your recovery'), findsOneWidget);
      expect(
        find.text('Recognize → Interrupt → Redirect → Reinforce'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Notice it → Break it → Choose differently → Strengthen what works',
        ),
        findsOneWidget,
      );

      expect(find.text('Notice It'), findsOneWidget);
      expect(
        find.text('Home helps you notice patterns and prepare.'),
        findsOneWidget,
      );
      expect(
        find.text('Break It → Choose Differently'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Rescue helps you interrupt the wave and choose one next right action.',
        ),
        findsOneWidget,
      );
      expect(find.text('Strengthen What Works'), findsOneWidget);
      expect(
        find.text(
          'Your Log helps you remember what helped and learn the pattern.',
        ),
        findsOneWidget,
      );

      expect(find.textContaining('remember what worked'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
