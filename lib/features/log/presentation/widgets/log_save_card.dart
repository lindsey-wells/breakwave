// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_save_card.dart
// Purpose: Save confirmation card for the BW-04 log flow.
// Notes: Neutral logging scaffold for BW-04.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogSaveCard extends StatelessWidget {
  final String entryType;
  final int intensity;
  final int triggerCount;
  final VoidCallback onSave;

  const LogSaveCard({
    super.key,
    required this.entryType,
    required this.intensity,
    required this.triggerCount,
    required this.onSave,
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
              'Save Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Current draft: $entryType • intensity $intensity • $triggerCount trigger${triggerCount == 1 ? '' : 's'} selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save log entry'),
            ),
          ],
        ),
      ),
    );
  }
}
