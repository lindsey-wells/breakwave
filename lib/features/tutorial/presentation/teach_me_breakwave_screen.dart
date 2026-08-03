// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: teach_me_breakwave_screen.dart
// Purpose: Compact, replayable Teach Me BreakWave tutorial route.
// Notes: BW-ONBOARD-01B1 is informational and never starts Rescue actions.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../../core/tutorial/breakwave_tutorial_state.dart';
import '../../../core/tutorial/breakwave_tutorial_state_store.dart';
import '../../../core/ui/wave_surface.dart';
import '../domain/breakwave_tutorial_step.dart';

class TeachMeBreakWaveScreen extends StatefulWidget {
  const TeachMeBreakWaveScreen({super.key});

  @override
  State<TeachMeBreakWaveScreen> createState() =>
      _TeachMeBreakWaveScreenState();
}

class _TeachMeBreakWaveScreenState extends State<TeachMeBreakWaveScreen> {
  bool _loading = true;
  bool _busy = false;
  bool _failed = false;
  int _step = 0;
  RecoveryMode _mode = RecoveryMode.secular;
  List<BreakWaveTutorialStep> _steps = const <BreakWaveTutorialStep>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final RecoveryMode mode =
          await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;
      final BreakWaveTutorialState state =
          await BreakWaveTutorialStateStore.load();
      final List<BreakWaveTutorialStep> steps =
          BreakWaveTutorialCatalog.build(mode);

      if (!mounted) return;

      setState(() {
        _mode = mode;
        _steps = steps;
        _step = state.completed ? 0 : state.currentStep;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _moveTo(int step) async {
    if (_busy || _steps.isEmpty) return;

    setState(() {
      _busy = true;
    });

    try {
      await BreakWaveTutorialStateStore.saveProgress(step: step);
      if (!mounted) return;

      setState(() {
        _step = step;
      });
    } catch (_) {
      if (!mounted) return;
      _showError('BreakWave could not save tutorial progress yet.');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _next() async {
    if (_step >= _steps.length - 1) {
      await _finish();
      return;
    }

    await _moveTo(_step + 1);
  }

  Future<void> _back() async {
    if (_step == 0) return;
    await _moveTo(_step - 1);
  }

  Future<void> _finish() async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    try {
      await BreakWaveTutorialStateStore.complete();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      _showError('BreakWave could not mark the tutorial complete yet.');
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exit() async {
    if (_busy) return;

    try {
      if (_steps.isNotEmpty) {
        await BreakWaveTutorialStateStore.saveProgress(step: _step);
      }
    } catch (_) {
      // Exiting the tutorial must remain available even if local state fails.
    }

    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<bool> _handleSystemBack() async {
    if (_busy) return false;

    if (_step > 0) {
      await _back();
      return false;
    }

    return true;
  }

  void _showError(String message) {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  IconData _iconFor(BreakWaveTutorialTopic topic) {
    switch (topic) {
      case BreakWaveTutorialTopic.overview:
        return Icons.water_outlined;
      case BreakWaveTutorialTopic.rescue:
        return Icons.sos_outlined;
      case BreakWaveTutorialTopic.home:
        return Icons.home_outlined;
      case BreakWaveTutorialTopic.log:
        return Icons.edit_note_outlined;
      case BreakWaveTutorialTopic.recoveryTools:
        return Icons.route_outlined;
      case BreakWaveTutorialTopic.privacyAndAccess:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teach Me BreakWave'),
          actions: <Widget>[
            TextButton(
              onPressed: _busy ? null : _exit,
              child: const Text('Exit tour'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_failed || _steps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'The tutorial could not open right now. Your recovery data was not changed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _exit,
                child: const Text('Return to Support'),
              ),
            ],
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final BreakWaveTutorialStep current = _steps[_step];
    final double progress = (_step + 1) / _steps.length;

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Part ${_step + 1} of ${_steps.length}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _mode == RecoveryMode.christian
                          ? 'Christian mode'
                          : 'Secular mode',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const Key('teach-me-breakwave-content'),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: <Widget>[
                WaveSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconFor(current.topic),
                          size: 31,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        current.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        current.summary,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      for (final String point in current.points)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(point)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const Key('teach-me-breakwave-back'),
                    onPressed: _busy || _step == 0 ? null : _back,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Back'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('teach-me-breakwave-next'),
                    onPressed: _busy ? null : _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _step == _steps.length - 1
                            ? 'Finish tour'
                            : 'Next',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
