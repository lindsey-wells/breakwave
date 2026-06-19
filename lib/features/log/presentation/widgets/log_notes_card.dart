// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_notes_card.dart
// Purpose: Notes entry card for the BW-04 log flow.
// Notes: BW-72C collapses optional notes so Log stays fast.
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
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            'Optional notes',
            style: theme.textTheme.titleLarge,
          ),
          subtitle: const Text(
            'Add a few honest words only if they help.',
          ),
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a few honest words about what happened, what you were feeling, or what helped.',
              ),
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
