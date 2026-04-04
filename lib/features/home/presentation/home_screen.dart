// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: BW-02 home dashboard structure for BreakWave.
// Notes: BW-09 home summary from persisted data.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import '../../../core/ui/wave_surface.dart';
import '../../reasons/presentation/reasons_focus_card.dart';
import 'widgets/daily_encouragement_card.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/latest_logged_moment_card.dart';
import 'widgets/recovery_cycle_preview_card.dart';
import 'widgets/recovery_snapshot_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenLog;

  const HomeScreen({
    super.key,
    required this.onOpenRescue,
    required this.onOpenLog,
  });

  Future<_HomeSummaryData> _loadSummary() async {
    final LogRepository repository = const LogRepository();
    final List<LogEntry> entries = await repository.loadEntries();

    int urgeCount = 0;
    int slipCount = 0;
    int victoryCount = 0;

    for (final LogEntry entry in entries) {
      switch (entry.entryType) {
        case 'Urge':
          urgeCount += 1;
          break;
        case 'Slip':
          slipCount += 1;
          break;
        case 'Victory':
          victoryCount += 1;
          break;
      }
    }

    return _HomeSummaryData(
      totalEntries: entries.length,
      urgeCount: urgeCount,
      slipCount: slipCount,
      victoryCount: victoryCount,
      latestEntry: entries.isEmpty ? null : entries.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakWave'),
      ),
      body: SafeArea(
        child: FutureBuilder<_HomeSummaryData>(
          future: _loadSummary(),
          builder: (BuildContext context, AsyncSnapshot<_HomeSummaryData> snapshot) {
            final _HomeSummaryData summary =
                snapshot.data ?? const _HomeSummaryData.empty();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const WaveSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Home Current',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Steady water, clear direction.',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'BreakWave is designed to feel calm, steady, and blue-led — like a wave you can learn to ride instead of fear.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ReasonsFocusCard(),
                      const SizedBox(height: 16),
                      RecoverySnapshotCard(
                        totalEntries: summary.totalEntries,
                        urgeCount: summary.urgeCount,
                        slipCount: summary.slipCount,
                        victoryCount: summary.victoryCount,
                      ),
                      const SizedBox(height: 16),
                      LatestLoggedMomentCard(
                        entry: summary.latestEntry,
                      ),
                      const SizedBox(height: 16),
                      HomeHeroCard(
                        onOpenRescue: onOpenRescue,
                        onOpenLog: onOpenLog,
                      ),
                      const SizedBox(height: 16),
                      const RecoveryCyclePreviewCard(),
                      const SizedBox(height: 16),
                      const DailyEncouragementCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeSummaryData {
  final int totalEntries;
  final int urgeCount;
  final int slipCount;
  final int victoryCount;
  final LogEntry? latestEntry;

  const _HomeSummaryData({
    required this.totalEntries,
    required this.urgeCount,
    required this.slipCount,
    required this.victoryCount,
    required this.latestEntry,
  });

  const _HomeSummaryData.empty()
      : totalEntries = 0,
        urgeCount = 0,
        slipCount = 0,
        victoryCount = 0,
        latestEntry = null;
}
