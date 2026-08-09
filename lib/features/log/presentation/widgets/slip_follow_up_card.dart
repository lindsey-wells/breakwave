// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: slip_follow_up_card.dart
// Purpose: BW-SLIP-01A compassionate post-slip follow-up foundation.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class SlipFollowUpCard extends StatelessWidget {
  const SlipFollowUpCard({
    super.key,
    required this.thoughtController,
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
    final ColorScheme colors = theme.colorScheme;

    return Card(
      key: const ValueKey<String>('slip-follow-up-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.waves_outlined,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'After a slip',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You came back. Take a minute to notice the pattern '
              'and choose what happens next.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const _SlipStepLabel(
              label: 'Recognize',
              prompt: 'What was happening just before?',
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey<String>('slip-recognize-field'),
              controller: thoughtController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What was happening just before?',
                hintText:
                    'Example: late, alone, stressed, scrolling in bed.',
              ),
            ),
            const SizedBox(height: 20),
            const _SlipStepLabel(
              label: 'Interrupt',
              prompt: 'What could you notice earlier next time?',
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey<String>('slip-interrupt-field'),
              controller: betterPlanController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What could you notice earlier next time?',
                hintText:
                    'Example: I start scrolling when I feel disconnected.',
              ),
            ),
            const SizedBox(height: 20),
            const _SlipStepLabel(
              label: 'Redirect',
              prompt: 'What will you do next?',
            ),
            const SizedBox(height: 8),
            Text(
              'Choose one next right action. Core redirection stays '
              'available here whenever you need it.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: replacementActions.map((String action) {
                final bool selected =
                    selectedReplacementAction == action;

                return ChoiceChip(
                  key: ValueKey<String>(
                    'slip-next-action-$action',
                  ),
                  label: Text(action),
                  selected: selected,
                  selectedColor: colors.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? colors.onPrimary
                        : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: selected
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                  onSelected: (bool value) {
                    onReplacementSelected(
                      value ? action : null,
                    );
                  },
                );
              }).toList(),
            ),
            if (selectedReplacementAction == 'Open Rescue')
              ...<Widget>[
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const ValueKey<String>(
                    'slip-open-rescue-now',
                  ),
                  onPressed: onOpenRescue,
                  icon: const Icon(Icons.waves_outlined),
                  label: const Text('Open Rescue now'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If the urge is still active, Rescue is available now.',
                ),
              ],
            if (selectedReplacementAction == 'Text someone safe')
              ...<Widget>[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const ValueKey<String>(
                    'slip-open-trusted-support',
                  ),
                  onPressed: onOpenSupport,
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Open trusted support'),
                ),
              ],
            if (showOtherReplacementField) ...<Widget>[
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey<String>('slip-other-action-field'),
                controller: otherReplacementActionController,
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Your next right action',
                  hintText:
                      'Example: put the phone away and sit outside.',
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              key: const ValueKey<String>('slip-reinforce-message'),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.26),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.primary.withOpacity(0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Reinforce',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You came back and looked at what happened. '
                    'That matters.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose one response worth practicing. '
                    'You do not have to solve everything at once.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlipStepLabel extends StatelessWidget {
  const _SlipStepLabel({
    required this.label,
    required this.prompt,
  });

  final String label;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          prompt,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
