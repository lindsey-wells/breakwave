// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_journey_player_screen.dart
// Purpose: One-step-at-a-time Christian journey player.
// Notes: BW-87B5B1 saves progress after every completed step.
// Notes: Restarting preserves prior completion history.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/christian_journey_progress_store.dart';
import '../domain/christian_journey_progress.dart';
import '../domain/christian_recovery_journey.dart';

class ChristianJourneyPlayerScreen
    extends StatefulWidget {
  const ChristianJourneyPlayerScreen({
    super.key,
    required this.journey,
    this.onActionRequested,
  });

  final ChristianRecoveryJourney journey;

  final ValueChanged<ChristianJourneyActionTarget>?
      onActionRequested;

  @override
  State<ChristianJourneyPlayerScreen>
      createState() =>
          _ChristianJourneyPlayerScreenState();
}

class _ChristianJourneyPlayerScreenState
    extends State<ChristianJourneyPlayerScreen> {
  ChristianJourneyProgress? _progress;

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
      final ChristianJourneyProgress? saved =
          await ChristianJourneyProgressStore
              .loadFor(
        widget.journey.id,
      );

      if (!mounted) return;

      setState(() {
        _progress = saved ??
            ChristianJourneyProgress.emptyFor(
              widget.journey.id,
            );

        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            'BreakWave could not load this journey. '
            'Saved progress was not changed.';
      });
    }
  }

  Future<void> _startJourney() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final ChristianJourneyProgress started =
          (_progress ??
                  ChristianJourneyProgress
                      .emptyFor(
                    widget.journey.id,
                  ))
              .begin(DateTime.now());

      await ChristianJourneyProgressStore
          .saveProgress(started);

      if (!mounted) return;

      setState(() {
        _progress = started;
        _saving = false;
        _statusMessage =
            'Journey started. Progress will save '
            'after every completed step.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not start this journey. '
            'Try again when ready.';
      });
    }
  }

  Future<void> _completeCurrentStep() async {
    if (_saving) return;

    final ChristianJourneyProgress progress =
        _progress ??
            ChristianJourneyProgress.emptyFor(
              widget.journey.id,
            );

    if (progress.isComplete ||
        widget.journey.steps.isEmpty) {
      return;
    }

    final int index =
        progress.currentStepIndex
            .clamp(
              0,
              widget.journey.steps.length - 1,
            )
            .toInt();

    final ChristianJourneyStep step =
        widget.journey.steps[index];

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final ChristianJourneyProgress updated =
          progress.completeCurrentStep(
        stepId: step.id,
        totalSteps:
            widget.journey.steps.length,
        now: DateTime.now(),
      );

      await ChristianJourneyProgressStore
          .saveProgress(updated);

      if (!mounted) return;

      setState(() {
        _progress = updated;
        _saving = false;

        _statusMessage = updated.isComplete
            ? 'Journey completed and saved on this device.'
            : 'Step completed. Your progress is saved.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not save this step. '
            'The journey remains open.';
      });
    }
  }

  Future<void> _restartJourney() async {
    if (_saving) return;

    final bool? restart =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Start this journey again?',
          ),
          content: const Text(
            'The current run will return to step one. '
            'Earlier completion history will remain saved.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(true),
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
      final ChristianJourneyProgress restarted =
          (_progress ??
                  ChristianJourneyProgress
                      .emptyFor(
                    widget.journey.id,
                  ))
              .restart(DateTime.now());

      await ChristianJourneyProgressStore
          .saveProgress(restarted);

      if (!mounted) return;

      setState(() {
        _progress = restarted;
        _saving = false;
        _statusMessage =
            'New journey run started. '
            'Earlier completions are still saved.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not restart this journey.';
      });
    }
  }

  void _requestAction(
    ChristianJourneyActionTarget target,
  ) {
    widget.onActionRequested?.call(target);
  }

  String _formatTimestamp(String raw) {
    final DateTime? parsed =
        DateTime.tryParse(raw);

    if (parsed == null) {
      return 'Completion saved';
    }

    final DateTime local =
        parsed.toLocal();

    final String month =
        local.month
            .toString()
            .padLeft(2, '0');

    final String day =
        local.day
            .toString()
            .padLeft(2, '0');

    return 'Last completed '
        '$month/$day/${local.year}';
  }

  String _stepKindLabel(
    ChristianJourneyStepKind kind,
  ) {
    switch (kind) {
      case ChristianJourneyStepKind.scripture:
        return 'Scripture';
      case ChristianJourneyStepKind.context:
        return 'Context';
      case ChristianJourneyStepKind.reflection:
        return 'Reflection';
      case ChristianJourneyStepKind.action:
        return 'Action';
      case ChristianJourneyStepKind.prayer:
        return 'Prayer';
    }
  }

  IconData _stepKindIcon(
    ChristianJourneyStepKind kind,
  ) {
    switch (kind) {
      case ChristianJourneyStepKind.scripture:
        return Icons.menu_book_outlined;
      case ChristianJourneyStepKind.context:
        return Icons.lightbulb_outline;
      case ChristianJourneyStepKind.reflection:
        return Icons.psychology_outlined;
      case ChristianJourneyStepKind.action:
        return Icons.directions_walk_outlined;
      case ChristianJourneyStepKind.prayer:
        return Icons.favorite_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journey.title),
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
                  'Journey unavailable',
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

    final ChristianJourneyProgress progress =
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
              _SectionTitle(
                widget.journey.title,
              ),
              const SizedBox(height: 10),
              Text(widget.journey.summary),
              const SizedBox(height: 12),
              Text(
                '${widget.journey.estimatedMinutes} minutes • '
                '${widget.journey.steps.length} steps',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Helpful when: '
                '${widget.journey.whenToUse}',
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
                    fontWeight:
                        FontWeight.w800,
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
                'What this journey includes',
              ),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index <
                    widget.journey.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title: widget
                      .journey
                      .steps[index]
                      .title,
                  kindLabel: _stepKindLabel(
                    widget
                        .journey
                        .steps[index]
                        .kind,
                  ),
                  isCurrent: false,
                  isCompleted: false,
                ),
                if (index !=
                    widget.journey.steps.length - 1)
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
                _saving ? null : _startJourney,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                _saving
                    ? 'Starting...'
                    : 'Start journey',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(
    BuildContext context,
    ChristianJourneyProgress progress,
  ) {
    final int currentIndex =
        progress.currentStepIndex
            .clamp(
              0,
              widget.journey.steps.length - 1,
            )
            .toInt();

    final ChristianJourneyStep currentStep =
        widget.journey.steps[currentIndex];

    final double fraction =
        progress.fractionFor(
      widget.journey.steps.length,
    );

    return Column(
      children: <Widget>[
        _PlayerSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    _stepKindIcon(
                      currentStep.kind,
                    ),
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _stepKindLabel(
                      currentStep.kind,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Step ${currentIndex + 1} of '
                    '${widget.journey.steps.length}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                        ),
                  ),
                ],
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
              if (currentStep
                  .hasScriptureReference) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Text(
                    currentStep
                        .scriptureReference,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                currentStep.body,
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
                    onPressed: () =>
                        _requestAction(
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
                                  widget
                                          .journey
                                          .steps
                                          .length -
                                      1
                              ? 'Complete journey'
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
              const _SectionTitle(
                'Journey path',
              ),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index <
                    widget.journey.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title: widget
                      .journey
                      .steps[index]
                      .title,
                  kindLabel: _stepKindLabel(
                    widget
                        .journey
                        .steps[index]
                        .kind,
                  ),
                  isCurrent:
                      index == currentIndex,
                  isCompleted: progress
                      .completedStepIds
                      .contains(
                        widget
                            .journey
                            .steps[index]
                            .id,
                      ),
                ),
                if (index !=
                    widget.journey.steps.length - 1)
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
    ChristianJourneyProgress progress,
  ) {
    final String lastCompletion =
        progress.completionHistoryIso.isEmpty
            ? ''
            : progress
                .completionHistoryIso
                .last;

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
                'Journey completed',
              ),
              const SizedBox(height: 10),
              const Text(
                'You completed Scripture, context, '
                'reflection, action, and prayer in this '
                'journey. The completion is saved locally.',
              ),
              const SizedBox(height: 12),
              Text(
                '${progress.completionCount} completed '
                '${progress.completionCount == 1 ? 'run' : 'runs'}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
              ),
              if (lastCompletion.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  _formatTimestamp(
                    lastCompletion,
                  ),
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
                'Journey path',
              ),
              const SizedBox(height: 12),
              for (
                int index = 0;
                index <
                    widget.journey.steps.length;
                index += 1
              ) ...<Widget>[
                _PathRow(
                  number: index + 1,
                  title: widget
                      .journey
                      .steps[index]
                      .title,
                  kindLabel: _stepKindLabel(
                    widget
                        .journey
                        .steps[index]
                        .kind,
                  ),
                  isCurrent: false,
                  isCompleted: true,
                ),
                if (index !=
                    widget.journey.steps.length - 1)
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
                _saving ? null : _restartJourney,
            icon: const Icon(Icons.replay),
            label: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Text(
                _saving
                    ? 'Restarting...'
                    : 'Start journey again',
              ),
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
    required this.kindLabel,
    required this.isCurrent,
    required this.isCompleted,
  });

  final int number;
  final String title;
  final String kindLabel;
  final bool isCurrent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colors =
        theme.colorScheme;

    final Color background =
        isCompleted
            ? colors.primaryContainer
            : isCurrent
                ? colors.secondaryContainer
                : colors
                    .surfaceContainerHighest;

    final IconData icon =
        isCompleted
            ? Icons.check
            : isCurrent
                ? Icons.play_arrow
                : Icons.circle_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 17,
            backgroundColor:
                colors.surface,
            child: isCompleted || isCurrent
                ? Icon(
                    icon,
                    size: 19,
                  )
                : Text(
                    number.toString(),
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(kindLabel),
              ],
            ),
          ),
        ],
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
