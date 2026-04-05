// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: simple_insights_card.dart
// Purpose: BW-20 simple insights surface v1.
// Notes: Lightweight Home insights from logs, check-ins, and watch patterns.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/checkin/daily_check_in_entry.dart';
import '../../../core/checkin/daily_check_in_store.dart';
import '../../../core/triggers/triggers_selection.dart';
import '../../../core/triggers/triggers_store.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';

class SimpleInsightsCard extends StatefulWidget {
  const SimpleInsightsCard({super.key});

  @override
  State<SimpleInsightsCard> createState() => _SimpleInsightsCardState();
}

class _SimpleInsightsCardState extends State<SimpleInsightsCard> {
  final LogRepository _repository = const LogRepository();

  bool _loading = true;
  _InsightsSnapshot _snapshot = const _InsightsSnapshot.empty();

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final List<LogEntry> allEntries = await _repository.loadEntries();
    final List<DailyCheckInEntry> checkIns = await DailyCheckInStore.loadEntries();
    final TriggersSelection triggersSelection = await TriggersStore.loadSelection();

    final List<LogEntry> sortedEntries = List<LogEntry>.from(allEntries)
      ..sort((LogEntry a, LogEntry b) {
        final DateTime aTime =
            DateTime.tryParse(a.createdAtIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bTime =
            DateTime.tryParse(b.createdAtIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    final List<LogEntry> recentEntries = sortedEntries.take(8).toList();

    int urgeCount = 0;
    int victoryCount = 0;
    int slipCount = 0;
    int rescueFollowThrough = 0;
    int totalIntensity = 0;

    for (final LogEntry entry in recentEntries) {
      totalIntensity += entry.intensity;

      switch (entry.entryType) {
        case 'Urge':
          urgeCount += 1;
          break;
        case 'Victory':
          victoryCount += 1;
          break;
        case 'Slip':
          slipCount += 1;
          break;
      }

      if (entry.triggers.contains('Rescue Completion') ||
          entry.triggers.contains('Wave Timer')) {
        rescueFollowThrough += 1;
      }
    }

    final double averageIntensity =
        recentEntries.isEmpty ? 0 : totalIntensity / recentEntries.length;

    final String intensityText;
    if (recentEntries.isEmpty) {
      intensityText = 'Intensity trend: no recent entries yet.';
    } else if (averageIntensity <= 2.2) {
      intensityText = 'Intensity trend: recent waves are leaning lighter.';
    } else if (averageIntensity <= 3.6) {
      intensityText = 'Intensity trend: recent waves are landing in the middle range.';
    } else {
      intensityText = 'Intensity trend: recent waves are leaning strong, so quicker interruption matters.';
    }

    final List<String> watchPreview = <String>[];
    for (final String item in <String>[
      ...triggersSelection.selectedTriggers,
      ...triggersSelection.selectedRiskyTimes,
    ]) {
      if (!watchPreview.contains(item)) {
        watchPreview.add(item);
      }
      if (watchPreview.length == 3) {
        break;
      }
    }

    final int recentCheckIns = _countRecentCheckIns(checkIns, days: 7);

    if (!mounted) return;

    setState(() {
      _snapshot = _InsightsSnapshot(
        recentEntriesText: recentEntries.isEmpty
            ? 'Recent entries: none yet.'
            : 'Recent entries: $urgeCount urge • $victoryCount victory • $slipCount slip',
        intensityText: intensityText,
        rescueText: rescueFollowThrough == 0
            ? 'Rescue follow-through: none logged yet.'
            : 'Rescue follow-through: $rescueFollowThrough recent rescue completion${rescueFollowThrough == 1 ? '' : 's'}.',
        watchText: watchPreview.isEmpty
            ? 'Watch pattern: no triggers or risky times saved yet.'
            : 'Watch pattern: ${watchPreview.join(' • ')}',
        checkInText: recentCheckIns == 0
            ? 'Daily contact: no recent check-ins yet.'
            : 'Daily contact: $recentCheckIns check-in${recentCheckIns == 1 ? '' : 's'} in the last 7 days.',
      );
      _loading = false;
    });
  }

  int _countRecentCheckIns(List<DailyCheckInEntry> entries, {required int days}) {
    final DateTime now = DateTime.now();
    final Set<String> validKeys = <String>{};

    for (int i = 0; i < days; i += 1) {
      validKeys.add(DailyCheckInStore.dateKeyFor(now.subtract(Duration(days: i))));
    }

    return entries.where((DailyCheckInEntry entry) => validKeys.contains(entry.dateKey)).length;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Simple insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A quick read on recent patterns so the next good move is easier to spot.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _InsightLine(text: _snapshot.recentEntriesText),
                const SizedBox(height: 10),
                _InsightLine(text: _snapshot.intensityText),
                const SizedBox(height: 10),
                _InsightLine(text: _snapshot.rescueText),
                const SizedBox(height: 10),
                _InsightLine(text: _snapshot.watchText),
                const SizedBox(height: 10),
                _InsightLine(text: _snapshot.checkInText),
              ],
            ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _InsightsSnapshot {
  const _InsightsSnapshot({
    required this.recentEntriesText,
    required this.intensityText,
    required this.rescueText,
    required this.watchText,
    required this.checkInText,
  });

  const _InsightsSnapshot.empty()
      : recentEntriesText = 'Recent entries: none yet.',
        intensityText = 'Intensity trend: no recent entries yet.',
        rescueText = 'Rescue follow-through: none logged yet.',
        watchText = 'Watch pattern: no triggers or risky times saved yet.',
        checkInText = 'Daily contact: no recent check-ins yet.';

  final String recentEntriesText;
  final String intensityText;
  final String rescueText;
  final String watchText;
  final String checkInText;
}
