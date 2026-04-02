// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_categories_card.dart
// Purpose: Support categories card for the BW-05 support flow.
// Notes: Neutral support scaffold for BW-05.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class SupportCategoriesCard extends StatelessWidget {
  const SupportCategoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Support Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'BreakWave support will grow in layers so users can reach for the right kind of help quickly.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _CategoryRow(
              icon: Icons.shield_outlined,
              title: 'Immediate Support',
              body: 'Fast options for high-pressure moments.',
            ),
            const SizedBox(height: 12),
            const _CategoryRow(
              icon: Icons.people_outline,
              title: 'Accountability',
              body: 'Trusted-person and check-in tools.',
            ),
            const SizedBox(height: 12),
            const _CategoryRow(
              icon: Icons.menu_book_outlined,
              title: 'Education',
              body: 'Recovery learning and practical understanding.',
            ),
            const SizedBox(height: 12),
            const _CategoryRow(
              icon: Icons.settings_suggest_outlined,
              title: 'Longer-Term Tools',
              body: 'Future support systems and deeper guidance.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _CategoryRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(body),
            ],
          ),
        ),
      ],
    );
  }
}
