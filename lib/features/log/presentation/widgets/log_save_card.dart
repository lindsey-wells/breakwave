// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_save_card.dart
// Purpose: Save confirmation card for the BW-04 log flow.
// Notes: BW-76B adds clearer save/update feedback without leaving Log.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogSaveCard extends StatelessWidget {
  final String entryType;
  final int intensity;
  final int triggerCount;
  final int savedEntryCount;
  final bool isSaving;
  final bool isEditing;
  final String? lastSaveMessage;
  final Future<void> Function() onSave;

  const LogSaveCard({
    super.key,
    required this.entryType,
    required this.intensity,
    required this.triggerCount,
    required this.savedEntryCount,
    required this.isSaving,
    required this.isEditing,
    required this.lastSaveMessage,
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
              isEditing ? 'Update Entry' : 'Save Entry',
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
            if (lastSaveMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lastSaveMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isSaving ? null : () => onSave(),
              icon: const Icon(Icons.save_outlined),
              label: Text(
                isSaving
                    ? 'Saving...'
                    : isEditing
                        ? 'Update log entry'
                        : 'Save log entry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
