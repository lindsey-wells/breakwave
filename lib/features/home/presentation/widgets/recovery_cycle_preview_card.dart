// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_preview_card.dart
// Purpose: BW-27 recovery cycle wheel entry card.
// Notes: BW-70A compacts the cycle preview into a tighter Home teaser.
// Notes: BW-81E reframes the teaser as Learn the Wave Pattern.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';

class RecoveryCyclePreviewCard extends StatelessWidget {
  const RecoveryCyclePreviewCard({super.key});

  static const List<_WavePatternStep> _steps = <_WavePatternStep>[
    _WavePatternStep(
      title: 'What it feels like',
      body: 'A trigger turns into pressure, urgency, bargaining, or autopilot.',
    ),
    _WavePatternStep(
      title: 'What to watch for',
      body: 'Notice isolation, late-night scrolling, secrecy, stress, or fantasy loops.',
    ),
    _WavePatternStep(
      title: 'What BreakWave helps you do',
      body: 'Name the wave, use Rescue, log honestly, and learn the pattern sooner.',
    ),
    _WavePatternStep(
      title: 'Next right action',
      body: 'Tap in, learn the cycle, then interrupt the wave before it builds.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecoveryCycleWheelScreen(),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.surfaceContainerHighest.withOpacity(0.50),
              colorScheme.surfaceContainer.withOpacity(0.34),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.78),
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PreviewWavePainter(),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.transparent,
                      const Color(0xFF73C4FF).withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Learn the Wave Pattern',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trigger → Urge → Pressure → Choice → Reset',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recovery gets easier when you can spot the wave before it takes over.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  for (final _WavePatternStep step in _steps) ...<Widget>[
                    _WavePatternRow(step: step),
                    if (step != _steps.last) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.waves,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap to open the Recovery Cycle Wheel.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePatternRow extends StatelessWidget {
  final _WavePatternStep step;

  const _WavePatternRow({
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.82),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                step.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.body,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WavePatternStep {
  const _WavePatternStep({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _PreviewWavePainter extends CustomPainter {
  const _PreviewWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint wavePaint = Paint()
      ..color = const Color(0xFF73C4FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Path wave = Path()
      ..moveTo(-16, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.54,
        size.width * 0.52,
        size.height * 0.64,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.74,
        size.width + 16,
        size.height * 0.58,
      );

    canvas.drawPath(wave, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
