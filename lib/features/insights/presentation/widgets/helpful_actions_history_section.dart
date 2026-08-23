import 'package:flutter/material.dart';

import '../../domain/recovery_insights_snapshot.dart';

class HelpfulActionsHistorySection extends StatelessWidget {
  const HelpfulActionsHistorySection({
    super.key,
    required this.actions,
  });

  final List<HelpfulActionInsight> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<HelpfulActionInsight> visible =
        actions.take(5).toList(growable: false);

    return Card(
      key: const ValueKey<String>('helpful-actions-history-section'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Helpful actions over time',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'From victories you recorded',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'The 30-day window is part of the 90-day window. '
              'These counts describe what you recorded after victories; '
              'they do not prove what caused an outcome or predict what '
              'will work next.',
            ),
            const SizedBox(height: 14),
            if (visible.isEmpty)
              const Text(
                'No helpful actions were recorded after victories '
                'in the last 90 days.',
              )
            else
              for (int index = 0; index < visible.length; index += 1) ...<
                  Widget>[
                if (index > 0) const SizedBox(height: 12),
                _HelpfulActionHistoryRow(
                  insight: visible[index],
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _HelpfulActionHistoryRow extends StatelessWidget {
  const _HelpfulActionHistoryRow({
    required this.insight,
  });

  final HelpfulActionInsight insight;

  String _victoryLabel(int count) {
    return count == 1 ? '1 victory' : '$count victories';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                insight.action,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '30 days: ${_victoryLabel(insight.victoryCount30Days)} '
                '• 90 days: ${_victoryLabel(insight.victoryCount90Days)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
