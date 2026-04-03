// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_snapshot_card.dart
// Purpose: Persisted recovery snapshot card for the BW-09 home flow.
// Notes: BW-09 home summary from persisted data.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class RecoverySnapshotCard extends StatelessWidget {
  final int totalEntries;
  final int urgeCount;
  final int slipCount;
  final int victoryCount;

  const RecoverySnapshotCard({
    super.key,
    required this.totalEntries,
    required this.urgeCount,
    required this.slipCount,
    required this.victoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasData = totalEntries > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recovery Snapshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasData
                  ? 'A simple read on what has been logged so far on this device.'
                  : 'No saved data yet. Your home snapshot will fill in as you log moments.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricPill(
                  label: 'Saved entries',
                  value: '$totalEntries',
                ),
                _MetricPill(
                  label: 'Urges',
                  value: '$urgeCount',
                ),
                _MetricPill(
                  label: 'Slips',
                  value: '$slipCount',
                ),
                _MetricPill(
                  label: 'Victories',
                  value: '$victoryCount',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
