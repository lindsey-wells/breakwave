// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: emergency_help_card.dart
// Purpose: Immediate emergency guidance for BreakWave.
// Notes: BW-SUPPORT-01B separates immediate danger from ordinary urge support.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHelpCard extends StatelessWidget {
  const EmergencyHelpCard({super.key});

  Future<void> _callEmergencyServices(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: '911',
    );

    final bool ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Opening your phone app.'
              : 'Unable to open the phone app right now.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.emergency_outlined,
                color: colorScheme.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Immediate danger',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Use this only when you or someone else may be in immediate danger or needs urgent police, fire, or medical help.',
          ),
          const SizedBox(height: 10),
          const Text(
            'In the United States, this button calls 911. Outside the United States, use your local emergency number.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _callEmergencyServices(context),
            icon: const Icon(Icons.phone_in_talk_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Call 911 (U.S.)'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'For urge support that is not an immediate emergency, use the trusted-contact tools below.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
