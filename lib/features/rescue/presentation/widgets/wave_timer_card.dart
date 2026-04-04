// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_timer_card.dart
// Purpose: BW-15 wave timer v1 for Rescue.
// Notes: Adds a simple 90-second timer with outcome logging.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../log/data/log_repository.dart';
import '../../../log/domain/log_entry.dart';

class WaveTimerCard extends StatefulWidget {
  const WaveTimerCard({
    super.key,
    required this.onReturnHome,
  });

  final VoidCallback onReturnHome;

  @override
  State<WaveTimerCard> createState() => _WaveTimerCardState();
}

class _WaveTimerCardState extends State<WaveTimerCard> {
  static const int _totalSeconds = 90;

  final LogRepository _repository = const LogRepository();

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _resetTimerState() {
    _timer?.cancel();
    _remainingSeconds = _totalSeconds;
    _isRunning = false;
  }

  Future<void> _saveOutcome({
    required String entryType,
    required int intensity,
    required String notes,
    required String outcomeTag,
  }) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _repository.saveEntry(
        LogEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          entryType: entryType,
          intensity: intensity,
          triggers: <String>[
            'Wave Timer',
            outcomeTag,
          ],
          notes: notes,
          createdAtIso: DateTime.now().toIso8601String(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _resetTimerState();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            entryType == 'Slip'
                ? 'Outcome saved. Returning Home.'
                : 'Wave outcome saved. Returning Home.',
          ),
        ),
      );

      widget.onReturnHome();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save that timer outcome right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool timerFinished = !_isRunning && _remainingSeconds == 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Wave Timer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay with this wave for 90 seconds. Breathe. Do not obey it right away.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _formatTime(_remainingSeconds),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isRunning
                  ? 'One breath at a time.'
                  : timerFinished
                      ? 'Now choose what happened.'
                      : 'Start when you are ready.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 18),
          if (!_isRunning && !timerFinished)
            FilledButton(
              onPressed: _startTimer,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Start 90-second timer'),
              ),
            ),
          if (_isRunning) ...<Widget>[
            FilledButton.tonal(
              onPressed: _cancelTimer,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Reset timer'),
              ),
            ),
          ],
          if (timerFinished) ...<Widget>[
            FilledButton(
              onPressed: _isSaving
                  ? null
                  : () => _saveOutcome(
                        entryType: 'Victory',
                        intensity: 2,
                        notes: 'Wave Timer outcome: Lower now.',
                        outcomeTag: 'Lower Now',
                      ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Lower now'),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: _isSaving
                  ? null
                  : () => _saveOutcome(
                        entryType: 'Urge',
                        intensity: 4,
                        notes: 'Wave Timer outcome: Still strong.',
                        outcomeTag: 'Still Strong',
                      ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Still strong'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () => _saveOutcome(
                        entryType: 'Slip',
                        intensity: 5,
                        notes: 'Wave Timer outcome: I slipped.',
                        outcomeTag: 'Slipped',
                      ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('I slipped'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
