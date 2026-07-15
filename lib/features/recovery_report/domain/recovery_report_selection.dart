// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_selection.dart
// Purpose: Privacy-first recovery report content selection.
// Notes: BW-87B6A1 requires explicit opt-in for optional content.
// Notes: Summary data is always included; raw logs are excluded.
// ------------------------------------------------------------

enum RecoveryReportRange {
  last30Days(
    days: 30,
    label: 'Last 30 days',
  ),
  last90Days(
    days: 90,
    label: 'Last 90 days',
  );

  const RecoveryReportRange({
    required this.days,
    required this.label,
  });

  final int days;
  final String label;

  static RecoveryReportRange fromStorage(
    dynamic raw,
  ) {
    final String value =
        (raw ?? '').toString().trim();

    for (final RecoveryReportRange range
        in RecoveryReportRange.values) {
      if (range.name == value) {
        return range;
      }
    }

    return RecoveryReportRange.last30Days;
  }
}

enum RecoveryReportSection {
  summary,
  triggers,
  timingPatterns,
  completedRoutines,
  completedChristianJourneys,
  personalPlan,
}

class RecoveryReportPlanSelection {
  const RecoveryReportPlanSelection({
    this.includePrimaryReason = false,
    this.includeReasons = false,
    this.includeTriggers = false,
    this.includeDangerWindows = false,
    this.includeRedirectActions = false,
    this.includePhoneBoundary = false,
    this.includeBedtimeStrategy = false,
    this.includeAfterSlipReset = false,
    this.includeTrustedSupportName = false,
    this.includeFaithSupport = false,
  });

  static const RecoveryReportPlanSelection none =
      RecoveryReportPlanSelection();

  final bool includePrimaryReason;
  final bool includeReasons;
  final bool includeTriggers;
  final bool includeDangerWindows;
  final bool includeRedirectActions;
  final bool includePhoneBoundary;
  final bool includeBedtimeStrategy;
  final bool includeAfterSlipReset;

  // Names and faith content remain opt-in because they may
  // reveal sensitive personal context.
  final bool includeTrustedSupportName;
  final bool includeFaithSupport;

  bool get anySelected =>
      includePrimaryReason ||
      includeReasons ||
      includeTriggers ||
      includeDangerWindows ||
      includeRedirectActions ||
      includePhoneBoundary ||
      includeBedtimeStrategy ||
      includeAfterSlipReset ||
      includeTrustedSupportName ||
      includeFaithSupport;

  List<String> get selectedFieldKeys {
    final List<String> keys = <String>[];

    if (includePrimaryReason) {
      keys.add('primaryReason');
    }

    if (includeReasons) {
      keys.add('reasons');
    }

    if (includeTriggers) {
      keys.add('triggers');
    }

    if (includeDangerWindows) {
      keys.add('dangerWindows');
    }

    if (includeRedirectActions) {
      keys.add('redirectActions');
    }

    if (includePhoneBoundary) {
      keys.add('phoneBoundary');
    }

    if (includeBedtimeStrategy) {
      keys.add('bedtimeStrategy');
    }

    if (includeAfterSlipReset) {
      keys.add('afterSlipReset');
    }

    if (includeTrustedSupportName) {
      keys.add('trustedSupportName');
    }

    if (includeFaithSupport) {
      keys.add('faithSupport');
    }

    return List<String>.unmodifiable(keys);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'includePrimaryReason':
          includePrimaryReason,
      'includeReasons': includeReasons,
      'includeTriggers': includeTriggers,
      'includeDangerWindows':
          includeDangerWindows,
      'includeRedirectActions':
          includeRedirectActions,
      'includePhoneBoundary':
          includePhoneBoundary,
      'includeBedtimeStrategy':
          includeBedtimeStrategy,
      'includeAfterSlipReset':
          includeAfterSlipReset,
      'includeTrustedSupportName':
          includeTrustedSupportName,
      'includeFaithSupport':
          includeFaithSupport,
    };
  }

  factory RecoveryReportPlanSelection.fromMap(
    dynamic raw,
  ) {
    final Map<String, dynamic> map =
        raw is Map<String, dynamic>
            ? raw
            : <String, dynamic>{};

    return RecoveryReportPlanSelection(
      includePrimaryReason:
          map['includePrimaryReason'] == true,
      includeReasons:
          map['includeReasons'] == true,
      includeTriggers:
          map['includeTriggers'] == true,
      includeDangerWindows:
          map['includeDangerWindows'] == true,
      includeRedirectActions:
          map['includeRedirectActions'] == true,
      includePhoneBoundary:
          map['includePhoneBoundary'] == true,
      includeBedtimeStrategy:
          map['includeBedtimeStrategy'] == true,
      includeAfterSlipReset:
          map['includeAfterSlipReset'] == true,
      includeTrustedSupportName:
          map['includeTrustedSupportName'] == true,
      includeFaithSupport:
          map['includeFaithSupport'] == true,
    );
  }
}

