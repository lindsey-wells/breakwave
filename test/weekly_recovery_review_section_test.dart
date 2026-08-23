import 'package:breakwave/features/insights/domain/recovery_insights_snapshot.dart';
import 'package:breakwave/features/insights/presentation/widgets/weekly_recovery_review_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('weekly review shows adjacent raw windows without judgment',
      (WidgetTester tester) async {
    const current = RecoveryPeriodSummary(
      days: 7,
      total: 4,
      urges: 2,
      slips: 1,
      victories: 1,
      averageIntensity: 3.5,
    );
    const previous = RecoveryPeriodSummary(
      days: 7,
      total: 3,
      urges: 1,
      slips: 0,
      victories: 2,
      averageIntensity: 2.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyRecoveryReviewSection(
            current: current,
            previous: previous,
          ),
        ),
      ),
    );

    expect(find.text('7-day recovery review'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('Previous 7 days'), findsOneWidget);
    expect(find.text('Logged moments: 4'), findsOneWidget);
    expect(find.text('Logged moments: 3'), findsOneWidget);
    expect(find.textContaining('do not by themselves mean recovery'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.textContaining('better week'), findsNothing);
    expect(find.textContaining('worse week'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weekly review shows honest empty intensity',
      (WidgetTester tester) async {
    const empty = RecoveryPeriodSummary(
      days: 7,
      total: 0,
      urges: 0,
      slips: 0,
      victories: 0,
      averageIntensity: 0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyRecoveryReviewSection(
            current: empty,
            previous: empty,
          ),
        ),
      ),
    );

    expect(find.text('Average recorded intensity: —'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
