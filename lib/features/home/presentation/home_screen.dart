// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: BW-02 home dashboard structure for BreakWave.
// Notes: BW-24 privacy-aware Home surfaces.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/privacy/privacy_settings.dart';
import '../../../core/privacy/privacy_settings_store.dart';
import '../../../core/widget/home_widget_sync.dart';
import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/section_header.dart';
import '../../checkin/presentation/daily_check_in_card.dart';
import '../../insights/presentation/simple_insights_card.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import '../../reasons/presentation/reasons_focus_card.dart';
import '../../triggers/presentation/triggers_watch_card.dart';
import 'widgets/bedtime_danger_mode_card.dart';
import 'widgets/daily_encouragement_card.dart';
import 'widgets/fast_urge_entry_card.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/latest_logged_moment_card.dart';
import 'widgets/recovery_cycle_preview_card.dart';
import 'widgets/recovery_snapshot_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenLog;

  const HomeScreen({
    super.key,
    required this.onOpenRescue,
    required this.onOpenLog,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<int> _privacyNotifier;

  @override
  void initState() {
    super.initState();
    _privacyNotifier = PrivacySettingsStore.changes;
    _privacyNotifier.addListener(_handlePrivacyChanged);
    BreakWaveHomeWidgetSync.sync();
  }

  @override
  void dispose() {
    _privacyNotifier.removeListener(_handlePrivacyChanged);
    super.dispose();
  }

  void _handlePrivacyChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<_HomeSummaryData> _loadSummary() async {
    final LogRepository repository = const LogRepository();
    final List<LogEntry> entries = await repository.loadEntries();
    final PrivacySettings privacy = await PrivacySettingsStore.load();

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
      privacy: privacy,
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
          builder:
              (BuildContext context, AsyncSnapshot<_HomeSummaryData> snapshot) {
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
                              'Calm, steady support for the next good move when the wave starts rising.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FastUrgeEntryCard(
                        onOpenRescue: widget.onOpenRescue,
                      ),
                      const SizedBox(height: 16),
                      BedtimeDangerModeCard(
                        onOpenRescue: widget.onOpenRescue,
                      ),
                      const SizedBox(height: 16),
                      const DailyCheckInCard(),
                      if (!summary.privacy.hideHomeInsights) ...<Widget>[
                        const SizedBox(height: 16),
                        const SimpleInsightsCard(),
                      ],
                      const SizedBox(height: 16),
                      const ReasonsFocusCard(),
                      const SizedBox(height: 16),
                      const TriggersWatchCard(),
                      const SizedBox(height: 16),
                      const SectionHeader(
                        eyebrow: 'Current snapshot',
                        title: 'See where you are right now',
                      ),
                      RecoverySnapshotCard(
                        totalEntries: summary.totalEntries,
                        urgeCount: summary.urgeCount,
                        slipCount: summary.slipCount,
                        victoryCount: summary.victoryCount,
                      ),
                      if (!summary.privacy.hideLatestLoggedMoment) ...<Widget>[
                        const SizedBox(height: 16),
                        LatestLoggedMomentCard(
                          entry: summary.latestEntry,
                        ),
                      ],
                      const SizedBox(height: 16),
                      const SectionHeader(
                        eyebrow: 'Act now',
                        title: 'Use the fastest next step',
                      ),
                      HomeHeroCard(
                        onOpenRescue: widget.onOpenRescue,
                        onOpenLog: widget.onOpenLog,
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(
                        eyebrow: 'Pattern awareness',
                        title: 'Learn what keeps the wave going',
                      ),
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
  final PrivacySettings privacy;

  const _HomeSummaryData({
    required this.totalEntries,
    required this.urgeCount,
    required this.slipCount,
    required this.victoryCount,
    required this.latestEntry,
    required this.privacy,
  });

  const _HomeSummaryData.empty()
      : totalEntries = 0,
        urgeCount = 0,
        slipCount = 0,
        victoryCount = 0,
        latestEntry = null,
        privacy = PrivacySettings.defaults;
}
