// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_app_bar.dart
// Purpose: BW-64 branded app header.
// Notes: Replaces menu-like wave icon with a custom BreakWave ocean mark.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BreakWaveAppBar({
    super.key,
    required this.sectionTitle,
  });

  final String sectionTitle;

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 20,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _BreakWaveBrandMark(size: 30),
              const SizedBox(width: 10),
              Text(
                'BreakWave',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sectionTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakWaveBrandMark extends StatelessWidget {
  const _BreakWaveBrandMark({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BreakWave ocean mark',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _BreakWaveBrandPainter(
            colorScheme: Theme.of(context).colorScheme,
          ),
        ),
      ),
    );
  }
}

class _BreakWaveBrandPainter extends CustomPainter {
  const _BreakWaveBrandPainter({
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Offset center = bounds.center;
    final double radius = size.shortestSide / 2;

    final Paint backgroundPaint = Paint()
      ..color = colorScheme.primaryContainer;

    final Paint ringPaint = Paint()
      ..color = colorScheme.primary.withAlpha(125)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Paint mainWavePaint = Paint()
      ..color = colorScheme.onPrimaryContainer
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.12;

    final Paint crestPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.075;

    final Paint foamPaint = Paint()
      ..color = colorScheme.onPrimaryContainer.withAlpha(210);

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawCircle(center, radius - 1.0, ringPaint);

    final Path mainWavePath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.66)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.45,
        size.width * 0.52,
        size.height * 0.44,
        size.width * 0.66,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.72,
        size.width * 0.90,
        size.height * 0.65,
        size.width * 0.82,
        size.height * 0.48,
      );

    final Path crestPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.37)
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.23,
        size.width * 0.86,
        size.height * 0.38,
        size.width * 0.76,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.62,
        size.width * 0.55,
        size.height * 0.57,
        size.width * 0.61,
        size.height * 0.46,
      );

    canvas.drawPath(mainWavePath, mainWavePaint);
    canvas.drawPath(crestPath, crestPaint);
    canvas.drawCircle(
      Offset(size.width * 0.37, size.height * 0.48),
      size.width * 0.035,
      foamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BreakWaveBrandPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
