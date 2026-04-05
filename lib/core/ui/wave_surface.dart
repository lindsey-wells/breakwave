// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_surface.dart
// Purpose: Shared ocean-themed surface for BreakWave.
// Notes: BW-30 ocean polish pass.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class WaveSurface extends StatelessWidget {
  const WaveSurface({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF163F69),
              Color(0xFF0E2B49),
              Color(0xFF09192D),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF5DB7FF).withOpacity(0.20),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF061220).withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WaveSurfacePainter(),
                ),
              ),
            ),
            Positioned(
              top: -34,
              right: -22,
              child: _GlowOrb(
                size: 110,
                color: const Color(0xFF4AB8FF).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -52,
              left: -28,
              child: _GlowOrb(
                size: 132,
                color: const Color(0xFF1C79D4).withOpacity(0.12),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.white.withOpacity(0.00),
                      Colors.white.withOpacity(0.28),
                      Colors.white.withOpacity(0.00),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  height: 1.35,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: Colors.white.withOpacity(0.90),
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _WaveSurfacePainter extends CustomPainter {
  const _WaveSurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint crestPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint deepPaint = Paint()
      ..color = const Color(0xFF73C4FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path topWave = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.48,
        size.height * 0.27,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.36,
        size.width,
        size.height * 0.22,
      );

    final Path middleWave = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.49,
        size.width * 0.42,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.64,
        size.width,
        size.height * 0.50,
      );

    final Path lowWave = Path()
      ..moveTo(0, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.73,
        size.width * 0.40,
        size.height * 0.81,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.90,
        size.width,
        size.height * 0.76,
      );

    canvas.drawPath(topWave, crestPaint);
    canvas.drawPath(middleWave, deepPaint);
    canvas.drawPath(lowWave, crestPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