class RecoveryReportSelection {
  const RecoveryReportSelection({
    this.range =
        RecoveryReportRange.last30Days,
    this.includeTriggers = false,
    this.includeTimingPatterns = false,
    this.includeCompletedRoutines = false,
    this.includeCompletedChristianJourneys =
        false,
    this.personalPlan =
        RecoveryReportPlanSelection.none,
  });

  static const RecoveryReportSelection
      summaryOnly =
      RecoveryReportSelection();

  static const List<String> excludedByDesign =
      <String>[
    'Individual log entries',
    'Log notes and CBT reflections',
    'Thought, action, and consequence text',
    'Trusted-contact phone numbers',
    'Trusted-contact email addresses',
  ];

  final RecoveryReportRange range;

  // All optional sections default to false.
  final bool includeTriggers;
  final bool includeTimingPatterns;
  final bool includeCompletedRoutines;

  // Faith participation is sensitive and remains opt-in.
  final bool includeCompletedChristianJourneys;

  final RecoveryReportPlanSelection personalPlan;

  bool get includeSummary => true;

  bool get includePersonalPlan =>
      personalPlan.anySelected;

  Set<RecoveryReportSection>
      get selectedSections {
    final Set<RecoveryReportSection> sections =
        <RecoveryReportSection>{
      RecoveryReportSection.summary,
    };

    if (includeTriggers) {
      sections.add(
        RecoveryReportSection.triggers,
      );
    }

    if (includeTimingPatterns) {
      sections.add(
        RecoveryReportSection.timingPatterns,
      );
    }

    if (includeCompletedRoutines) {
      sections.add(
        RecoveryReportSection.completedRoutines,
      );
    }

    if (includeCompletedChristianJourneys) {
      sections.add(
        RecoveryReportSection
            .completedChristianJourneys,
      );
    }

    if (includePersonalPlan) {
      sections.add(
        RecoveryReportSection.personalPlan,
      );
    }

    return Set<RecoveryReportSection>.unmodifiable(
      sections,
    );
  }

  int get selectedSectionCount =>
      selectedSections.length;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'range': range.name,
      'includeTriggers': includeTriggers,
      'includeTimingPatterns':
          includeTimingPatterns,
      'includeCompletedRoutines':
          includeCompletedRoutines,
      'includeCompletedChristianJourneys':
          includeCompletedChristianJourneys,
      'personalPlan': personalPlan.toMap(),
    };
  }

  factory RecoveryReportSelection.fromMap(
    Map<String, dynamic> map,
  ) {
    return RecoveryReportSelection(
      range: RecoveryReportRange.fromStorage(
        map['range'],
      ),
      includeTriggers:
          map['includeTriggers'] == true,
      includeTimingPatterns:
          map['includeTimingPatterns'] == true,
      includeCompletedRoutines:
          map['includeCompletedRoutines'] == true,
      includeCompletedChristianJourneys:
          map[
              'includeCompletedChristianJourneys'] ==
          true,
      personalPlan:
          RecoveryReportPlanSelection.fromMap(
        map['personalPlan'],
      ),
    );
  }
}
