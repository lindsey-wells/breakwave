// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: trusted_accountability_card.dart
// Purpose: Trusted-person accountability card for the BW-05 support flow.
// Notes: Neutral support scaffold for BW-05.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class TrustedAccountabilityCard extends StatelessWidget {
  const TrustedAccountabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Trusted Person and Accountability',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'BreakWave can later help users reach one safe person faster and with less friction.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _AccountabilityRow(
              icon: Icons.person_add_alt_outlined,
              text: 'Future trusted-person setup for quick contact.',
            ),
            const SizedBox(height: 10),
            const _AccountabilityRow(
              icon: Icons.message_outlined,
              text: 'Future check-in prompt and support message options.',
            ),
            const SizedBox(height: 10),
            const _AccountabilityRow(
              icon: Icons.handshake_outlined,
              text: 'Future accountability patterns for recurring high-risk moments.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.people_outline),
              label: const Text('Accountability tools placeholder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountabilityRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AccountabilityRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
