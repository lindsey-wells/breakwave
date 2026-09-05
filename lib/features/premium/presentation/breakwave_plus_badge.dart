// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_badge.dart
// Purpose: Shared branded BreakWave Plus badge.
// Notes: Steel/graphite when inactive; BreakWave blue when active.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class BreakWavePlusBadge extends StatelessWidget {
  const BreakWavePlusBadge({
    super.key,
    required this.active,
    required this.statusColor,
    this.size = 56,
    this.loading = false,
  });

  final bool active;
  final Color statusColor;
  final double size;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color steelMid =
        Color.lerp(statusColor, const Color(0xFFB9C2CC), 0.28)!;
    final List<Color> colors = active
        ? const <Color>[
            Color(0xFF70D2FF),
            Color(0xFF178ED2),
            Color(0xFF07547F),
          ]
        : <Color>[
            const Color(0xFFAEB6C0),
            steelMid,
            const Color(0xFF353C46),
          ];

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
            stops: const <double>[0, 0.48, 1],
          ),
          border: Border.all(
            color: active
                ? const Color(0xFFB8EAFF)
                : const Color(0xFF3DA8DC),
            width: 1.5,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.42),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: (active
                      ? const Color(0xFF35B9FF)
                      : const Color(0xFF5EC8F5))
                  .withOpacity(0.22),
              blurRadius: 10,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: size * 0.34,
                  height: size * 0.34,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  '+',
                  style: TextStyle(
                    color: const Color(0xFFF7FBFF),
                    fontSize: size * 0.62,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    shadows: const <Shadow>[
                      Shadow(
                        color: Color(0xFF101820),
                        blurRadius: 2.5,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: Color(0x80FFFFFF),
                        blurRadius: 1,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
