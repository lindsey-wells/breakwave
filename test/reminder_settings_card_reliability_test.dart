import 'package:breakwave/core/reminders/notification_readiness.dart';
import 'package:breakwave/core/reminders/notification_reliability.dart';
import 'package:breakwave/features/support/presentation/widgets/reminder_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'scheduled proof and Android handoffs do not change saved settings',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{'bw-notify-01b-sentinel': 'keep'},
      );

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final Map<String, Object?> before = <String, Object?>{
        for (final String key in preferences.getKeys())
          key: preferences.get(key),
      };

      const NotificationReadiness readiness = NotificationReadiness(
        initialized: true,
        timeZoneReady: true,
        timeZoneIdentifier: 'America/New_York',
        permissionStatus: NotificationPermissionStatus.enabled,
      );

      int proofCount = 0;
      int notificationSettingsCount = 0;
      int appSettingsCount = 0;
      int exactAlarmRequestCount = 0;
      int exactAlarmRescheduleCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReminderSettingsCard(
                readinessLoader: () async => readiness,
                reliabilityProofScheduler: () async {
                  proofCount += 1;
                  return ScheduledProofResult(
                    outcome: ScheduledProofOutcome.scheduled,
                    readiness: readiness,
                    scheduledFor: DateTime(2026, 8, 7, 20, 30),
                  );
                },
                notificationSettingsOpener: () async {
                  notificationSettingsCount += 1;
                  return true;
                },
                appSettingsOpener: () async {
                  appSettingsCount += 1;
                  return true;
                },
                exactAlarmRequester: () async {
                  exactAlarmRequestCount += 1;
                  return true;
                },
                exactAlarmRescheduler: () async {
                  exactAlarmRescheduleCount += 1;
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder exactAlarm =
          find.byKey(const Key('notification-exact-alarm-request'));
      await tester.ensureVisible(exactAlarm);
      await tester.tap(exactAlarm);
      await tester.pumpAndSettle();

      expect(exactAlarmRequestCount, 1);
      expect(exactAlarmRescheduleCount, 1);
      expect(
        find.textContaining('Precise timing allowed'),
        findsWidgets,
      );

      final Finder proof =
          find.byKey(const Key('notification-proof-schedule'));
      await tester.ensureVisible(proof);
      await tester.tap(proof);
      await tester.pumpAndSettle();

      expect(proofCount, 1);
      expect(
        find.textContaining('Scheduled check set for about'),
        findsWidgets,
      );

      final Finder notifications =
          find.byKey(const Key('notification-settings-open'));
      await tester.ensureVisible(notifications);
      await tester.tap(notifications);
      await tester.pumpAndSettle();

      final Finder appSettings =
          find.byKey(const Key('app-settings-open'));
      await tester.ensureVisible(appSettings);
      await tester.tap(appSettings);
      await tester.pumpAndSettle();

      expect(notificationSettingsCount, 1);
      expect(appSettingsCount, 1);

      final Map<String, Object?> after = <String, Object?>{
        for (final String key in preferences.getKeys())
          key: preferences.get(key),
      };
      expect(after, before);
    },
  );
}
