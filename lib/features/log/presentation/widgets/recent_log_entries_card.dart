// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recent_log_entries_card.dart
// Purpose: Recent log history surface for the BW-08 log flow.
// Notes: BW-72B makes recent entries compact with expandable details.
// Notes: BW-84A adds Show all / Show latest review controls.
// Notes: BW-84D highlights the most recently updated entry.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../domain/log_entry.dart';

class RecentLogEntriesCard extends StatelessWidget {
  final List<LogEntry> entries;
  final int totalEntryCount;
  final bool showAllEntries;
  final String? highlightedEntryId;
  final VoidCallback onToggleShowAll;
  final ValueChanged<LogEntry> onEdit;
  final ValueChanged<LogEntry> onDelete;

  const RecentLogEntriesCard({
    super.key,
    required this.entries,
    required this.totalEntryCount,
    required this.showAllEntries,
    required this.highlightedEntryId,
    required this.onToggleShowAll,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canToggleScope = totalEntryCount > 5;
    final int visibleCount = entries.length;

    final String reviewScopeText = entries.isEmpty
        ? 'No saved entries yet.'
        : showAllEntries
            ? 'Showing all $totalEntryCount saved entries.'
            : 'Showing latest $visibleCount of $totalEntryCount saved entries.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Newest saved moments. Open details only when you need them.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              reviewScopeText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (showAllEntries && totalEntryCount > 5) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Keep scrolling to review older saved entries.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (canToggleScope) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onToggleShowAll,
                icon: Icon(
                  showAllEntries
                      ? Icons.filter_list_outlined
                      : Icons.article_outlined,
                ),
                label: Text(
                  showAllEntries ? 'Show latest 5' : 'Show all entries',
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const _EmptyHistoryState()
            else
              Column(
                children: entries.map((LogEntry entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecentEntryRow(
                      entry: entry,
                      isHighlighted: entry.id == highlightedEntryId,
                      onEdit: () => onEdit(entry),
                      onDelete: () => onDelete(entry),
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

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: const Text(
        'No saved entries yet. Your recent log history will appear here after you save an entry.',
      ),
    );
  }
}

class _RecentEntryRow extends StatelessWidget {
  final LogEntry entry;
  final bool isHighlighted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecentEntryRow({
    required this.entry,
    required this.isHighlighted,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTimestamp(String iso) {
    try {
      final DateTime time = DateTime.parse(iso).toLocal();
      final String month = time.month.toString().padLeft(2, '0');
      final String day = time.day.toString().padLeft(2, '0');
      final int hour24 = time.hour;
      final int minute = time.minute;
      final int hour12 = hour24 == 0
          ? 12
          : (hour24 > 12 ? hour24 - 12 : hour24);
      final String minuteText = minute.toString().padLeft(2, '0');
      final String meridiem = hour24 >= 12 ? 'PM' : 'AM';
      return '$month/$day • $hour12:$minuteText $meridiem';
    } catch (_) {
      return 'Saved recently';
    }
  }

  bool get _hasDetails {
    return entry.thought.trim().isNotEmpty ||
        entry.actionTaken.trim().isNotEmpty ||
        entry.consequence.trim().isNotEmpty ||
        entry.betterPlan.trim().isNotEmpty ||
        entry.notes.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor =
        isHighlighted ? theme.colorScheme.primary : const Color(0x22FFFFFF);
    final Color backgroundColor = isHighlighted
        ? theme.colorScheme.primaryContainer.withOpacity(0.25)
        : Colors.transparent;

    final String triggerText = entry.triggers.isEmpty
        ? 'No triggers tagged'
        : entry.triggers.join(', ');

    final List<Widget> detailChildren = <Widget>[
      if (entry.thought.trim().isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          'Thought: ${entry.thought.trim()}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
      if (entry.actionTaken.trim().isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          'Action: ${entry.actionTaken.trim()}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
      if (entry.consequence.trim().isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          'Consequence: ${entry.consequence.trim()}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
      if (entry.betterPlan.trim().isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          'Better plan: ${entry.betterPlan.trim()}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
      if (entry.notes.trim().isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          entry.notes.trim(),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: isHighlighted ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                entry.entryType,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '•',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Intensity ${entry.intensity}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '•',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                _formatTimestamp(entry.createdAtIso),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (isHighlighted) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Updated just now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Triggers: $triggerText',
            style: theme.textTheme.bodyMedium,
          ),
          if (entry.replacementAction.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Replacement action: ${entry.replacementAction.trim()}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (_hasDetails) ...<Widget>[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Show details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detailChildren,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
