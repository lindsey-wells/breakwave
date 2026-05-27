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
  static const String defaultTeamEmailAddress = 'BreakWaveapp@proton.me';

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
    final String email = settings.emailAddress.trim();

    return [
      'BreakWave email / consent handoff',
      '',
      'This message was created by the BreakWave app after the user chose to send their saved email preferences.',
      '',
      'Email address: ${email.isEmpty ? '(none)' : email}',
      'Marketing updates consent: ${settings.marketingOptIn ? 'yes' : 'no'}',
      'Research / feedback consent: ${settings.researchOptIn ? 'yes' : 'no'}',
      '',
      'Timestamp ISO: ${now.toIso8601String()}',
      'Source: BreakWave Android MVP',
      '',
      'Privacy note: this handoff is manual. The user can review, edit, or cancel this email before sending.',
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

    final String recipient = handoffSettings.hasRecipient
        ? handoffSettings.teamEmailAddress.trim()
        : defaultTeamEmailAddress;

    if (!hasSendableData(emailSettings)) {
      throw StateError('No saved email-consent data to send.');
    }

    final Uri uri = Uri(
      scheme: 'mailto',
      path: recipient,
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
