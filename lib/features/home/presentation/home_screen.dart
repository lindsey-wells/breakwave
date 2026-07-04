// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_screen.dart
// Purpose: BW-57 home dashboard cleanup for BreakWave.
// Notes: Reduces empty-state clutter and keeps Rescue/action paths obvious.
// Notes: BW-78A simplifies Home for launch and moves the user's why higher.
// Notes: BW-81B adds clear Start here actions for check-in, Rescue, and Log.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/privacy/privacy_settings.dart';
import '../../../core/privacy/privacy_settings_store.dart';
import '../../../core/widget/home_widget_sync.dart';
import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/breakwave_app_bar.dart';
import '../../checkin/presentation/daily_check_in_card.dart';
import '../../insights/presentation/simple_insights_card.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import '../../reasons/presentation/reasons_focus_card.dart';
import '../../triggers/presentation/triggers_watch_card.dart';
import 'widgets/bedtime_danger_mode_card.dart';
import 'widgets/daily_encouragement_card.dart';
import 'widgets/fast_urge_entry_card.dart';
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
  final GlobalKey _checkInSectionKey = GlobalKey();

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


  void _scrollToDailyCheckIn() {
    final BuildContext? checkInContext = _checkInSectionKey.currentContext;
    if (checkInContext == null) return;

    Scrollable.ensureVisible(
      checkInContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
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
      appBar: const BreakWaveAppBar(sectionTitle: 'Home'),
      body: SafeArea(
        child: FutureBuilder<_HomeSummaryData>(
          future: _loadSummary(),
          builder:
              (BuildContext context, AsyncSnapshot<_HomeSummaryData> snapshot) {
            final _HomeSummaryData summary =
                snapshot.data ?? const _HomeSummaryData.empty();
            final bool hasRecoveryData = summary.totalEntries > 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 150),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        WaveSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Start here',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Check in each day. If the wave is rising, open Rescue. Afterward, use Log to honestly record what happened.',
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  FilledButton.tonalIcon(
                                    onPressed: _scrollToDailyCheckIn,
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('Check in'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: widget.onOpenRescue,
                                    icon: const Icon(Icons.waves),
                                    label: const Text('Open Rescue'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: widget.onOpenLog,
                                    icon: const Icon(Icons.edit_note),
                                    label: const Text('Open Log'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      FastUrgeEntryCard(
                        onOpenRescue: widget.onOpenRescue,
                      ),
                      const SizedBox(height: 12),
                      const SectionHeader(
                        eyebrow: 'Your setup',
                        title: 'Your why and risk signals',
                      ),
                      const ReasonsFocusCard(),
                      const SizedBox(height: 12),
                      const TriggersWatchCard(),
                      const SizedBox(height: 16),
                      const DailyEncouragementCard(),
                      const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _checkInSectionKey,
                          child: const SectionHeader(
                            eyebrow: 'Today',
                            title: 'Check in',
                          ),
                        ),
                      const DailyCheckInCard(),
                      const SizedBox(height: 12),
                      BedtimeDangerModeCard(
                        onOpenRescue: widget.onOpenRescue,
                      ),
                      if (hasRecoveryData) ...<Widget>[
                        const SizedBox(height: 20),
                        const SectionHeader(
                          eyebrow: 'Progress',
                          title: 'Your recent pattern',
                        ),
                        RecoverySnapshotCard(
                          totalEntries: summary.totalEntries,
                          urgeCount: summary.urgeCount,
                          slipCount: summary.slipCount,
                          victoryCount: summary.victoryCount,
                          onOpenLog: widget.onOpenLog,
                        ),
                        if (!summary.privacy.hideLatestLoggedMoment) ...<Widget>[
                          const SizedBox(height: 16),
                          LatestLoggedMomentCard(
                            entry: summary.latestEntry,
                          ),
                        ],
                        if (!summary.privacy.hideHomeInsights) ...<Widget>[
                          const SizedBox(height: 16),
                          const SimpleInsightsCard(),
                        ],
                      ],
                      const SizedBox(height: 16),
                      const SectionHeader(
                        eyebrow: 'Pattern awareness',
                        title: 'Learn the pattern',
                      ),
                      const RecoveryCyclePreviewCard(),
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
