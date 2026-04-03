// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recent_log_entries_card.dart
// Purpose: Recent log history surface for the BW-08 log flow.
// Notes: BW-10 edit/delete actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../domain/log_entry.dart';

class RecentLogEntriesCard extends StatelessWidget {
  final List<LogEntry> entries;
  final ValueChanged<LogEntry> onEdit;
  final ValueChanged<LogEntry> onDelete;

  const RecentLogEntriesCard({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
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
              'Recent Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your newest saved entries appear here so patterns stop feeling invisible.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecentEntryRow({
    required this.entry,
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

  @override
  Widget build(BuildContext context) {
    final String triggerText = entry.triggers.isEmpty
        ? 'No triggers tagged'
        : entry.triggers.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '•',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Intensity ${entry.intensity}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '•',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatTimestamp(entry.createdAtIso),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Triggers: $triggerText',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (entry.notes.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              entry.notes.trim(),
              style: Theme.of(context).textTheme.bodyMedium,
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
