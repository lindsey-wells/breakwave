// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: urge_intensity_section.dart
// Purpose: Urge intensity selector for the BW-03 rescue flow.
// Notes: Neutral rescue flow scaffold for BW-06A.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/breakwave_colors.dart';

class UrgeIntensitySection extends StatelessWidget {
  final int selectedIntensity;
  final ValueChanged<int> onSelected;

  const UrgeIntensitySection({
    super.key,
    required this.selectedIntensity,
    required this.onSelected,
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
              'Urge Intensity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Name the wave honestly. You do not need to feel calm before you take the next good action.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _IntensityChip(
                  label: '1 Low',
                  isSelected: selectedIntensity == 1,
                  onTap: () => onSelected(1),
                ),
                _IntensityChip(
                  label: '2 Shaky',
                  isSelected: selectedIntensity == 2,
                  onTap: () => onSelected(2),
                ),
                _IntensityChip(
                  label: '3 Strong',
                  isSelected: selectedIntensity == 3,
                  onTap: () => onSelected(3),
                ),
                _IntensityChip(
                  label: '4 High Risk',
                  isSelected: selectedIntensity == 4,
                  onTap: () => onSelected(4),
                ),
                _IntensityChip(
                  label: '5 Critical',
                  isSelected: selectedIntensity == 5,
                  onTap: () => onSelected(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntensityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntensityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
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
      onSelected: (_) => onTap(),
    );
  }
}
