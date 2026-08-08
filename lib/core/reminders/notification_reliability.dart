// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: notification_reliability.dart
// Purpose: BW-NOTIFY-01B scheduled-delivery proof models and privacy-aware copy.
// ------------------------------------------------------------

import 'notification_readiness.dart';

enum ScheduledProofOutcome {
  scheduled,
  permissionDenied,
  unavailable,
  failed,
}

class ScheduledProofResult {
  const ScheduledProofResult({
    required this.outcome,
    required this.readiness,
    this.scheduledFor,
  });

  final ScheduledProofOutcome outcome;
  final NotificationReadiness readiness;
  final DateTime? scheduledFor;
}

class ScheduledProofCopy {
  const ScheduledProofCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static ScheduledProofCopy forPrivacy({
    required bool discreetNotifications,
  }) {
    if (discreetNotifications) {
      return const ScheduledProofCopy(
        title: 'Check-in',
        body: 'Your scheduled check is ready.',
      );
    }

    return const ScheduledProofCopy(
      title: 'BreakWave scheduled check',
      body:
          'Scheduled delivery check arrived. Android may still delay future reminders.',
    );
  }
}
