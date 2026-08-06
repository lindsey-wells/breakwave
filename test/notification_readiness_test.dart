import 'package:breakwave/core/reminders/breakwave_notifications.dart';
import 'package:breakwave/core/reminders/notification_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test notification uses a dedicated notification id', () {
    expect(
      BreakWaveNotifications.testNotificationId,
      isNot(BreakWaveNotifications.dailyReminderId),
    );
    expect(
      BreakWaveNotifications.testNotificationId,
      isNot(BreakWaveNotifications.riskyNudgeId),
    );
  });

  test('discreet test notification copy remains neutral', () {
    final TestNotificationCopy copy =
        TestNotificationCopy.forPrivacy(
      discreetNotifications: true,
    );

    final String combined = '${copy.title} ${copy.body}'.toLowerCase();
    expect(combined, isNot(contains('breakwave')));
    expect(combined, isNot(contains('recovery')));
    expect(combined, isNot(contains('urge')));
    expect(combined, isNot(contains('porn')));
  });

  test('standard test notification explains scheduled-delay limit', () {
    final TestNotificationCopy copy =
        TestNotificationCopy.forPrivacy(
      discreetNotifications: false,
    );

    expect(copy.title, 'BreakWave test');
    expect(copy.body, contains('Android may still delay'));
  });

  test('readiness labels unavailable states honestly', () {
    const NotificationReadiness readiness = NotificationReadiness(
      initialized: false,
      timeZoneReady: false,
      timeZoneIdentifier: null,
      permissionStatus: NotificationPermissionStatus.unavailable,
    );

    expect(readiness.serviceLabel, 'Needs attention');
    expect(readiness.permissionLabel, 'Unavailable');
    expect(readiness.timeZoneLabel, 'Unavailable');
  });
}
