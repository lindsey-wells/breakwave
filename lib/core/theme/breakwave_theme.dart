// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_theme.dart
// Purpose: App-wide visual theme for BreakWave.
// Notes: BW-06A selected-state contrast polish.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import 'breakwave_colors.dart';

class BreakWaveTheme {
  static ThemeData dark() {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: BreakWaveColors.crestBlue,
      secondary: BreakWaveColors.foamBlue,
      surface: BreakWaveColors.cardDark,
      error: Color(0xFFFF6B6B),
      onPrimary: Colors.white,
      onSecondary: BreakWaveColors.navyDeep,
      onSurface: Colors.white,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BreakWaveColors.navyDeep,
      appBarTheme: const AppBarTheme(
        backgroundColor: BreakWaveColors.navyDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: BreakWaveColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: Color(0x1FFFFFFF),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BreakWaveColors.oceanDeep,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BreakWaveColors.cardMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: BreakWaveColors.foamBlue),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BreakWaveColors.oceanDeep,
        indicatorColor: BreakWaveColors.navIndicator,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Colors.white,
                size: 28,
              );
            }
            return const IconThemeData(
              color: BreakWaveColors.mistBlue,
              size: 26,
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: BreakWaveColors.mistBlue,
            );
          },
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BreakWaveColors.crestBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BreakWaveColors.foamBlue,
          side: const BorderSide(color: Color(0x55FFFFFF)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BreakWaveColors.chipIdle,
        selectedColor: BreakWaveColors.chipSelected,
        secondarySelectedColor: BreakWaveColors.chipSelected,
        side: const BorderSide(color: Color(0x2FFFFFFF)),
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
