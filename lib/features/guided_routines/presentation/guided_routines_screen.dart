// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: guided_routines_screen.dart
// Purpose: Library of repeatable guided recovery routines.
// Notes: BW-87B4B shows real saved progress without streak pressure.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../data/recovery_routine_progress_store.dart';
import '../domain/recovery_routine.dart';
import '../domain/recovery_routine_catalog.dart';
import '../domain/recovery_routine_progress.dart';
import 'guided_routine_player_screen.dart';

class GuidedRoutinesScreen extends StatefulWidget {
  const GuidedRoutinesScreen({
    super.key,
    this.onActionRequested,
  });

  final ValueChanged<RoutineActionTarget>? onActionRequested;

  @override
  State<GuidedRoutinesScreen> createState() =>
      _GuidedRoutinesScreenState();
}

class _GuidedRoutinesScreenState
    extends State<GuidedRoutinesScreen> {
  RecoveryMode _mode = RecoveryMode.secular;

  Map<String, RecoveryRoutineProgress> _progress =
      <String, RecoveryRoutineProgress>{};

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    RecoveryModeStore.changes.addListener(
      _handleRecoveryModeChanged,
    );
    _loadRoutines();
  }

  @override
  void dispose() {
    RecoveryModeStore.changes.removeListener(
      _handleRecoveryModeChanged,
    );
    super.dispose();
  }

  void _handleRecoveryModeChanged() {
    _loadRoutines(showSpinner: false);
  }

  Future<void> _loadRoutines({
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

      final Map<String, RecoveryRoutineProgress>
          progress =
          await RecoveryRoutineProgressStore.loadAll();

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
            'BreakWave could not load your guided routines. '
            'Saved routine progress was not changed.';
      });
    }
  }

  Future<void> _openRoutine(
    RecoveryRoutine routine,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GuidedRoutinePlayerScreen(
          routine: routine,
          onActionRequested: widget.onActionRequested,
        ),
      ),
    );

    if (!mounted) return;

    await _loadRoutines(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<RecoveryRoutine> routines =
        RecoveryRoutineCatalog.forMode(_mode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided routines'),
        actions: <Widget>[
          IconButton(
            onPressed: _loading
                ? null
                : () => _loadRoutines(
                      showSpinner: false,
                    ),
            tooltip: 'Refresh guided routines',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(
          context,
          routines,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<RecoveryRoutine> routines,
  ) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _RoutineSurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Routines unavailable',
                ),
                const SizedBox(height: 10),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loadRoutines,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final int completedRuns = _progress.values.fold<int>(
      0,
      (
        int total,
        RecoveryRoutineProgress progress,
      ) =>
          total + progress.completionCount,
    );

    return RefreshIndicator(
      onRefresh: () =>
          _loadRoutines(showSpinner: false),
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
          _RoutineSurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Practice the next right move',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose the routine that matches the moment. '
                  'BreakWave saves each completed step so you '
                  'can pause and resume without starting over.',
                ),
                const SizedBox(height: 12),
                Text(
                  _mode == RecoveryMode.christian
                      ? 'Christian recovery wording is active.'
                      : 'Secular recovery wording is active.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (completedRuns > 0) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    '$completedRuns completed '
                    '${completedRuns == 1 ? 'routine run' : 'routine runs'} '
                    'saved on this device.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _RoutineSurface(
            child: Text(
              'There are no streak penalties here. A paused '
              'routine remains available whenever you are '
              'ready to continue.',
            ),
          ),
          const SizedBox(height: 16),
          for (
            int index = 0;
            index < routines.length;
            index += 1
          ) ...<Widget>[
            _RoutineLibraryCard(
              routine: routines[index],
              progress:
                  _progress[routines[index].id],
              onOpen: () =>
                  _openRoutine(routines[index]),
            ),
            if (index != routines.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _RoutineLibraryCard extends StatelessWidget {
  const _RoutineLibraryCard({
    required this.routine,
    required this.progress,
    required this.onOpen,
  });

  final RecoveryRoutine routine;
  final RecoveryRoutineProgress? progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final RecoveryRoutineProgress? saved = progress;

    final bool isComplete =
        saved?.isComplete ?? false;

    final bool isStarted =
        saved?.isStarted ?? false;

    final int completedSteps =
        saved?.completedStepIds.length ?? 0;

    final int completionCount =
        saved?.completionCount ?? 0;

    final double fraction = saved?.fractionFor(
          routine.steps.length,
        ) ??
        0;

    final String stateLabel;
    final String buttonLabel;
    final IconData stateIcon;

    if (isComplete) {
      stateLabel =
          'Completed • $completionCount '
          '${completionCount == 1 ? 'run' : 'runs'}';
      buttonLabel = 'View completed routine';
      stateIcon = Icons.check_circle_outline;
    } else if (isStarted) {
      stateLabel =
          '$completedSteps of ${routine.steps.length} '
          'steps completed';
      buttonLabel = 'Resume routine';
      stateIcon = Icons.play_circle_outline;
    } else {
      stateLabel = 'Not started';
      buttonLabel = 'Start routine';
      stateIcon = Icons.flag_outlined;
    }

    final ThemeData theme = Theme.of(context);

    return _RoutineSurface(
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
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  routine.title,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(routine.summary),
          const SizedBox(height: 12),
          Text(
            'Best used: ${routine.whenToUse}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '${routine.estimatedMinutes} minutes • '
            '${routine.steps.length} steps',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 8),
          Text(
            stateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
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

class _RoutineSurface extends StatelessWidget {
  const _RoutineSurface({
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
        color: colorScheme.surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
