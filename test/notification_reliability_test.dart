import 'package:breakwave/core/reminders/notification_reliability.dart';
import 'package:breakwave/core/reminders/notification_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scheduled proof copy remains neutral in discreet mode', () {
    final ScheduledProofCopy copy = ScheduledProofCopy.forPrivacy(
      discreetNotifications: true,
    );

    expect(copy.title, 'Check-in');
    expect(copy.body, 'Your scheduled check is ready.');
    expect(copy.title.toLowerCase(), isNot(contains('breakwave')));
    expect(copy.body.toLowerCase(), isNot(contains('urge')));
  });

  test('standard scheduled proof copy explains delivery limits', () {
    final ScheduledProofCopy copy = ScheduledProofCopy.forPrivacy(
      discreetNotifications: false,
    );

    expect(copy.title, 'BreakWave scheduled check');
    expect(copy.body, contains('Android may still delay'));
  });

  test('scheduled proof result can carry the expected delivery time', () {
    const NotificationReadiness readiness = NotificationReadiness(
      initialized: true,
      timeZoneReady: true,
      timeZoneIdentifier: 'America/New_York',
      permissionStatus: NotificationPermissionStatus.enabled,
    );
    final DateTime scheduledFor = DateTime(2026, 8, 7, 20, 30);

    final ScheduledProofResult result = ScheduledProofResult(
      outcome: ScheduledProofOutcome.scheduled,
      readiness: readiness,
      scheduledFor: scheduledFor,
    );

    expect(result.outcome, ScheduledProofOutcome.scheduled);
    expect(result.scheduledFor, scheduledFor);
  });
}
