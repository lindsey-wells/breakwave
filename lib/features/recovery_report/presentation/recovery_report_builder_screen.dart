// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_builder_screen.dart
// Purpose: Privacy-first recovery report selection and preview.
// Notes: BW-87B6B1 previews exactly what the user selected.
// Notes: This pass creates no file and opens no share sheet.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../faith/data/christian_journey_progress_store.dart';
import '../../faith/domain/christian_journey_progress.dart';
import '../../guided_routines/data/recovery_routine_progress_store.dart';
import '../../guided_routines/domain/recovery_routine_progress.dart';
import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import '../../personal_plan/data/personal_recovery_plan_store.dart';
import '../../personal_plan/domain/personal_recovery_plan.dart';
import '../domain/recovery_report_formatter.dart';
import '../domain/recovery_report_selection.dart';
import '../domain/recovery_report_snapshot.dart';
import '../domain/recovery_report_snapshot_builder.dart';

class RecoveryReportBuilderScreen extends StatefulWidget {
  const RecoveryReportBuilderScreen({
    super.key,
  });

  @override
  State<RecoveryReportBuilderScreen> createState() =>
      _RecoveryReportBuilderScreenState();
}

class _RecoveryReportBuilderScreenState
    extends State<RecoveryReportBuilderScreen> {
  final LogRepository _logRepository =
      const LogRepository();

  final RecoveryReportSnapshotBuilder _builder =
      const RecoveryReportSnapshotBuilder();

  List<LogEntry> _entries = const <LogEntry>[];

  Map<String, RecoveryRoutineProgress>
      _routineProgress =
      <String, RecoveryRoutineProgress>{};

  Map<String, ChristianJourneyProgress>
      _journeyProgress =
      <String, ChristianJourneyProgress>{};

  PersonalRecoveryPlan? _personalPlan;
  RecoveryMode _mode = RecoveryMode.secular;

  RecoveryReportRange _range =
      RecoveryReportRange.last30Days;

  bool _includeTriggers = false;
  bool _includeTimingPatterns = false;
  bool _includeCompletedRoutines = false;
  bool _includeCompletedChristianJourneys =
      false;

  bool _includePrimaryReason = false;
  bool _includeReasons = false;
  bool _includePlanTriggers = false;
  bool _includeDangerWindows = false;
  bool _includeRedirectActions = false;
  bool _includePhoneBoundary = false;
  bool _includeBedtimeStrategy = false;
  bool _includeAfterSlipReset = false;
  bool _includeTrustedSupportName = false;
  bool _includeFaithSupport = false;

  bool _loading = true;
  bool _buildingPreview = false;

  String? _loadError;
  String? _previewText;

  @override
  void initState() {
    super.initState();
    _loadReportInputs();
  }

  RecoveryReportSelection get _selection =>
      RecoveryReportSelection(
        range: _range,
        includeTriggers: _includeTriggers,
        includeTimingPatterns:
            _includeTimingPatterns,
        includeCompletedRoutines:
            _includeCompletedRoutines,
        includeCompletedChristianJourneys:
            _mode == RecoveryMode.christian &&
                _includeCompletedChristianJourneys,
        personalPlan:
            RecoveryReportPlanSelection(
          includePrimaryReason:
              _includePrimaryReason,
          includeReasons: _includeReasons,
          includeTriggers:
              _includePlanTriggers,
          includeDangerWindows:
              _includeDangerWindows,
          includeRedirectActions:
              _includeRedirectActions,
          includePhoneBoundary:
              _includePhoneBoundary,
          includeBedtimeStrategy:
              _includeBedtimeStrategy,
          includeAfterSlipReset:
              _includeAfterSlipReset,
          includeTrustedSupportName:
              _includeTrustedSupportName,
          includeFaithSupport:
              _mode == RecoveryMode.christian &&
                  _includeFaithSupport,
        ),
      );

  Future<void> _loadReportInputs() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final List<LogEntry> entries =
          await _logRepository.loadEntries();

      final Map<String, RecoveryRoutineProgress>
          routineProgress =
          await RecoveryRoutineProgressStore
              .loadAll();

      final Map<String, ChristianJourneyProgress>
          journeyProgress =
          await ChristianJourneyProgressStore
              .loadAll();

      final PersonalRecoveryPlan? personalPlan =
          await PersonalRecoveryPlanStore.load();

      final RecoveryMode mode =
          await RecoveryModeStore.loadMode() ??
              RecoveryMode.secular;

      if (!mounted) return;

      setState(() {
        _entries =
            List<LogEntry>.unmodifiable(entries);

        _routineProgress =
            Map<String, RecoveryRoutineProgress>
                .unmodifiable(routineProgress);

        _journeyProgress =
            Map<String, ChristianJourneyProgress>
                .unmodifiable(journeyProgress);

        _personalPlan = personalPlan;
        _mode = mode;
        _loading = false;
      });

      _generatePreview();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError =
            'BreakWave could not load the information needed '
            'for this report. Your saved recovery data was '
            'not changed.';
      });
    }
  }

  void _changeSelection(
    VoidCallback update,
  ) {
    setState(() {
      update();
      _previewText = null;
    });
  }

  void _generatePreview() {
    if (_loading || _buildingPreview) {
      return;
    }

    setState(() {
      _buildingPreview = true;
    });

    try {
      final RecoveryReportSnapshot snapshot =
          _builder.build(
        selection: _selection,
        entries: _entries,
        routineProgress: _routineProgress,
        christianJourneyProgress:
            _journeyProgress,
        personalPlan: _personalPlan,
        recoveryMode: _mode,
        now: DateTime.now(),
      );

      final String preview =
          RecoveryReportFormatter.buildText(
        snapshot,
      );

      if (!mounted) return;

      setState(() {
        _previewText = preview;
        _buildingPreview = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _buildingPreview = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'BreakWave could not build the report preview '
            'right now.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recovery report',
        ),
        actions: <Widget>[
          IconButton(
            onPressed:
                _loading ? null : _loadReportInputs,
            tooltip: 'Refresh report information',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _ReportSurface(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  'Report unavailable',
                ),
                const SizedBox(height: 10),
                Text(_loadError!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loadReportInputs,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final bool hasPlan =
        _personalPlan?.hasAnyContent ?? false;

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        120,
      ),
      children: <Widget>[
        const _ReportSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _SectionTitle(
                'Choose exactly what to include',
              ),
              SizedBox(height: 10),
              Text(
                'BreakWave builds this report on your device. '
                'Nothing is uploaded or shared from this screen. '
                'Review the complete preview before creating '
                'or sending anything.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReportSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Report period',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    RecoveryReportRange.values
                        .map(
                          (
                            RecoveryReportRange range,
                          ) =>
                              ChoiceChip(
                            label:
                                Text(range.label),
                            selected:
                                _range == range,
                            onSelected: (_) {
                              _changeSelection(() {
                                _range = range;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReportSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Recovery information',
              ),
              const SizedBox(height: 6),
              const CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: true,
                onChanged: null,
                title: Text(
                  'Recovery summary',
                ),
                subtitle: Text(
                  'Logged moments, urges, victories, '
                  'slips, and average intensity.',
                ),
              ),
              _selectionTile(
                title: 'Top recorded triggers',
                subtitle:
                    'Up to five aggregate trigger counts. '
                    'No individual entries are included.',
                value: _includeTriggers,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeTriggers = value;
                  });
                },
              ),
              _selectionTile(
                title: 'Timing observations',
                subtitle:
                    'Dominant weekday or time window only '
                    'when enough valid entries exist.',
                value: _includeTimingPatterns,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeTimingPatterns = value;
                  });
                },
              ),
              _selectionTile(
                title: 'Guided routine completions',
                subtitle:
                    'Routine names and completion counts '
                    'inside the selected period.',
                value:
                    _includeCompletedRoutines,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeCompletedRoutines =
                        value;
                  });
                },
              ),
              _selectionTile(
                title:
                    'Christian journey completions',
                subtitle: _mode ==
                        RecoveryMode.christian
                    ? 'Journey names and completion counts '
                        'inside the selected period.'
                    : 'Available only when Christian mode '
                        'is selected.',
                value: _mode ==
                        RecoveryMode.christian &&
                    _includeCompletedChristianJourneys,
                enabled:
                    _mode == RecoveryMode.christian,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeCompletedChristianJourneys =
                        value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReportSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Selected recovery-plan details',
              ),
              const SizedBox(height: 10),
              Text(
                hasPlan
                    ? 'Every field below is off by default. '
                        'Select only what you are comfortable '
                        'showing another person.'
                    : 'No saved personal recovery plan is '
                        'available. Create and save a plan '
                        'before including plan details.',
              ),
              const SizedBox(height: 8),
              _planSelectionTile(
                title: 'Primary reason',
                value: _includePrimaryReason,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includePrimaryReason = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Reasons that matter',
                value: _includeReasons,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeReasons = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Plan triggers',
                value: _includePlanTriggers,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includePlanTriggers = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Danger windows',
                value: _includeDangerWindows,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeDangerWindows = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Redirect actions',
                value: _includeRedirectActions,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeRedirectActions = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Phone boundary',
                value: _includePhoneBoundary,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includePhoneBoundary = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Bedtime strategy',
                value: _includeBedtimeStrategy,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeBedtimeStrategy = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'After-slip reset',
                value: _includeAfterSlipReset,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeAfterSlipReset = value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Trusted support name',
                subtitle:
                    'Sensitive: includes the saved person’s '
                    'name, but never their phone or email.',
                value:
                    _includeTrustedSupportName,
                enabled: hasPlan,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeTrustedSupportName =
                        value;
                  });
                },
              ),
              _planSelectionTile(
                title: 'Faith support',
                subtitle:
                    _mode == RecoveryMode.christian
                        ? 'Sensitive: may reveal personal '
                            'religious information.'
                        : 'Available only in Christian mode.',
                value:
                    _mode == RecoveryMode.christian &&
                        _includeFaithSupport,
                enabled: hasPlan &&
                    _mode == RecoveryMode.christian,
                onChanged: (bool value) {
                  _changeSelection(() {
                    _includeFaithSupport = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ReportSurface(
          emphasized: true,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SectionTitle(
                      'Never included',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...RecoveryReportSelection
                  .excludedByDesign
                  .map(
                    (String item) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Text('• $item'),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _buildingPreview
                ? null
                : _generatePreview,
            icon: const Icon(
              Icons.visibility_outlined,
            ),
            label: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Text(
                _buildingPreview
                    ? 'Building preview...'
                    : 'Generate private preview',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ReportSurface(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Complete report preview',
              ),
              const SizedBox(height: 10),
              Text(
                _previewText == null
                    ? 'Your selections changed. Generate '
                        'the preview again to see exactly '
                        'what the report will contain.'
                    : 'Read this carefully before creating '
                        'or sharing a report in a later step.',
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant,
                  ),
                ),
                child: SelectableText(
                  _previewText ??
                      'No current preview.',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This testing pass does not create a file '
                'or open the system share sheet.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: enabled
          ? (bool? selected) {
              onChanged(selected ?? false);
            }
          : null,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _planSelectionTile({
    required String title,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: enabled && value,
      onChanged: enabled
          ? (bool? selected) {
              onChanged(selected ?? false);
            }
          : null,
      title: Text(title),
      subtitle:
          subtitle == null ? null : Text(subtitle),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
    this.text,
  );

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
    );
  }
}

class _ReportSurface extends StatelessWidget {
  const _ReportSurface({
    required this.child,
    this.emphasized = false,
  });

  final Widget child;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: emphasized
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest
                .withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasized
              ? colorScheme.primary
                  .withOpacity(0.35)
              : colorScheme.outlineVariant,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: emphasized
            ? TextStyle(
                color:
                    colorScheme.onPrimaryContainer,
              )
            : null,
        child: IconTheme.merge(
          data: IconThemeData(
            color: emphasized
                ? colorScheme.onPrimaryContainer
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
