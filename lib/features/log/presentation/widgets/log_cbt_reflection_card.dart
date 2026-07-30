// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_cbt_reflection_card.dart
// Purpose: BW-63 CBT-informed log reflection card.
// Notes: BW-72B keeps CBT logging lightweight while allowing Other actions.
// Notes: BW-72C keeps the replacement action visible and collapses optional reflection details.
// Notes: BW-76D adds real actions for Open Rescue and trusted support choices.
// Notes: BW-LOG-01B2 adds calm Reflection-specific language.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogCbtReflectionCard extends StatelessWidget {
  const LogCbtReflectionCard({
    super.key,
    required this.isReflectionEntry,
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

  final bool isReflectionEntry;
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

    final String cardTitle =
        isReflectionEntry ? 'Simple reflection' : 'Next better move';
    final String cardPrompt = isReflectionEntry
        ? 'Capture what you noticed and the next choice you want to make.'
        : 'Choose the clean action you want to take next.';
    final String reflectionSubtitle = isReflectionEntry
        ? 'Optional: Notice → Action → What happened → Next step'
        : 'Optional: Trigger → Thought → Urge → Action';
    final String reflectionPrompt = isReflectionEntry
        ? 'Notice the pattern without judging yourself.'
        : 'Name the thought, then choose the next better move.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              cardTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(cardPrompt),
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
                final bool isSelected =
                    selectedReplacementAction == action;

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
                    onReplacementSelected(
                      selected ? action : null,
                    );
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
              subtitle: Text(reflectionSubtitle),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(reflectionPrompt),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: thoughtController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isReflectionEntry
                        ? 'Thought or pattern noticed'
                        : 'Thought before the urge',
                    hintText: isReflectionEntry
                        ? 'Example: I reach for my phone when I feel disconnected.'
                        : 'Example: I need this to calm down.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: actionTakenController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isReflectionEntry
                        ? 'Action you took'
                        : 'Action taken',
                    hintText: isReflectionEntry
                        ? 'Example: paused, put the phone down, and took a walk.'
                        : 'Example: opened Rescue, left the room, texted Alex.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: consequenceController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isReflectionEntry
                        ? 'What happened next'
                        : 'Consequence / what happened next',
                    hintText: isReflectionEntry
                        ? 'Example: I felt calmer and more present.'
                        : 'Example: the urge dropped after ten minutes.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: betterPlanController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isReflectionEntry
                        ? 'What you want to try next'
                        : 'Better plan for next time',
                    hintText: isReflectionEntry
                        ? 'Example: check in before scrolling late at night.'
                        : 'Example: charge phone outside the bedroom.',
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
