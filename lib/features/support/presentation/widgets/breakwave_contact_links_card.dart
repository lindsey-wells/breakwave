// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_contact_links_card.dart
// Purpose: BW-48B BreakWave contact and social links.
// Notes: BW-80A adds app/browser/copy chooser for social links.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BreakWaveContactLinksCard extends StatelessWidget {
  const BreakWaveContactLinksCard({super.key});

  static const MethodChannel _socialLinksChannel =
      MethodChannel('breakwave/social_links');

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

  Future<void> _showSocialLinkOptions(
    BuildContext context, {
    required String label,
    required String handle,
    required String url,
  }) async {
    final Uri webUri = Uri.parse(url);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  subtitle: Text(handle),
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Open in app'),
                  subtitle: const Text('Uses the installed app when your device supports it.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInApp(context, webUri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Open web link'),
                  subtitle: const Text('Open the website view instead of the social app.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInBrowser(context, webUri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy link'),
                  subtitle: Text(url),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Clipboard.setData(ClipboardData(text: url));

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label link copied.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSocialInApp(BuildContext context, Uri webUri) async {
    final bool opened = await launchUrl(
      webUri,
      mode: LaunchMode.externalNonBrowserApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App not available. Choose browser or copy link instead.'),
        ),
      );
    }
  }

  Future<void> _openSocialInBrowser(BuildContext context, Uri webUri) async {
    bool openedChooser = false;

    try {
      openedChooser = await _socialLinksChannel.invokeMethod<bool>(
            'openBrowserChooser',
            <String, String>{'url': webUri.toString()},
          ) ??
          false;
    } catch (_) {
      openedChooser = false;
    }

    if (openedChooser) return;

    await Clipboard.setData(ClipboardData(text: webUri.toString()));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Web link copied. Paste it into your browser.'),
      ),
    );
  }

  Future<void> _openTikTok(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'TikTok',
      handle: tikTokHandle,
      url: tikTokUrl,
    );
  }

  Future<void> _openX(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'X',
      handle: xHandle,
      url: xUrl,
    );
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
