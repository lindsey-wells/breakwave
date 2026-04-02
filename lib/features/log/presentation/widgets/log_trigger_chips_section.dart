// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_trigger_chips_section.dart
// Purpose: Trigger chip selector for the BW-04 log flow.
// Notes: Neutral logging scaffold for BW-04.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogTriggerChipsSection extends StatelessWidget {
  final List<String> availableTriggers;
  final Set<String> selectedTriggers;
  final ValueChanged<String> onToggle;

  const LogTriggerChipsSection({
    super.key,
    required this.availableTriggers,
    required this.selectedTriggers,
    required this.onToggle,
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
              'Trigger Signals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the trigger signals that best match what was happening.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTriggers.map((String trigger) {
                return FilterChip(
                  label: Text(trigger),
                  selected: selectedTriggers.contains(trigger),
                  onSelected: (_) => onToggle(trigger),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
