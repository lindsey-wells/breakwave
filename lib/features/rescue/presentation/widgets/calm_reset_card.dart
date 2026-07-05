// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: calm_reset_card.dart
// Purpose: Calm reset guidance card for the BW-03 rescue flow.
// Notes: BW-71A makes Calm Reset interactive.
// Notes: BW-71B guides Calm Reset through three automatic breathing rounds.
// Notes: BW-82D adds a short settle pause after the exhale step.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';

class CalmResetCard extends StatefulWidget {
  const CalmResetCard({super.key});

  @override
  State<CalmResetCard> createState() => _CalmResetCardState();
}

class _CalmResetCardState extends State<CalmResetCard> {
  static const int _targetRounds = 3;
  static const int _postStepPauseSeconds = 2;

  static const List<_ResetStep> _steps = <_ResetStep>[
    _ResetStep(
      label: 'Inhale through the nose for 4 seconds.',
      seconds: 4,
      icon: Icons.looks_one_outlined,
    ),
    _ResetStep(
      label: 'Hold gently for 4 seconds.',
      seconds: 4,
      icon: Icons.looks_two_outlined,
    ),
    _ResetStep(
      label: 'Exhale slowly for 6 seconds.',
      seconds: 6,
      icon: Icons.looks_3_outlined,
    ),
  ];

  Timer? _timer;
  bool _isRunning = false;
  bool _isPostStepPause = false;
  int _activeStep = -1;
  int _remainingSeconds = 0;
  int _completedRounds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startReset() {
    _timer?.cancel();

    setState(() {
      _isRunning = true;
      _isPostStepPause = false;
      _activeStep = 0;
      _remainingSeconds = _steps.first.seconds;
      _completedRounds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset started. Breathe through the steps one round at a time.'),
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds -= 1;
        });
        return;
      }

      if (_activeStep == _steps.length - 1 && !_isPostStepPause) {
        setState(() {
          _isPostStepPause = true;
          _remainingSeconds = _postStepPauseSeconds;
        });
        return;
      }

      final int nextStep = _activeStep + 1;

      if (nextStep < _steps.length) {
        setState(() {
          _isPostStepPause = false;
          _activeStep = nextStep;
          _remainingSeconds = _steps[nextStep].seconds;
        });
        return;
      }

      final int nextRoundCount = _completedRounds + 1;

      if (nextRoundCount >= _targetRounds) {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _activeStep = -1;
          _remainingSeconds = 0;
          _completedRounds = nextRoundCount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Three calm reset rounds completed. Choose the next right action.'),
          ),
        );
        return;
      }

      setState(() {
        _completedRounds = nextRoundCount;
        _activeStep = 0;
        _remainingSeconds = _steps.first.seconds;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('One calm reset round completed. Starting the next round.'),
        ),
      );
    });
  }

  void _stopReset() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isPostStepPause = false;
      _activeStep = -1;
      _remainingSeconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calm reset stopped. Choose the next right action when ready.'),
      ),
    );
  }

  bool _isCompleted(int index) {
    if (!_isRunning) {
      return _completedRounds >= _targetRounds;
    }

    return index < _activeStep;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Calm Reset',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Reset the body first. A slower body gives you a better next decision.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_isRunning) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                _isPostStepPause
                    ? 'Round ${_completedRounds + 1} of $_targetRounds • Let it settle • $_remainingSeconds seconds'
                    : 'Round ${_completedRounds + 1} of $_targetRounds • ${_steps[_activeStep].verb} • $_remainingSeconds seconds',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            if (_completedRounds > 0 && !_isRunning) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                'Completed $_completedRounds of $_targetRounds calm reset rounds.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (int index = 0; index < _steps.length; index++) ...<Widget>[
              _StepRow(
                icon: _steps[index].icon,
                text: _steps[index].label,
                isActive: _activeStep == index,
                isCompleted: _isCompleted(index),
              ),
              if (index != _steps.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isRunning ? _stopReset : _startReset,
              icon: const Icon(Icons.self_improvement_outlined),
              label: Text(_isRunning ? 'Stop reset' : 'Start reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetStep {
  const _ResetStep({
    required this.label,
    required this.seconds,
    required this.icon,
  });

  final String label;
  final int seconds;
  final IconData icon;

  String get verb {
    if (label.startsWith('Inhale')) return 'Inhale';
    if (label.startsWith('Hold')) return 'Hold';
    return 'Exhale';
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final bool isCompleted;

  const _StepRow({
    required this.icon,
    required this.text,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color accentColor = isCompleted
        ? theme.colorScheme.primary
        : isActive
            ? theme.colorScheme.secondary
            : theme.colorScheme.onSurface;

    final IconData statusIcon = isCompleted
        ? Icons.check_circle_outline
        : isActive
            ? Icons.radio_button_checked
            : icon;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.all(isActive || isCompleted ? 10 : 0),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.14)
            : isCompleted
                ? theme.colorScheme.primary.withOpacity(0.10)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            statusIcon,
            color: accentColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: accentColor,
                fontWeight:
                    isActive || isCompleted ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
