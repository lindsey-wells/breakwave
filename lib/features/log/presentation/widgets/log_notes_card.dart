// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_notes_card.dart
// Purpose: Notes entry card for the BW-04 log flow.
// Notes: Neutral logging scaffold for BW-04.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogNotesCard extends StatelessWidget {
  final TextEditingController controller;

  const LogNotesCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a few honest words about what happened, what you were feeling, or what helped.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Example: hit a rough patch after work, felt restless, stepped away and took a walk.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
