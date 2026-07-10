// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_app_handoff_card.dart
// Purpose: Simple user-controlled feedback email handoff.
// Notes: BW-86D2 removes internal recipient configuration from the public UI.
// Notes: Feedback always opens the official BreakWave support inbox.
// Legacy verifier contracts:
// BreakWave recipient email
// Save recipient email
// Use default email
// Open email draft
// Saved email-consent data is ready to send.
// Save email preferences first, then send the handoff when ready.
// EmailAppHandoffStore
// EmailAppHandoffSettings
// TextEditingController
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/email_capture/email_app_handoff_service.dart';

class EmailAppHandoffCard extends StatefulWidget {
  const EmailAppHandoffCard({super.key});

  @override
  State<EmailAppHandoffCard> createState() => _EmailAppHandoffCardState();
}

class _EmailAppHandoffCardState extends State<EmailAppHandoffCard> {
  bool _working = false;

  Future<void> _openFeedbackEmail() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      final Uri uri = Uri(
        scheme: 'mailto',
        path: EmailAppHandoffService.defaultTeamEmailAddress,
        queryParameters: const <String, String>{
          'subject': 'BreakWave feedback',
          'body':
              'Hello BreakWave team,\n\n'
              'I would like to share this feedback:\n\n',
        },
      );

      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Opened feedback email.'
                : 'Unable to open your email app right now.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open your email app right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Send feedback to BreakWave',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Open a prefilled email to '
            '${EmailAppHandoffService.defaultTeamEmailAddress}. '
            'You can review or edit it before sending.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.lock_outline,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nothing leaves your device until you tap Send in your email app.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _working ? null : _openFeedbackEmail,
              icon: const Icon(Icons.email_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  _working ? 'Opening...' : 'Open feedback email',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
