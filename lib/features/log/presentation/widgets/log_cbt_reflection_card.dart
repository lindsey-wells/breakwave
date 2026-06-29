// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_cbt_reflection_card.dart
// Purpose: BW-63 CBT-informed log reflection card.
// Notes: BW-72B keeps CBT logging lightweight while allowing Other actions.
// Notes: BW-72C keeps the replacement action visible and collapses optional reflection details.
// Notes: BW-76D adds real actions for Open Rescue and trusted support choices.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogCbtReflectionCard extends StatelessWidget {
  const LogCbtReflectionCard({
    super.key,
    required this.thoughtController,
    required this.actionTakenController,
    required this.consequenceController,
    required this.betterPlanController,
    required this.replacementActions,
    required this.selectedReplacementAction,
    required this.onReplacementSelected,
    required this.otherReplacementActionController,
    required this.showOtherReplacementField,
    required this.onOpenRescue,
    required this.onOpenSupport,
  });

  final TextEditingController thoughtController;
  final TextEditingController actionTakenController;
  final TextEditingController consequenceController;
  final TextEditingController betterPlanController;
  final List<String> replacementActions;
  final String? selectedReplacementAction;
  final ValueChanged<String?> onReplacementSelected;
  final TextEditingController otherReplacementActionController;
  final bool showOtherReplacementField;
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenSupport;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Next better move',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the clean action you want to take next.',
            ),
            const SizedBox(height: 16),
            Text(
              'Healthy replacement action',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: replacementActions.map((String action) {
                final bool isSelected = selectedReplacementAction == action;

                return ChoiceChip(
                  label: Text(action),
                  selected: isSelected,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  onSelected: (bool selected) {
                    onReplacementSelected(selected ? action : null);
                  },
                );
              }).toList(),
            ),
            if (selectedReplacementAction == 'Open Rescue') ...<Widget>[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onOpenRescue,
                icon: const Icon(Icons.waves_outlined),
                label: const Text('Open Rescue now'),
              ),
            ],
            if (selectedReplacementAction == 'Text someone safe') ...<Widget>[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onOpenSupport,
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Open trusted support'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use your saved trusted contact or support message from the Support tab.',
              ),
            ],
            if (showOtherReplacementField) ...<Widget>[
              const SizedBox(height: 14),
              TextField(
                controller: otherReplacementActionController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Other replacement action',
                  hintText: 'Example: call sponsor, do pushups, sit outside.',
                ),
              ),
            ],
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Add reflection details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Optional: Trigger → Thought → Urge → Action',
              ),
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name the thought, then choose the next better move.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: thoughtController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Thought before the urge',
                    hintText: 'Example: I need this to calm down.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: actionTakenController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Action taken',
                    hintText: 'Example: opened Rescue, left the room, texted Alex.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: consequenceController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Consequence / what happened next',
                    hintText: 'Example: the urge dropped after ten minutes.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: betterPlanController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Better plan for next time',
                    hintText: 'Example: charge phone outside the bedroom.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
