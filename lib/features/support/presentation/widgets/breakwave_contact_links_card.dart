// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_contact_links_card.dart
// Purpose: BW-48B BreakWave contact and social links.
// Notes: Adds simple launch-ready email, TikTok, and X contact links.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BreakWaveContactLinksCard extends StatelessWidget {
  const BreakWaveContactLinksCard({super.key});

  static const String emailAddress = 'BreakWaveapp@proton.me';
  static const String tikTokHandle = '@BreakWaveapp';
  static const String xHandle = '@BreakWaveapp';
  static const String tikTokUrl = 'https://www.tiktok.com/@BreakWaveapp';
  static const String xUrl = 'https://x.com/BreakWaveapp';

  Future<void> _openUri(BuildContext context, Uri uri) async {
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link right now.'),
        ),
      );
    }
  }

  Future<void> _openEmail(BuildContext context) {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=BreakWave%20Support',
    );

    return _openUri(context, uri);
  }

  Future<void> _openTikTok(BuildContext context) {
    return _openUri(context, Uri.parse(tikTokUrl));
  }

  Future<void> _openX(BuildContext context) {
    return _openUri(context, Uri.parse(xUrl));
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
            'Connect with BreakWave',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Use these links for support, updates, and launch announcements. BreakWave recovery tools work without following any social account.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => _openEmail(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text(emailAddress),
              ),
              OutlinedButton.icon(
                onPressed: () => _openTikTok(context),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('TikTok $tikTokHandle'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openX(context),
                icon: const Icon(Icons.alternate_email),
                label: const Text('X $xHandle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
