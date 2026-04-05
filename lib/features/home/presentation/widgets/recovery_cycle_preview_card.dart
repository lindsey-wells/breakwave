// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_preview_card.dart
// Purpose: BW-27 recovery cycle wheel entry card.
// Notes: BW-30A ocean identity correction for the cycle preview.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../cycle/presentation/recovery_cycle_wheel_screen.dart';

class RecoveryCyclePreviewCard extends StatelessWidget {
  const RecoveryCyclePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Recovery cycle wheel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Trigger → Urge → Escalation → Action → Regret / Recovery',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to learn where the wave usually grows and where you can interrupt it earlier.',
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
