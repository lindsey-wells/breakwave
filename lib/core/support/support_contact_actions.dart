// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_actions.dart
// Purpose: BW-37 trusted contact action helpers.
// Notes: Launches direct SMS/email actions for the saved support contact.
// ------------------------------------------------------------

import 'package:url_launcher/url_launcher.dart';

import 'support_contact.dart';

class SupportContactActions {
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  static Future<bool> sendStrugglingText(SupportContact contact) async {
    if (!contact.hasPhone) return false;
    return _launchSms(
      phoneNumber: contact.phoneNumber,
      body: 'I’m struggling right now. Please check on me when you can.',
    );
  }

  static Future<bool> sendCheckOnMeText(SupportContact contact) async {
    if (!contact.hasPhone) return false;
    return _launchSms(
      phoneNumber: contact.phoneNumber,
      body: 'Please check on me soon. I could use support right now.',
    );
  }

  static Future<bool> sendCallMeText(SupportContact contact) async {
    if (!contact.hasPhone) return false;
    return _launchSms(
      phoneNumber: contact.phoneNumber,
      body: 'Can you call me when you can? I need some support right now.',
    );
  }

  static Future<bool> sendSupportEmail(SupportContact contact) async {
    if (!contact.hasEmail) return false;
    return _launchEmail(
      emailAddress: contact.emailAddress,
      subject: 'I could use support',
      body: 'I could use support right now. Please reach out when you can.',
    );
  }

  static Future<bool> _launchSms({
    required String phoneNumber,
    required String body,
  }) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      query: _encodeQueryParameters(<String, String>{
        'body': body,
      }),
    );

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<bool> _launchEmail({
    required String emailAddress,
    required String subject,
    required String body,
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
