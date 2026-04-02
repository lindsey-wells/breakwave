// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: redirect_actions_card.dart
// Purpose: Fast redirect actions card for the BW-03 rescue flow.
// Notes: Neutral rescue flow scaffold for BW-03.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class RedirectActionsCard extends StatelessWidget {
  const RedirectActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fast Redirect Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick one immediate action that changes your body, your device access, or your location.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                ActionChip(
                  avatar: const Icon(Icons.phone_android_outlined),
                  label: const Text('Put the phone down'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.door_front_door_outlined),
                  label: const Text('Leave the room'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.directions_walk_outlined),
                  label: const Text('Take a short walk'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.water_drop_outlined),
                  label: const Text('Cold water reset'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.message_outlined),
                  label: const Text('Text someone safe'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
