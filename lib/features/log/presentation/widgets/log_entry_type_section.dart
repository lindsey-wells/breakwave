// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry_type_section.dart
// Purpose: Entry type selector for the BW-04 log flow.
// Notes: Neutral logging scaffold for BW-04.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogEntryTypeSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onSelected;

  const LogEntryTypeSection({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> entryTypes = <String>[
      'Urge',
      'Slip',
      'Victory',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Entry Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the kind of moment you are logging right now.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entryTypes.map((String type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  onSelected: (_) => onSelected(type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
