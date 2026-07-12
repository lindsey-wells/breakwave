// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_screen.dart
// Purpose: Editable, locally saved personal recovery plan.
// Notes: BW-87B3B connects existing BreakWave choices into one plan.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/reasons/reasons_store.dart';
import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../../core/support/support_contact_store.dart';
import '../../../core/triggers/triggers_store.dart';
import '../../../core/why/custom_why_store.dart';
import '../../insights/domain/recovery_insights_calculator.dart';
import '../../log/data/log_repository.dart';
import '../data/personal_recovery_plan_store.dart';
import '../domain/personal_recovery_plan.dart';
import '../domain/personal_recovery_plan_prefill.dart';

class PersonalRecoveryPlanScreen extends StatefulWidget {
  const PersonalRecoveryPlanScreen({super.key});

  @override
  State<PersonalRecoveryPlanScreen> createState() =>
      _PersonalRecoveryPlanScreenState();
}

class _PersonalRecoveryPlanScreenState
    extends State<PersonalRecoveryPlanScreen> {
  final PersonalRecoveryPlanPrefill _prefill =
      const PersonalRecoveryPlanPrefill();
  final LogRepository _logRepository =
      const LogRepository();
  final RecoveryInsightsCalculator _insightsCalculator =
      const RecoveryInsightsCalculator();

  late final TextEditingController _reasonsController;
  late final TextEditingController _primaryReasonController;
  late final TextEditingController _triggersController;
  late final TextEditingController _dangerWindowsController;
  late final TextEditingController _redirectActionsController;
  late final TextEditingController _trustedSupportController;
  late final TextEditingController _phoneBoundaryController;
  late final TextEditingController _bedtimeStrategyController;
  late final TextEditingController _afterSlipResetController;
  late final TextEditingController _faithSupportController;

  PersonalRecoveryPlan? _savedPlan;
  PersonalRecoveryPlan _draftPlan =
      PersonalRecoveryPlan.empty;
  RecoveryMode _mode = RecoveryMode.secular;

  bool _loading = true;
  bool _saving = false;
  bool _importing = false;
  bool _dirty = false;
  bool _suppressDirty = false;
  bool _sourceUpdateAvailable = false;

  String? _statusMessage;
  String? _loadError;

  static const List<String> _reasonSuggestions = <String>[
    'Relationships',
    'Integrity',
    'Mental clarity',
    'Time and energy',
    'Faith',
    'Confidence',
    'Sexual health',
  ];

  static const List<String> _triggerSuggestions = <String>[
    'Stress',
    'Boredom',
    'Lonely',
    'Habit',
    'Tired',
    'Environment',
  ];

  static const List<String> _dangerWindowSuggestions = <String>[
    'Late night',
    'Home alone',
    'In bed with the phone',
    'After conflict',
    'Unstructured time',
    'After drinking',
  ];

  List<String> get _redirectSuggestions {
    final List<String> suggestions = <String>[
      'Open Rescue',
      'Put the phone down',
      'Leave the room',
      'Move to public space',
      'Text someone safe',
      'Take a short walk',
      'Cold water reset',
      'Journal one line',
    ];

    if (_mode == RecoveryMode.christian) {
      suggestions.add('Pray for one minute');
    }

    return suggestions;
  }

  List<TextEditingController> get _controllers =>
      <TextEditingController>[
        _reasonsController,
        _primaryReasonController,
        _triggersController,
        _dangerWindowsController,
        _redirectActionsController,
        _trustedSupportController,
        _phoneBoundaryController,
        _bedtimeStrategyController,
        _afterSlipResetController,
        _faithSupportController,
      ];

  @override
  void initState() {
    super.initState();

    _reasonsController = TextEditingController();
    _primaryReasonController = TextEditingController();
    _triggersController = TextEditingController();
    _dangerWindowsController = TextEditingController();
    _redirectActionsController = TextEditingController();
    _trustedSupportController = TextEditingController();
    _phoneBoundaryController = TextEditingController();
    _bedtimeStrategyController = TextEditingController();
    _afterSlipResetController = TextEditingController();
    _faithSupportController = TextEditingController();

    for (final TextEditingController controller in _controllers) {
      controller.addListener(_handleDraftChanged);
    }

    _loadPlan();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller
        ..removeListener(_handleDraftChanged)
        ..dispose();
    }

    super.dispose();
  }

  void _handleDraftChanged() {
    if (_suppressDirty || !mounted) return;

    setState(() {
      _dirty = true;
      _statusMessage = null;
    });
  }

  Future<void> _loadPlan() async {
    try {
      final PersonalRecoveryPlan? plan =
          await PersonalRecoveryPlanStore.load();

      final RecoveryMode mode =
          await RecoveryModeStore.loadMode() ??
              RecoveryMode.secular;

      final PersonalRecoveryPlan basePlan =
          plan ?? PersonalRecoveryPlan.empty;

      final PersonalRecoveryPlan refreshed =
          await _refreshFromBreakWave(basePlan);

      if (!mounted) return;

      _mode = mode;
      _savedPlan = plan;
      _applyPlan(basePlan, dirty: false);

      setState(() {
        _sourceUpdateAvailable =
            _editableSignature(refreshed) !=
                _editableSignature(basePlan);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError =
            'BreakWave could not load your saved plan. '
            'Your other recovery data was not changed.';
      });
    }
  }

  void _applyPlan(
    PersonalRecoveryPlan plan, {
    required bool dirty,
  }) {
    _suppressDirty = true;
    _draftPlan = plan;

    _writeLines(_reasonsController, plan.reasons);
    _primaryReasonController.text = plan.primaryReason;
    _writeLines(_triggersController, plan.triggers);
    _writeLines(
      _dangerWindowsController,
      plan.dangerWindows,
    );
    _writeLines(
      _redirectActionsController,
      plan.redirectActions,
    );
    _trustedSupportController.text =
        plan.trustedSupportName;
    _phoneBoundaryController.text = plan.phoneBoundary;
    _bedtimeStrategyController.text =
        plan.bedtimeStrategy;
    _afterSlipResetController.text =
        plan.afterSlipReset;
    _faithSupportController.text = plan.faithSupport;

    _suppressDirty = false;

    if (mounted) {
      setState(() {
        _dirty = dirty;
      });
    } else {
      _dirty = dirty;
    }
  }

  List<String> _parseLines(String raw) {
    final List<String> result = <String>[];
    final Set<String> seen = <String>{};

    for (final String part in raw.split(RegExp(r'[\n,]'))) {
      final String display = part.trim();
      final String key = display.toLowerCase();

      if (display.isEmpty || !seen.add(key)) {
        continue;
      }

      result.add(display);
    }

    return result;
  }

  void _writeLines(
    TextEditingController controller,
    List<String> values,
  ) {
    controller.text = values.join('\n');
  }

  PersonalRecoveryPlan _currentDraft() {
    return _draftPlan.copyWith(
      reasons: _parseLines(_reasonsController.text),
      primaryReason:
          _primaryReasonController.text.trim(),
      triggers: _parseLines(_triggersController.text),
      dangerWindows:
          _parseLines(_dangerWindowsController.text),
      redirectActions:
          _parseLines(_redirectActionsController.text),
      trustedSupportName:
          _trustedSupportController.text.trim(),
      phoneBoundary:
          _phoneBoundaryController.text.trim(),
      bedtimeStrategy:
          _bedtimeStrategyController.text.trim(),
      afterSlipReset:
          _afterSlipResetController.text.trim(),
      faithSupport:
          _faithSupportController.text.trim(),
    );
  }

  String _editableSignature(PersonalRecoveryPlan plan) {
    return <String>[
      plan.reasons.join('|').toLowerCase(),
      plan.primaryReason.trim().toLowerCase(),
      plan.triggers.join('|').toLowerCase(),
      plan.dangerWindows.join('|').toLowerCase(),
      plan.redirectActions.join('|').toLowerCase(),
      plan.trustedSupportName.trim().toLowerCase(),
      plan.phoneBoundary.trim(),
      plan.bedtimeStrategy.trim(),
      plan.afterSlipReset.trim(),
      plan.faithSupport.trim(),
    ].join('§');
  }

  Future<PersonalRecoveryPlan>
      _refreshFromBreakWave(
    PersonalRecoveryPlan current,
  ) async {
    final reasons =
        await ReasonsStore.loadSelection();
    final triggers =
        await TriggersStore.loadSelection();
    final contact =
        await SupportContactStore.loadContact();
    final customWhy =
        await CustomWhyStore.load();
    final entries =
        await _logRepository.loadEntries();

    final snapshot =
        _insightsCalculator.calculate(
      entries: entries,
      now: DateTime.now(),
    );

    final List<String> observedTriggers =
        snapshot.topTriggers30Days
            .map((item) => item.trigger)
            .where((String value) {
      final String key =
          value.trim().toLowerCase();

      return key != 'rescue completion' &&
          key != 'wave timer';
    }).toList();

    final List<String> observedDangerWindows =
        <String>[
      if (snapshot.busiestWeekday30Days != null)
        snapshot.busiestWeekday30Days!,
      if (snapshot.busiestTimeWindow30Days != null)
        snapshot.busiestTimeWindow30Days!,
    ];

    return _prefill.refreshFromCurrentChoices(
      current: current,
      reasonsSelection: reasons,
      triggersSelection: triggers,
      supportContact: contact,
      customWhy: customWhy,
      observedTriggers: observedTriggers,
      observedDangerWindows:
          observedDangerWindows,
    );
  }

  Future<void> _importCurrentChoices() async {
    if (_importing) return;

    setState(() {
      _importing = true;
      _statusMessage = null;
    });

    try {
      final PersonalRecoveryPlan current =
          _currentDraft();

      final PersonalRecoveryPlan imported =
          await _refreshFromBreakWave(current);

      if (!mounted) return;

      final bool changed =
          _editableSignature(imported) !=
              _editableSignature(current);

      if (changed) {
        _applyPlan(imported, dirty: true);
      }

      setState(() {
        _importing = false;
        _sourceUpdateAvailable = false;
        _statusMessage = changed
            ? 'Current BreakWave choices and recent log patterns were added or refreshed. Custom plan work was preserved. Review the plan, then save.'
            : 'Your plan already matches the latest saved choices '
                'and recent log patterns. Custom plan work was '
                'not replaced.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _importing = false;
        _statusMessage =
            'BreakWave could not import your saved choices '
            'right now. Your plan was not changed.';
      });
    }
  }

  Future<void> _savePlan() async {
    if (_saving) return;

    final PersonalRecoveryPlan draft = _currentDraft();

    if (!draft.hasAnyContent) {
      setState(() {
        _statusMessage =
            'Add at least one useful part of your plan '
            'before saving.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    try {
      final PersonalRecoveryPlan saved =
          draft.preparedForSave(DateTime.now());

      await PersonalRecoveryPlanStore.save(saved);

      if (!mounted) return;

      setState(() {
        _savedPlan = saved;
        _draftPlan = saved;
        _saving = false;
        _dirty = false;
        _sourceUpdateAvailable = false;
        _statusMessage =
            'Personal recovery plan saved on this device.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _statusMessage =
            'BreakWave could not save your plan right now. '
            'Your draft is still on this screen.';
      });
    }
  }

  void _toggleSuggestion(
    TextEditingController controller,
    String value,
  ) {
    final List<String> items =
        _parseLines(controller.text);

    final int existingIndex = items.indexWhere(
      (String item) =>
          item.toLowerCase() == value.toLowerCase(),
    );

    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    } else {
      items.add(value);
    }

    _writeLines(controller, items);
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;

    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Discard unsaved changes?'),
          content: const Text(
            'Your last saved recovery plan will remain, '
            'but changes made on this screen will be lost.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Keep editing'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Discard changes'),
            ),
          ],
        );
      },
    );

    return discard == true;
  }

  String _updatedLabel() {
    final String raw = _savedPlan?.updatedAtIso ?? '';
    final DateTime? parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return 'Not saved yet';
    }

    final DateTime local = parsed.toLocal();
    final String month =
        local.month.toString().padLeft(2, '0');
    final String day =
        local.day.toString().padLeft(2, '0');
    final String hour =
        local.hour.toString().padLeft(2, '0');
    final String minute =
        local.minute.toString().padLeft(2, '0');

    return 'Last saved $month/$day/${local.year} '
        'at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmLeave,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My recovery plan'),
        ),
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle('Plan unavailable'),
                const SizedBox(height: 10),
                Text(_loadError!),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _loadPlan();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: <Widget>[
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Build a plan you can actually use',
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect what matters, what starts the wave, '
                'and what you will do next. Your plan stays '
                'on this device.',
              ),
              const SizedBox(height: 12),
              Text(
                _dirty
                    ? 'Unsaved changes'
                    : _sourceUpdateAvailable
                        ? 'New BreakWave choices are available'
                        : _updatedLabel(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Use my current BreakWave choices',
              ),
              const SizedBox(height: 8),
              const Text(
                'Refresh imported parts using your saved reasons, '
                'triggers, risky times, trusted support name, saved Why, '
                'and recent log patterns. Existing plan work will not be replaced.',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _importing
                      ? null
                      : _importCurrentChoices,
                  icon: const Icon(Icons.auto_fix_high),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text(
                      _importing
                          ? 'Refreshing plan...'
                          : 'Refresh from current BreakWave choices',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle('Why I am changing'),
              const SizedBox(height: 10),
              TextField(
                controller: _primaryReasonController,
                decoration: const InputDecoration(
                  labelText: 'My main reason',
                  hintText:
                      'The reason I want in front of me first',
                ),
                textCapitalization:
                    TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              _ListPlanField(
                title: 'Reasons that matter',
                helper:
                    'Choose suggestions or enter one reason per line.',
                controller: _reasonsController,
                suggestions: _reasonSuggestions,
                onToggleSuggestion: (String value) =>
                    _toggleSuggestion(
                  _reasonsController,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle('What I need to watch'),
              const SizedBox(height: 12),
              _ListPlanField(
                title: 'Known triggers',
                helper:
                    'Choose suggestions or enter one trigger per line.',
                controller: _triggersController,
                suggestions: _triggerSuggestions,
                onToggleSuggestion: (String value) =>
                    _toggleSuggestion(
                  _triggersController,
                  value,
                ),
              ),
              const SizedBox(height: 18),
              _ListPlanField(
                title: 'Danger windows',
                helper:
                    'Times or situations when extra protection helps.',
                controller: _dangerWindowsController,
                suggestions: _dangerWindowSuggestions,
                onToggleSuggestion: (String value) =>
                    _toggleSuggestion(
                  _dangerWindowsController,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle('My first moves'),
              const SizedBox(height: 10),
              _ListPlanField(
                title: 'Redirect actions',
                helper:
                    'Choose actions you can take before momentum builds.',
                controller: _redirectActionsController,
                suggestions: _redirectSuggestions,
                onToggleSuggestion: (String value) =>
                    _toggleSuggestion(
                  _redirectActionsController,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(
                'Support and boundaries',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _trustedSupportController,
                decoration: const InputDecoration(
                  labelText: 'Trusted support person',
                  hintText: 'Name only',
                  helperText:
                      'Calling and messaging details remain in Support.',
                ),
                textCapitalization:
                    TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneBoundaryController,
                decoration: const InputDecoration(
                  labelText: 'Phone or environment boundary',
                  hintText:
                      'Example: Charge my phone outside the bedroom.',
                ),
                minLines: 2,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _bedtimeStrategyController,
                decoration: const InputDecoration(
                  labelText: 'Bedtime strategy',
                  hintText:
                      'Example: Phone away, lights out, read for ten minutes.',
                ),
                minLines: 2,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle('After a slip'),
              const SizedBox(height: 10),
              const Text(
                'Write the next honest steps—not a punishment.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _afterSlipResetController,
                decoration: const InputDecoration(
                  labelText: 'My reset plan',
                  hintText:
                      'Example: Stop, tell the truth, log what happened, and restart.',
                ),
                minLines: 3,
                maxLines: 6,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        if (_mode == RecoveryMode.christian) ...<Widget>[
          const SizedBox(height: 16),
          _PlanCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle('Faith support'),
                const SizedBox(height: 10),
                const Text(
                  'Add prayer, Scripture, or a faithful next '
                  'step you want available when the wave rises.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _faithSupportController,
                  decoration: const InputDecoration(
                    labelText: 'My faith-based support plan',
                    hintText:
                        'Example: Pray honestly, read my saved verse, and contact support.',
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization:
                      TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ],
        if (_statusMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          _PlanCard(
            child: Text(
              _statusMessage!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                _saving || (!_dirty && _savedPlan != null)
                    ? null
                    : _savePlan,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                _saving
                    ? 'Saving...'
                    : (!_dirty && _savedPlan != null)
                        ? 'Plan saved'
                        : 'Save recovery plan',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListPlanField extends StatelessWidget {
  const _ListPlanField({
    required this.title,
    required this.helper,
    required this.controller,
    required this.suggestions,
    required this.onToggleSuggestion,
  });

  final String title;
  final String helper;
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onToggleSuggestion;

  List<String> get _selected {
    return controller.text
        .split(RegExp(r'[\n,]'))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
  }

  bool _contains(String suggestion) {
    return _selected.any(
      (String value) =>
          value.toLowerCase() ==
          suggestion.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(helper),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map(
                (String suggestion) {
                  return FilterChip(
                    label: Text(suggestion),
                    selected: _contains(suggestion),
                    onSelected: (_) =>
                        onToggleSuggestion(suggestion),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Your list',
                hintText: 'One item per line',
              ),
              minLines: 2,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
