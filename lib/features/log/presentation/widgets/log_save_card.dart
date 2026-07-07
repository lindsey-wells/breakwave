// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_save_card.dart
// Purpose: Save confirmation card for the BW-04 log flow.
// Notes: BW-76B adds clearer save/update feedback without leaving Log.
// Notes: BW-84B makes editing mode visible near the save/update action.
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
  final VoidCallback onCancelEdit;

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
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String triggerLabel = triggerCount == 1 ? 'trigger' : 'triggers';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isEditing ? 'Update Entry' : 'Save Entry',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Current draft: $entryType • intensity $intensity • $triggerCount $triggerLabel selected',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Saved locally on this device: $savedEntryCount',
              style: theme.textTheme.bodyMedium,
            ),
            if (isEditing) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 1.4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.edit_note_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Editing saved entry',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Changes will update this saved log entry instead of creating a new one.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onCancelEdit,
                      icon: const Icon(Icons.close_outlined),
                      label: const Text('Cancel edit'),
                    ),
                  ],
                ),
              ),
            ],
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
                      style: theme.textTheme.bodyMedium,
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
