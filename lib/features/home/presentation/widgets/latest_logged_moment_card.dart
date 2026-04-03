// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: latest_logged_moment_card.dart
// Purpose: Latest persisted log moment card for the BW-09 home flow.
// Notes: BW-09 home summary from persisted data.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../log/domain/log_entry.dart';

class LatestLoggedMomentCard extends StatelessWidget {
  final LogEntry? entry;

  const LatestLoggedMomentCard({
    super.key,
    required this.entry,
  });

  String _formatTimestamp(String iso) {
    try {
      final DateTime time = DateTime.parse(iso).toLocal();
      final String month = time.month.toString().padLeft(2, '0');
      final String day = time.day.toString().padLeft(2, '0');
      final int hour24 = time.hour;
      final int minute = time.minute;
      final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final String minuteText = minute.toString().padLeft(2, '0');
      final String meridiem = hour24 >= 12 ? 'PM' : 'AM';
      return '$month/$day • $hour12:$minuteText $meridiem';
    } catch (_) {
      return 'Saved recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final LogEntry? latest = entry;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: latest == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Latest Logged Moment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No logged moments yet. Once something is saved, the newest entry will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Latest Logged Moment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        latest.entryType,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Intensity ${latest.intensity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatTimestamp(latest.createdAtIso),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    latest.triggers.isEmpty
                        ? 'Triggers: none tagged'
                        : 'Triggers: ${latest.triggers.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (latest.notes.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      latest.notes.trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
