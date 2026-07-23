// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_privacy_policy.dart
// Purpose: Canonical BreakWave Privacy Policy URL and button.
// Notes: Keeps compliance-facing values out of large Support files.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWavePrivacyPolicy {
  const BreakWavePrivacyPolicy._();

  static const String url =
      'https://breakwaveapp.com/#privacy';

  static const String buttonLabel =
      'Read Privacy Policy';

  static final Uri uri = Uri.parse(url);
}

class BreakWavePrivacyPolicyButton extends StatelessWidget {
  const BreakWavePrivacyPolicyButton({
    super.key,
    required this.onPressed,
  });

  static const Key widgetKey =
      Key('breakwave_privacy_policy_button');

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: widgetKey,
      onPressed: onPressed,
      icon: const Icon(Icons.policy_outlined),
      label: const Text(
        BreakWavePrivacyPolicy.buttonLabel,
      ),
    );
  }
}
