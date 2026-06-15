// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_timer_card.dart
// Purpose: BW-15 wave timer v1 for Rescue.
// Notes: BW-30 ocean polish pass keeps behavior but refines the visual presentation.
// ------------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;

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

class _WaveTimerCardState extends State<WaveTimerCard>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 90;

  final LogRepository _repository = const LogRepository();

  late final AnimationController _waveController;
  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool timerFinished = !_isRunning && _remainingSeconds == 0;

    final double progress = timerFinished
        ? 1
        : _isRunning
            ? (_totalSeconds - _remainingSeconds) / _totalSeconds
            : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHighest.withOpacity(0.62),
            colorScheme.surfaceContainer.withOpacity(0.40),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
          AnimatedBuilder(
            animation: _waveController,
            builder: (BuildContext context, Widget? child) {
              return SizedBox(
                height: 38,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WaveProgressPainter(
                    progress: progress,
                    phase: _waveController.value,
                    isRunning: _isRunning,
                    timerFinished: timerFinished,
                    colorScheme: colorScheme,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _formatTime(_remainingSeconds),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isRunning
                  ? 'One breath at a time.'
                  : timerFinished
                      ? 'The wave made it through 90 seconds. Mark what happened with honesty.'
                      : 'Start when you are ready.',
              textAlign: TextAlign.center,
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

class _WaveProgressPainter extends CustomPainter {
  const _WaveProgressPainter({
    required this.progress,
    required this.phase,
    required this.isRunning,
    required this.timerFinished,
    required this.colorScheme,
  });

  final double progress;
  final double phase;
  final bool isRunning;
  final bool timerFinished;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.34, size.width, size.height * 0.32),
      const Radius.circular(999),
    );

    final Paint trackPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest.withOpacity(0.56);

    canvas.drawRRect(track, trackPaint);

    final double progressWidth = math.max(0, size.width * progress);
    if (progressWidth <= 0) {
      return;
    }

    final Rect clipRect = Rect.fromLTWH(0, 0, progressWidth, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    final double baseline = size.height * 0.50;
    final double amplitude = isRunning ? size.height * 0.16 : size.height * 0.08;
    final double frequency = math.pi * 2 / math.max(size.width * 0.42, 1);
    final double phaseShift = phase * math.pi * 2;

    final Path wavePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseline);

    for (double x = 0; x <= size.width + 8; x += 6) {
      final double y = baseline + math.sin((x * frequency) + phaseShift) * amplitude;
      wavePath.lineTo(x, y);
    }

    wavePath
      ..lineTo(size.width, size.height)
      ..close();

    final Paint wavePaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          colorScheme.primary.withOpacity(timerFinished ? 0.95 : 0.78),
          colorScheme.secondary.withOpacity(0.88),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(wavePath, wavePaint);

    final Paint crestPaint = Paint()
      ..color = colorScheme.onPrimary.withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final Path crestPath = Path();
    bool started = false;
    for (double x = 0; x <= size.width + 8; x += 6) {
      final double y = baseline + math.sin((x * frequency) + phaseShift) * amplitude;
      if (!started) {
        crestPath.moveTo(x, y);
        started = true;
      } else {
        crestPath.lineTo(x, y);
      }
    }

    canvas.drawPath(crestPath, crestPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaveProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        phase != oldDelegate.phase ||
        isRunning != oldDelegate.isRunning ||
        timerFinished != oldDelegate.timerFinished ||
        colorScheme != oldDelegate.colorScheme;
  }
}

