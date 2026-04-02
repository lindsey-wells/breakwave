// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_save_card.dart
// Purpose: Save confirmation card for the BW-04 log flow.
// Notes: BW-07 persistence foundation.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogSaveCard extends StatelessWidget {
  final String entryType;
  final int intensity;
  final int triggerCount;
  final int savedEntryCount;
  final bool isSaving;
  final Future<void> Function() onSave;

  const LogSaveCard({
    super.key,
    required this.entryType,
    required this.intensity,
    required this.triggerCount,
    required this.savedEntryCount,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final String triggerLabel = triggerCount == 1 ? 'trigger' : 'triggers';

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
              'Current draft: $entryType • intensity $intensity • $triggerCount $triggerLabel selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Saved locally on this device: $savedEntryCount',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isSaving ? null : () => onSave(),
              icon: const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : 'Save log entry'),
            ),
          ],
        ),
      ),
    );
  }
}
