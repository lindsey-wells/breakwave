// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry_type_section.dart
// Purpose: Entry type selector for the BW-04 log flow.
// Notes: BW-72B shortens Log copy for faster capture.
// Notes: BW-LOG-01A adds distinct icon and color identity.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/breakwave_colors.dart';
import 'log_entry_visuals.dart';

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
              'What happened?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick the closest match.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entryTypes.map((String type) {
                final bool isSelected = selectedType == type;
                final LogEntryVisualStyle visual =
                    LogEntryVisuals.forType(type);

                return Semantics(
                  selected: isSelected,
                  label: '$type log entry type',
                  child: ChoiceChip(
                    key: ValueKey<String>(
                      'log-entry-type-$type',
                    ),
                    avatar: Icon(
                      visual.icon,
                      size: 19,
                      color: visual.color,
                    ),
                    label: Text(type),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: BreakWaveColors.chipIdle,
                    selectedColor: visual.backgroundColor,
                    side: BorderSide(
                      color: isSelected
                          ? visual.color
                          : const Color(0x33FFFFFF),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    elevation: isSelected ? 3 : 0,
                    shadowColor: visual.color.withOpacity(0.30),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                    onSelected: (_) => onSelected(type),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
