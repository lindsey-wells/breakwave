import 'package:breakwave/core/reminders/notification_readiness.dart';
import 'package:breakwave/features/support/presentation/widgets/reminder_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'test notification reports success without changing saved settings',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'bw-notify-sentinel': 'keep'},
      );

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final Map<String, Object?> before = <String, Object?>{
        for (final String key in preferences.getKeys())
          key: preferences.get(key),
      };

      const NotificationReadiness readiness =
          NotificationReadiness(
        initialized: true,
        timeZoneReady: true,
        timeZoneIdentifier: 'America/New_York',
        permissionStatus: NotificationPermissionStatus.enabled,
      );

      int sendCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReminderSettingsCard(
                readinessLoader: () async => readiness,
                testNotificationSender: () async {
                  sendCount += 1;
                  return const TestNotificationResult(
                    outcome: TestNotificationOutcome.shown,
                    readiness: readiness,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification readiness'), findsOneWidget);
      expect(find.text('America/New_York'), findsOneWidget);

      final Finder sendButton =
          find.byKey(const Key('notification-test-send'));
      await tester.ensureVisible(sendButton);
      await tester.pumpAndSettle();
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(sendCount, 1);
      expect(
        find.text(
          'Test notification sent. Check your notification shade.',
        ),
        findsWidgets,
      );

      final Map<String, Object?> after = <String, Object?>{
        for (final String key in preferences.getKeys())
          key: preferences.get(key),
      };
      expect(after, before);
    },
  );
}
