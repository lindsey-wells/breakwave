// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_surface.dart
// Purpose: Shared ocean-themed surface for BreakWave.
// Notes: BW-30A ocean identity correction.
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
            color: const Color(0xFF73C4FF).withOpacity(0.14),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF061220).withOpacity(0.24),
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
              right: -20,
              child: _GlowOrb(
                size: 128,
                color: const Color(0xFF73C4FF).withOpacity(0.08),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.white.withOpacity(0.00),
                      Colors.white.withOpacity(0.20),
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
      ..strokeWidth = 1.8;

    final Paint swellPaint = Paint()
      ..color = const Color(0xFF73C4FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Path topWave = Path()
      ..moveTo(-20, size.height * 0.34)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.20,
        size.width * 0.52,
        size.height * 0.31,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.40,
        size.width + 20,
        size.height * 0.26,
      );

    final Path lowWave = Path()
      ..moveTo(-20, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.63,
        size.width * 0.46,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.84,
        size.width + 20,
        size.height * 0.66,
      );

    canvas.drawPath(topWave, crestPaint);
    canvas.drawPath(lowWave, swellPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
