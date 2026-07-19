// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_contact_links_card.dart
// Purpose: BW-48B BreakWave contact and social links.
// Notes: BW-80E uses default browser first, with browser fallback choices.
// Notes: BW-86D1 wires official BreakWave email and social links.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BreakWaveContactLinksCard extends StatelessWidget {
  const BreakWaveContactLinksCard({super.key});

  static const MethodChannel _socialLinksChannel =
      MethodChannel('breakwave/social_links');

  static const String websiteUrl = 'https://breakwaveapp.com';
  static const String emailAddress = 'support@breakwaveapp.com';
  static const String privacyEmailAddress = 'privacy@breakwaveapp.com';
  static const String tikTokHandle = '@BreakWaveapp';
  static const String xHandle = '@BreakWaveapp';
  static const String instagramHandle = '@breakwaveapp';
  static const String facebookHandle = '@breakwaveapp';
  static const String tikTokUrl = 'https://www.tiktok.com/@BreakWaveapp';
  static const String xUrl = 'https://x.com/BreakWaveapp';
  static const String instagramUrl = 'https://instagram.com/breakwaveapp';
  static const String facebookUrl = 'https://www.facebook.com/breakwaveapp';
  static const String tikTokBrowserUrl =
      'https://www.tiktok.com/@BreakWaveapp?is_from_webapp=1&sender_device=pc';
  static const String xBrowserUrl = 'https://x.com/BreakWaveapp';
  static const String instagramBrowserUrl = 'https://instagram.com/breakwaveapp';
  static const String facebookBrowserUrl = 'https://www.facebook.com/breakwaveapp';
  static const String chromePackage = 'com.android.chrome';
  static const String duckDuckGoPackage = 'com.duckduckgo.mobile.android';

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

  Future<void> _openWebsite(BuildContext context) {
    return _openSocialInDefaultBrowser(
      context,
      Uri.parse(websiteUrl),
    );
  }

  Future<void> _openEmail(BuildContext context) {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=BreakWave%20Support',
    );

    return _openUri(context, uri);
  }

  Future<void> _openPrivacyEmail(BuildContext context) {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: privacyEmailAddress,
      query: 'subject=BreakWave%20Privacy',
    );

    return _openUri(context, uri);
  }

  Future<void> _showSocialLinkOptions(
    BuildContext context, {
    required String label,
    required String handle,
    required String url,
    required String browserUrl,
  }) async {
    final Uri webUri = Uri.parse(url);
    final Uri browserUri = Uri.parse(browserUrl);

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
                  subtitle: const Text('Uses the installed social app when available.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInApp(context, webUri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Open in browser'),
                  subtitle: const Text('Tries the web profile in your browser. Copy link is the fallback.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInDefaultBrowser(context, browserUri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy link'),
                  subtitle: const Text('Copy the web profile link.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _copySocialLink(context, label: label, url: url);
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

  Future<void> _openSocialInDefaultBrowser(
    BuildContext context,
    Uri webUri,
  ) async {
    bool opened = false;

    try {
      opened = await _socialLinksChannel.invokeMethod<bool>(
            'openDefaultBrowser',
            <String, String>{'url': webUri.toString()},
          ) ??
          false;
    } catch (_) {
      opened = false;
    }

    if (opened) return;

    if (!context.mounted) return;
    await _showBrowserFallbackOptions(context, webUri);
  }

  Future<void> _showBrowserFallbackOptions(
    BuildContext context,
    Uri webUri,
  ) async {
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
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Choose browser'),
                  subtitle: Text('No default browser was available.'),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Open in Chrome'),
                  subtitle: const Text('Most Android devices include Chrome.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInBrowserPackage(
                      context,
                      webUri,
                      browserName: 'Chrome',
                      packageName: chromePackage,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.travel_explore),
                  title: const Text('Open in DuckDuckGo'),
                  subtitle: const Text('Use DuckDuckGo Browser if installed.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openSocialInBrowserPackage(
                      context,
                      webUri,
                      browserName: 'DuckDuckGo',
                      packageName: duckDuckGoPackage,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy link'),
                  subtitle: const Text('Copy the web profile link.'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Clipboard.setData(
                      ClipboardData(text: webUri.toString()),
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Web link copied.'),
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

  Future<void> _openSocialInBrowserPackage(
    BuildContext context,
    Uri webUri, {
    required String browserName,
    required String packageName,
  }) async {
    bool opened = false;

    try {
      opened = await _socialLinksChannel.invokeMethod<bool>(
            'openUrlInPackage',
            <String, String>{
              'url': webUri.toString(),
              'packageName': packageName,
            },
          ) ??
          false;
    } catch (_) {
      opened = false;
    }

    if (opened) return;

    await Clipboard.setData(ClipboardData(text: webUri.toString()));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$browserName was not available. Web link copied.'),
      ),
    );
  }

  Future<void> _copySocialLink(
    BuildContext context, {
    required String label,
    required String url,
  }) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label link copied.'),
      ),
    );
  }

  Future<void> _openTikTok(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'TikTok',
      handle: tikTokHandle,
      url: tikTokUrl,
      browserUrl: tikTokBrowserUrl,
    );
  }

  Future<void> _openX(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'X',
      handle: xHandle,
      url: xUrl,
      browserUrl: xBrowserUrl,
    );
  }

  Future<void> _openInstagram(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'Instagram',
      handle: instagramHandle,
      url: instagramUrl,
      browserUrl: instagramBrowserUrl,
    );
  }

  Future<void> _openFacebook(BuildContext context) {
    return _showSocialLinkOptions(
      context,
      label: 'Facebook',
      handle: facebookHandle,
      url: facebookUrl,
      browserUrl: facebookBrowserUrl,
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
              OutlinedButton.icon(
                onPressed: () => _openWebsite(context),
                icon: const Icon(Icons.language),
                label: const Text('Visit breakwaveapp.com'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _openEmail(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text(emailAddress),
              ),
                OutlinedButton.icon(
                  onPressed: () => _openPrivacyEmail(context),
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text(privacyEmailAddress),
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
                OutlinedButton.icon(
                  onPressed: () => _openInstagram(context),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Instagram $instagramHandle'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openFacebook(context),
                  icon: const Icon(Icons.public),
                  label: const Text('Facebook $facebookHandle'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
