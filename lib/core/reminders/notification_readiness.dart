// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: notification_readiness.dart
// Purpose: BW-NOTIFY-01A notification readiness and test-result models.
// ------------------------------------------------------------

enum NotificationPermissionStatus {
  enabled,
  disabled,
  unavailable,
}

enum TestNotificationOutcome {
  shown,
  permissionDenied,
  unavailable,
  failed,
}

class NotificationReadiness {
  const NotificationReadiness({
    required this.initialized,
    required this.timeZoneReady,
    required this.timeZoneIdentifier,
    required this.permissionStatus,
    this.errorMessage,
  });

  final bool initialized;
  final bool timeZoneReady;
  final String? timeZoneIdentifier;
  final NotificationPermissionStatus permissionStatus;
  final String? errorMessage;

  String get serviceLabel => initialized ? 'Ready' : 'Needs attention';

  String get permissionLabel {
    switch (permissionStatus) {
      case NotificationPermissionStatus.enabled:
        return 'Allowed';
      case NotificationPermissionStatus.disabled:
        return 'Turned off';
      case NotificationPermissionStatus.unavailable:
        return 'Unavailable';
    }
  }

  String get timeZoneLabel {
    if (!timeZoneReady || timeZoneIdentifier == null) {
      return 'Unavailable';
    }
    return timeZoneIdentifier!;
  }
}

class TestNotificationResult {
  const TestNotificationResult({
    required this.outcome,
    required this.readiness,
  });

  final TestNotificationOutcome outcome;
  final NotificationReadiness readiness;
}

class TestNotificationCopy {
  const TestNotificationCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static TestNotificationCopy forPrivacy({
    required bool discreetNotifications,
  }) {
    if (discreetNotifications) {
      return const TestNotificationCopy(
        title: 'Check-in',
        body: 'Your test notification is working.',
      );
    }

    return const TestNotificationCopy(
      title: 'BreakWave test',
      body:
          'Notifications are ready. Android may still delay scheduled reminders.',
    );
  }
}
