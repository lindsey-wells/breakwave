// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: accountability_check_in_template.dart
// Purpose: Local-only accountability check-in drafting templates.
// Notes: BW-89A12D adds editable copy-only templates without recovery-data injection.
// ------------------------------------------------------------

enum AccountabilityCheckInTemplate {
  weeklyCheckIn,
  afterSlipHonesty,
  victoryUpdate;

  String get label {
    switch (this) {
      case AccountabilityCheckInTemplate.weeklyCheckIn:
        return 'Weekly check-in';
      case AccountabilityCheckInTemplate.afterSlipHonesty:
        return 'After-slip honesty';
      case AccountabilityCheckInTemplate.victoryUpdate:
        return 'Victory update';
    }
  }

  String get starterText {
    switch (this) {
      case AccountabilityCheckInTemplate.weeklyCheckIn:
        return 'Quick weekly check-in: I am taking a little time to look at how this week went. One thing I am working on is _____. One thing that would help this week is _____. Thanks for being someone I can be honest with.';
      case AccountabilityCheckInTemplate.afterSlipHonesty:
        return 'I want to be honest: I had a setback. I do not want to hide it, and I am focusing on what I do next. My next step is _____. Could you check in with me when you can?';
      case AccountabilityCheckInTemplate.victoryUpdate:
        return 'A small win I want to share: _____. I chose a healthier next step, and I want to remember that progress. Thanks for being in my corner.';
    }
  }
}
