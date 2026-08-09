import 'package:breakwave/features/home/presentation/widgets/home_recovery_model_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Home recovery model card stays compact and explains the existing system',
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
      expect(
        find.textContaining('Home helps you notice and prepare.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('choose one next right action'),
        findsOneWidget,
      );
      expect(
        find.textContaining('remember what worked'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
