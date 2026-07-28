// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_screen.dart
// Purpose: Editable, locally saved personal recovery plan.
// Notes: BW-MOD-01F delegates load/import/save orchestration.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../insights/domain/recovery_insights_calculator.dart';
import '../../log/data/log_repository.dart';
import '../application/personal_recovery_plan_session.dart';
import '../application/personal_recovery_plan_workflow.dart';
import '../data/personal_recovery_plan_store.dart';
import '../domain/personal_recovery_plan.dart';
import '../domain/personal_recovery_plan_prefill.dart';
import 'personal_recovery_plan_draft_controllers.dart';
import 'widgets/personal_recovery_plan_body.dart';

class PersonalRecoveryPlanScreen extends StatefulWidget {
  const PersonalRecoveryPlanScreen({super.key});

  @override
  State<PersonalRecoveryPlanScreen> createState() =>
      _PersonalRecoveryPlanScreenState();
}

class _PersonalRecoveryPlanScreenState
    extends State<PersonalRecoveryPlanScreen> {
  late final PersonalRecoveryPlanSession _session;
  late final PersonalRecoveryPlanDraftControllers
      _draftControllers;

  PersonalRecoveryPlan? _savedPlan;
  RecoveryMode _mode = RecoveryMode.secular;

  bool _loading = true;
  bool _saving = false;
  bool _importing = false;
  bool _dirty = false;
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

  @override
  void initState() {
    super.initState();

    final PersonalRecoveryPlanWorkflow workflow =
        PersonalRecoveryPlanWorkflow(
      prefill: const PersonalRecoveryPlanPrefill(),
      logRepository: const LogRepository(),
      insightsCalculator:
          const RecoveryInsightsCalculator(),
    );

    _session = PersonalRecoveryPlanSession(
      workflow: workflow,
      loadPlan: PersonalRecoveryPlanStore.load,
      loadMode: RecoveryModeStore.loadMode,
      savePlan: PersonalRecoveryPlanStore.save,
      now: DateTime.now,
    );

    _draftControllers =
        PersonalRecoveryPlanDraftControllers(
      onChanged: _handleDraftChanged,
    );

    _loadPlan();
  }

  @override
  void dispose() {
    _draftControllers.dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    if (!mounted) return;

    setState(() {
      _dirty = true;
      _statusMessage = null;
    });
  }

  Future<void> _loadPlan() async {
    final PersonalRecoveryPlanLoadResult result =
        await _session.load();
    if (!mounted) return;

    if (!result.succeeded) {
      setState(() {
        _loading = false;
        _loadError = result.errorMessage;
      });
      return;
    }

    _mode = result.mode;
    _savedPlan = result.savedPlan;
    _applyPlan(result.basePlan, dirty: false);

    setState(() {
      _sourceUpdateAvailable =
          result.sourceUpdateAvailable;
      _loading = false;
    });
  }

  void _applyPlan(
    PersonalRecoveryPlan plan, {
    required bool dirty,
  }) {
    _draftControllers.applyPlan(plan);

    if (mounted) {
      setState(() {
        _dirty = dirty;
      });
    } else {
      _dirty = dirty;
    }
  }

  PersonalRecoveryPlan _currentDraft() {
    return _draftControllers.currentDraft();
  }

  Future<void> _importCurrentChoices() async {
    if (_importing) return;

    setState(() {
      _importing = true;
      _statusMessage = null;
    });

    final PersonalRecoveryPlanImportResult result =
        await _session.importCurrentChoices(
      _currentDraft(),
    );
    if (!mounted) return;

    if (result.succeeded && result.changed) {
      _applyPlan(result.plan, dirty: true);
    }

    setState(() {
      _importing = false;
      if (result.succeeded) {
        _sourceUpdateAvailable = false;
      }
      _statusMessage = result.statusMessage;
    });
  }

  Future<void> _savePlan() async {
    if (_saving) return;

    final PersonalRecoveryPlan draft = _currentDraft();

    if (!_session.canSave(draft)) {
      setState(() {
        _statusMessage =
            PersonalRecoveryPlanSession.emptyDraftMessage;
      });
      return;
    }

    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    final PersonalRecoveryPlanSaveResult result =
        await _session.save(draft);
    if (!mounted) return;

    if (result.succeeded && result.savedPlan != null) {
      final PersonalRecoveryPlan saved =
          result.savedPlan!;

      setState(() {
        _savedPlan = saved;
        _draftControllers.updateBasePlan(saved);
        _saving = false;
        _dirty = false;
        _sourceUpdateAvailable = false;
        _statusMessage = result.statusMessage;
      });
      return;
    }

    setState(() {
      _saving = false;
      _statusMessage = result.statusMessage;
    });
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

  void _retryLoadPlan() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _loadPlan();
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
          child: PersonalRecoveryPlanBody(
            loading: _loading,
            loadError: _loadError,
            dirty: _dirty,
            sourceUpdateAvailable:
                _sourceUpdateAvailable,
            updatedLabel: _updatedLabel(),
            importing: _importing,
            saving: _saving,
            hasSavedPlan: _savedPlan != null,
            mode: _mode,
            draftControllers: _draftControllers,
            reasonSuggestions: _reasonSuggestions,
            triggerSuggestions: _triggerSuggestions,
            dangerWindowSuggestions:
                _dangerWindowSuggestions,
            redirectSuggestions: _redirectSuggestions,
            statusMessage: _statusMessage,
            onRetry: _retryLoadPlan,
            onRefresh: _importCurrentChoices,
            onSave: _savePlan,
          ),
        ),
      ),
    );
  }
}
