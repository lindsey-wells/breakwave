// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_intensity_section.dart
// Purpose: Intensity selector for the BW-04 log flow.
// Notes: Neutral logging scaffold for BW-06A.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/breakwave_colors.dart';

class LogIntensitySection extends StatelessWidget {
  final int selectedIntensity;
  final ValueChanged<int> onSelected;

  const LogIntensitySection({
    super.key,
    required this.selectedIntensity,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>[
      '1 Light',
      '2 Mild',
      '3 Strong',
      '4 Heavy',
      '5 Extreme',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Intensity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Rate how strong the moment felt. Fast honesty beats perfect detail.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(labels.length, (int index) {
                final int value = index + 1;
                final bool isSelected = selectedIntensity == value;
                return ChoiceChip(
                  label: Text(labels[index]),
                  selected: isSelected,
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                  backgroundColor: BreakWaveColors.chipIdle,
                  selectedColor: BreakWaveColors.chipSelected,
                  side: BorderSide(
                    color: isSelected
                        ? BreakWaveColors.chipSelectedBorder
                        : const Color(0x33FFFFFF),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                  elevation: isSelected ? 3 : 0,
                  shadowColor: BreakWaveColors.chipSelectedGlow,
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  onSelected: (_) => onSelected(value),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
