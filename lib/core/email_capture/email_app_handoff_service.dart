// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_app_handoff_service.dart
// Purpose: BW-44B email app handoff service.
// Notes: Builds a prefilled email draft from saved email-consent data.
// ------------------------------------------------------------

import 'package:url_launcher/url_launcher.dart';

import 'email_app_handoff_settings.dart';
import 'email_app_handoff_store.dart';
import 'email_capture_settings.dart';
import 'email_capture_store.dart';

class EmailAppHandoffService {
  static bool hasSendableData(EmailCaptureSettings settings) {
    return settings.emailAddress.trim().isNotEmpty ||
        settings.marketingOptIn ||
        settings.researchOptIn;
  }

  static String buildSubject() {
    return 'BreakWave lead / consent submission';
  }

  static String buildBody(
    EmailCaptureSettings settings,
    DateTime now,
  ) {
    return [
      'BreakWave lead / consent submission',
      '',
      'Email address: ${settings.emailAddress.trim().isEmpty ? '(none)' : settings.emailAddress.trim()}',
      'Marketing opt-in: ${settings.marketingOptIn}',
      'Research opt-in: ${settings.researchOptIn}',
      'Timestamp ISO: ${now.toIso8601String()}',
      'Source: BreakWave',
    ].join('\n');
  }

  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }

  static Future<bool> openSavedDraft() async {
    final EmailAppHandoffSettings handoffSettings =
        await EmailAppHandoffStore.load();
    final EmailCaptureSettings emailSettings =
        await EmailCaptureStore.load();

    if (!handoffSettings.hasRecipient) {
      throw StateError('Missing BreakWave team email address.');
    }

    if (!hasSendableData(emailSettings)) {
      throw StateError('No saved email-consent data to send.');
    }

    final Uri uri = Uri(
      scheme: 'mailto',
      path: handoffSettings.teamEmailAddress.trim(),
      query: _encodeQueryParameters(<String, String>{
        'subject': buildSubject(),
        'body': buildBody(emailSettings, DateTime.now()),
      }),
    );

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
