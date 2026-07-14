// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_journeys_screen.dart
// Purpose: Christian recovery journey library.
// Notes: BW-87B5B1 shows saved progress without streak pressure.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../data/christian_journey_progress_store.dart';
import '../domain/christian_journey_progress.dart';
import '../domain/christian_recovery_journey.dart';
import '../domain/christian_recovery_journey_catalog.dart';
import 'christian_journey_player_screen.dart';

class ChristianJourneysScreen extends StatefulWidget {
  const ChristianJourneysScreen({
    super.key,
    this.onActionRequested,
  });

  final ValueChanged<ChristianJourneyActionTarget>?
      onActionRequested;

  @override
  State<ChristianJourneysScreen> createState() =>
      _ChristianJourneysScreenState();
}

class _ChristianJourneysScreenState
    extends State<ChristianJourneysScreen> {
  RecoveryMode _mode = RecoveryMode.secular;

  Map<String, ChristianJourneyProgress> _progress =
      <String, ChristianJourneyProgress>{};

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    RecoveryModeStore.changes.addListener(
      _handleRecoveryModeChanged,
    );

    ChristianJourneyProgressStore.changes.addListener(
      _handleProgressChanged,
    );

    _loadJourneys();
  }

  @override
  void dispose() {
    RecoveryModeStore.changes.removeListener(
      _handleRecoveryModeChanged,
    );

    ChristianJourneyProgressStore.changes.removeListener(
      _handleProgressChanged,
    );

    super.dispose();
  }

  void _handleRecoveryModeChanged() {
    _loadJourneys(showSpinner: false);
  }

  void _handleProgressChanged() {
    _loadJourneys(showSpinner: false);
  }

  Future<void> _loadJourneys({
    bool showSpinner = true,
  }) async {
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final RecoveryMode mode =
          await RecoveryModeStore.loadMode() ??
              RecoveryMode.secular;

      final Map<String, ChristianJourneyProgress>
          progress =
          await ChristianJourneyProgressStore.loadAll();

      if (!mounted) return;

      setState(() {
        _mode = mode;
        _progress = progress;
        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'BreakWave could not load your Christian journeys. '
            'Saved journey progress was not changed.';
      });
    }
  }

  Future<void> _openJourney(
    ChristianRecoveryJourney journey,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChristianJourneyPlayerScreen(
          journey: journey,
          onActionRequested: widget.onActionRequested,
        ),
      ),
    );

    if (!mounted) return;

    await _loadJourneys(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Christian recovery journeys',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _loading
                ? null
                : () => _loadJourneys(
                      showSpinner: false,
                    ),
            tooltip: 'Refresh Christian journeys',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _JourneySurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Journeys unavailable',
                ),
                const SizedBox(height: 10),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loadJourneys,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_mode != RecoveryMode.christian) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          120,
        ),
        children: const <Widget>[
          _JourneySurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitle(
                  'Christian mode required',
                ),
                SizedBox(height: 10),
                Text(
                  'These journeys are intentionally Christian '
                  'and include Scripture, prayer, grace, and '
                  'clearly Christian recovery language.',
                ),
                SizedBox(height: 10),
                Text(
                  'Switch BreakWave to the Christian recovery '
                  'path to use the journeys as written.',
                ),
              ],
            ),
          ),
        ],
      );
    }

    final List<ChristianRecoveryJourney> journeys =
        ChristianRecoveryJourneyCatalog.journeys;

    final int completedRuns =
        _progress.values.fold<int>(
      0,
      (
        int total,
        ChristianJourneyProgress progress,
      ) =>
          total + progress.completionCount,
    );

    return RefreshIndicator(
      onRefresh: () =>
          _loadJourneys(showSpinner: false),
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          120,
        ),
        children: <Widget>[
          _JourneySurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Walk through the next faithful step',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Each journey moves through Scripture, '
                  'context, honest reflection, practical action, '
                  'and prayer. Progress saves after every '
                  'completed step.',
                ),
                const SizedBox(height: 12),
                const Text(
                  ChristianRecoveryJourneyCatalog.contentNote,
                ),
                if (completedRuns > 0) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    '$completedRuns completed '
                    '${completedRuns == 1 ? 'journey run' : 'journey runs'} '
                    'saved on this device.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _JourneySurface(
            child: Text(
              'There are no streak penalties here. A paused '
              'journey remains available whenever you are ready '
              'to continue.',
            ),
          ),
          const SizedBox(height: 16),
          for (
            int index = 0;
            index < journeys.length;
            index += 1
          ) ...<Widget>[
            _JourneyLibraryCard(
              journey: journeys[index],
              progress:
                  _progress[journeys[index].id],
              onOpen: () =>
                  _openJourney(journeys[index]),
            ),
            if (index != journeys.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _JourneyLibraryCard extends StatelessWidget {
  const _JourneyLibraryCard({
    required this.journey,
    required this.progress,
    required this.onOpen,
  });

  final ChristianRecoveryJourney journey;
  final ChristianJourneyProgress? progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final ChristianJourneyProgress? saved =
        progress;

    final bool isComplete =
        saved?.isComplete ?? false;

    final bool isStarted =
        saved?.isStarted ?? false;

    final int completedSteps =
        saved?.completedStepIds.length ?? 0;

    final int completionCount =
        saved?.completionCount ?? 0;

    final double fraction =
        saved?.fractionFor(
              journey.steps.length,
            ) ??
            0;

    final String stateLabel;
    final String buttonLabel;
    final IconData stateIcon;

    if (isComplete) {
      stateLabel =
          'Completed • $completionCount '
          '${completionCount == 1 ? 'run' : 'runs'}';

      buttonLabel = 'View completed journey';
      stateIcon = Icons.check_circle_outline;
    } else if (isStarted) {
      stateLabel =
          '$completedSteps of ${journey.steps.length} '
          'steps completed';

      buttonLabel = 'Resume journey';
      stateIcon = Icons.play_circle_outline;
    } else {
      stateLabel = 'Not started';
      buttonLabel = 'Start journey';
      stateIcon = Icons.menu_book_outlined;
    }

    final ThemeData theme =
        Theme.of(context);

    return _JourneySurface(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                stateIcon,
                color:
                    theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  journey.title,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(journey.summary),
          const SizedBox(height: 10),
          Text(
            '${journey.estimatedMinutes} minutes • '
            '${journey.steps.length} steps',
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Helpful when: ${journey.whenToUse}',
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(
                Icons.bookmark_outline,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stateLabel,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          if (isStarted || isComplete) ...<Widget>[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: fraction,
              minHeight: 9,
              borderRadius:
                  BorderRadius.circular(20),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onOpen,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                child: Text(buttonLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneySurface extends StatelessWidget {
  const _JourneySurface({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
