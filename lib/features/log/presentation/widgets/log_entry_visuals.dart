// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_entry_visuals.dart
// Purpose: Shared icon and color identity for Log entry types.
// Notes: BW-LOG-01A adds presentation-only visual identity.
// Notes: BW-LOG-01B2 adds a calm lavender Reflection identity.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

class LogEntryVisualStyle {
  const LogEntryVisualStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

class LogEntryVisuals {
  const LogEntryVisuals._();

  static const LogEntryVisualStyle urge = LogEntryVisualStyle(
    icon: Icons.waves_rounded,
    color: Color(0xFF62C3FF),
    backgroundColor: Color(0x332C8ED6),
  );

  static const LogEntryVisualStyle slip = LogEntryVisualStyle(
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFFFBC66),
    backgroundColor: Color(0x33FF9F43),
  );

  static const LogEntryVisualStyle victory = LogEntryVisualStyle(
    icon: Icons.emoji_events_rounded,
    color: Color(0xFF6CE3A5),
    backgroundColor: Color(0x3354C98B),
  );

  static const LogEntryVisualStyle reflection = LogEntryVisualStyle(
    icon: Icons.lightbulb_outline_rounded,
    color: Color(0xFFC8B6FF),
    backgroundColor: Color(0x334C3A8A),
  );

  static const LogEntryVisualStyle fallback = LogEntryVisualStyle(
    icon: Icons.notes_rounded,
    color: Color(0xFFB7D9EE),
    backgroundColor: Color(0x332E86C9),
  );

  static LogEntryVisualStyle forType(String entryType) {
    switch (entryType.trim().toLowerCase()) {
      case 'urge':
        return urge;
      case 'slip':
        return slip;
      case 'victory':
        return victory;
      case 'reflection':
        return reflection;
      default:
        return fallback;
    }
  }
}
