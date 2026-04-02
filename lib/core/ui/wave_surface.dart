// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: wave_surface.dart
// Purpose: Shared wave-style visual surface for BreakWave sections.
// Notes: BW-06 theme and wave motif pass.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../theme/breakwave_colors.dart';

class WaveSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const WaveSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            BreakWaveColors.oceanDeep,
            BreakWaveColors.waveBlue,
            BreakWaveColors.cardDark,
          ],
          stops: <double>[0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: const Color(0x1FFFFFFF),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
