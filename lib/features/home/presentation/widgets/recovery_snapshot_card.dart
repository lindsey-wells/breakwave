// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_snapshot_card.dart
// Purpose: Persisted recovery snapshot card for the BW-09 home flow.
// Notes: BW-09 home summary from persisted data.
// Notes: BW-81D makes snapshot metrics tappable entry points to Log.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class RecoverySnapshotCard extends StatelessWidget {
  final int totalEntries;
  final int urgeCount;
  final int slipCount;
  final int victoryCount;
  final VoidCallback onOpenLog;

  const RecoverySnapshotCard({
    super.key,
    required this.totalEntries,
    required this.urgeCount,
    required this.slipCount,
    required this.victoryCount,
    required this.onOpenLog,
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
                  ? 'Tap any snapshot number to open your Log.'
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
                  onTap: onOpenLog,
                ),
                _MetricPill(
                  label: 'Urges',
                  value: '$urgeCount',
                  onTap: onOpenLog,
                ),
                _MetricPill(
                  label: 'Slips',
                  value: '$slipCount',
                  onTap: onOpenLog,
                ),
                _MetricPill(
                  label: 'Victories',
                  value: '$victoryCount',
                  onTap: onOpenLog,
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
  final VoidCallback onTap;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(18);

    return Semantics(
      button: true,
      label: '$label: $value. Open Log.',
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
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
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
