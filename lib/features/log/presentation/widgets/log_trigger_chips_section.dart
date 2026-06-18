// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_trigger_chips_section.dart
// Purpose: Trigger chip selector for the BW-04 log flow.
// Notes: BW-72B adds lightweight Other trigger capture.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/breakwave_colors.dart';

class LogTriggerChipsSection extends StatelessWidget {
  final List<String> availableTriggers;
  final Set<String> selectedTriggers;
  final ValueChanged<String> onToggle;
  final TextEditingController otherTriggerController;
  final bool showOtherTriggerField;

  const LogTriggerChipsSection({
    super.key,
    required this.availableTriggers,
    required this.selectedTriggers,
    required this.onToggle,
    required this.otherTriggerController,
    required this.showOtherTriggerField,
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
              'What was happening?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTriggers.map((String trigger) {
                final bool isSelected = selectedTriggers.contains(trigger);
                return FilterChip(
                  label: Text(trigger),
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
                  onSelected: (_) => onToggle(trigger),
                );
              }).toList(),
            ),
            if (showOtherTriggerField) ...<Widget>[
              const SizedBox(height: 14),
              TextField(
                controller: otherTriggerController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Other trigger',
                  hintText: 'Example: argument, social media, being alone.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
