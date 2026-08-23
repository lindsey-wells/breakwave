import 'package:flutter/material.dart';

class ConfirmedHelpfulActionsPicker extends StatelessWidget {
  const ConfirmedHelpfulActionsPicker({
    super.key,
    required this.actions,
    required this.selectedAction,
    required this.onUseAction,
  });

  final List<String> actions;
  final String selectedAction;
  final ValueChanged<String> onUseAction;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    return Container(
      key: const ValueKey<String>('confirmed-helpful-actions-picker'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Helpful actions you confirmed',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'These came from victories where you said an action helped. '
            'BreakWave is remembering what you recorded, not recommending '
            'what you should do next.',
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < actions.length; index += 1) ...<Widget>[
            if (index > 0) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onUseAction(actions[index]),
                icon: Icon(
                  selectedAction == actions[index]
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                ),
                label: Text(
                  selectedAction == actions[index]
                      ? '${actions[index]} — in my plan'
                      : 'Use ${actions[index]} in my plan',
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            'Nothing changes unless you choose an action, and it is not '
            'saved until you save your recovery plan.',
          ),
        ],
      ),
    );
  }
}
