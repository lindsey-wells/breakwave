import 'package:flutter/material.dart';

class PatternHelpfulActionsCard extends StatelessWidget {
  const PatternHelpfulActionsCard({
    super.key,
    required this.actionCounts,
  });

  final Map<String, int> actionCounts;

  @override
  Widget build(BuildContext context) {
    if (actionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final List<MapEntry<String, int>> visible =
        actionCounts.entries.take(3).toList(growable: false);

    return Card(
      key: const ValueKey<String>('pattern-helpful-actions-card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Actions you recorded as helpful',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'From confirmed victories',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'These counts show only what you recorded after victories. '
              'They do not prove what caused the outcome or predict what '
              'will work next.',
            ),
            const SizedBox(height: 14),
            for (int index = 0; index < visible.length; index += 1) ...<Widget>[
              if (index > 0) const SizedBox(height: 10),
              _HelpfulActionRow(
                action: visible[index].key,
                count: visible[index].value,
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'You decide whether any of these fit a future wave.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpfulActionRow extends StatelessWidget {
  const _HelpfulActionRow({
    required this.action,
    required this.count,
  });

  final String action;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String countLabel = count == 1
        ? 'Recorded as helpful in 1 victory.'
        : 'Recorded as helpful in $count victories.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                action,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                countLabel,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
