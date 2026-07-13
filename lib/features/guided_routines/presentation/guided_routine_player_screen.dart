// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: guided_routine_player_screen.dart
// Purpose: One-step-at-a-time guided routine player.
// Notes: BW-87B4B saves progress after every completed step.
// Notes: Restarting preserves prior completion history.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/recovery_routine_progress_store.dart';
import '../domain/recovery_routine.dart';
import '../domain/recovery_routine_progress.dart';

class GuidedRoutinePlayerScreen
    extends StatefulWidget {
  const GuidedRoutinePlayerScreen({
    super.key,
    required this.routine,
    this.onActionRequested,
  });

  final RecoveryRoutine routine;
  final ValueChanged<RoutineActionTarget>?
      onActionRequested;

  @override
  State<GuidedRoutinePlayerScreen> createState() =>
      _GuidedRoutinePlayerScreenState();
}

class _GuidedRoutinePlayerScreenState
    extends State<GuidedRoutinePlayerScreen> {
  RecoveryRoutineProgress? _progress;

  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final RecoveryRoutineProgress? saved =
          await RecoveryRoutineProgressStore.loadFor(
        widget.routine.id,
      );

      if (!mounted) return;

      setState(() {
        _progress = saved ??
            RecoveryRoutineProgress.emptyFor(
              widget.routine.id,
            );
        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'BreakWave could not load this routine. '
            'Saved progress was not changed.';
      });
    }
  }

  Future<void> _startRoutine() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final RecoveryRoutineProgress started =
          (_progress ??
                  RecoveryRoutineProgress.emptyFor(
                    widget.routine.id,
                  ))
              .begin(DateTime.now());

      await RecoveryRoutineProgressStore
          .saveProgress(started);

      if (!mounted) return;

      setState(() {
        _progress = started;
        _saving = false;
        _statusMessage =
            'Routine started. Progress will save '
            'after every completed step.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not start this routine. '
            'Try again when ready.';
      });
    }
  }

  Future<void> _completeCurrentStep() async {
    if (_saving) return;

    final RecoveryRoutineProgress progress =
        _progress ??
            RecoveryRoutineProgress.emptyFor(
              widget.routine.id,
            );

    if (progress.isComplete ||
        widget.routine.steps.isEmpty) {
      return;
    }

    final int index = progress.currentStepIndex
        .clamp(
          0,
          widget.routine.steps.length - 1,
        );

    final RecoveryRoutineStep step =
        widget.routine.steps[index];

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final RecoveryRoutineProgress updated =
          progress.completeCurrentStep(
        stepId: step.id,
        totalSteps: widget.routine.steps.length,
        now: DateTime.now(),
      );

      await RecoveryRoutineProgressStore
          .saveProgress(updated);

      if (!mounted) return;

      setState(() {
        _progress = updated;
        _saving = false;
        _statusMessage = updated.isComplete
            ? 'Routine completed and saved on this device.'
            : 'Step completed. Your progress is saved.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not save this step. '
            'The routine remains open.';
      });
    }
  }

  Future<void> _restartRoutine() async {
    if (_saving) return;

    final bool? restart = await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Start this routine again?',
          ),
          content: const Text(
            'The current run will return to step one. '
            'Earlier completion history will remain saved.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Start again'),
            ),
          ],
        );
      },
    );

    if (restart != true || !mounted) return;

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final RecoveryRoutineProgress restarted =
          (_progress ??
                  RecoveryRoutineProgress.emptyFor(
                    widget.routine.id,
                  ))
              .restart(DateTime.now());

      await RecoveryRoutineProgressStore
          .saveProgress(restarted);

      if (!mounted) return;

      setState(() {
        _progress = restarted;
        _saving = false;
        _statusMessage =
            'New routine run started. '
            'Earlier completions are still saved.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not restart this routine.';
      });
    }
  }

  void _requestAction(
    RoutineActionTarget target,
  ) {
    widget.onActionRequested?.call(target);
  }

  String _formatTimestamp(String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return 'Completion saved';
    }

    final DateTime local = parsed.toLocal();

    final String month =
        local.month.toString().padLeft(2, '0');

    final String day =
        local.day.toString().padLeft(2, '0');

    return 'Last completed '
        '$month/$day/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.title),
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
          _PlayerSurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Routine unavailable',
                ),
                const SizedBox(height: 10),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _errorMessage = null;
                      });
                      _loadProgress();
                    },
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final RecoveryRoutineProgress progress =
        _progress!;

    final bool notStarted =
        !progress.isStarted &&
            !progress.isComplete &&
            progress.completedStepIds.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        120,
      ),
      children: <Widget>[
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _SectionTitle(widget.routine.title),
              const SizedBox(height: 10),
              Text(widget.routine.summary),
              const SizedBox(height: 12),
              Text(
                '${widget.routine.estimatedMinutes} minutes • '
                '${widget.routine.steps.length} steps',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Helpful when: ${widget.routine.whenToUse}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (notStarted)
          _buildStartState(context)
        else if (progress.isComplete)
          _buildCompletionState(
            context,
            progress,
          )
        else
          _buildActiveState(
            context,
            progress,
          ),
        if (_statusMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          _PlayerSurface(
            child: Text(
              _statusMessage!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStartState(
    BuildContext context,
  ) {
    return Column(
      children: <Widget>[
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'What this routine includes',
              ),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index < widget.routine.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title:
                      widget.routine.steps[index].title,
                  isCurrent: false,
                  isCompleted: false,
                ),
                if (index !=
                    widget.routine.steps.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                _saving ? null : _startRoutine,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                _saving
                    ? 'Starting...'
                    : 'Start routine',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(
    BuildContext context,
    RecoveryRoutineProgress progress,
  ) {
    final int currentIndex =
        progress.currentStepIndex.clamp(
      0,
      widget.routine.steps.length - 1,
    );

    final RecoveryRoutineStep currentStep =
        widget.routine.steps[currentIndex];

    final double fraction =
        progress.fractionFor(
      widget.routine.steps.length,
    );

    return Column(
      children: <Widget>[
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Step ${currentIndex + 1} of '
                '${widget.routine.steps.length}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: fraction,
                minHeight: 9,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              const SizedBox(height: 18),
              _SectionTitle(currentStep.title),
              const SizedBox(height: 12),
              Text(
                currentStep.instruction,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),
              if (currentStep.hasAction &&
                  widget.onActionRequested !=
                      null) ...<Widget>[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _requestAction(
                      currentStep.actionTarget!,
                    ),
                    icon: const Icon(
                      Icons.open_in_new,
                    ),
                    label: Text(
                      currentStep.actionLabel,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving
                      ? null
                      : _completeCurrentStep,
                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),
                  label: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      _saving
                          ? 'Saving step...'
                          : currentIndex ==
                                  widget.routine
                                          .steps.length -
                                      1
                              ? 'Complete routine'
                              : 'Mark step complete',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle('Routine path'),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index < widget.routine.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title:
                      widget.routine.steps[index].title,
                  isCurrent:
                      index == currentIndex,
                  isCompleted: progress
                      .completedStepIds
                      .contains(
                        widget.routine
                            .steps[index]
                            .id,
                      ),
                ),
                if (index !=
                    widget.routine.steps.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionState(
    BuildContext context,
    RecoveryRoutineProgress progress,
  ) {
    final String lastCompletion =
        progress.completionHistoryIso.isEmpty
            ? ''
            : progress.completionHistoryIso.last;

    return Column(
      children: <Widget>[
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 42,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(height: 12),
              const _SectionTitle(
                'Routine completed',
              ),
              const SizedBox(height: 10),
              const Text(
                'You completed each step in this run. '
                'The completion is saved locally and the '
                'routine remains available whenever it '
                'would help again.',
              ),
              const SizedBox(height: 12),
              Text(
                '${progress.completionCount} completed '
                '${progress.completionCount == 1 ? 'run' : 'runs'}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (lastCompletion.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  _formatTimestamp(lastCompletion),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Completed steps',
              ),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index < widget.routine.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title:
                      widget.routine.steps[index].title,
                  isCurrent: false,
                  isCompleted: true,
                ),
                if (index !=
                    widget.routine.steps.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed:
                _saving ? null : _restartRoutine,
            icon: const Icon(Icons.replay),
            label: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Text('Start routine again'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.number,
    required this.title,
    required this.isCurrent,
    required this.isCompleted,
  });

  final int number;
  final String title;
  final bool isCurrent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final IconData icon = isCompleted
        ? Icons.check_circle_outline
        : isCurrent
            ? Icons.radio_button_checked
            : Icons.circle_outlined;

    final Color color =
        isCompleted || isCurrent
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),
      padding: EdgeInsets.all(
        isCurrent || isCompleted ? 10 : 0,
      ),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primary
                .withOpacity(0.14)
            : isCompleted
                ? theme.colorScheme.primary
                    .withOpacity(0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$number. $title',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                color: color,
                fontWeight:
                    isCurrent || isCompleted
                        ? FontWeight.w800
                        : FontWeight.w500,
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

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({
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
