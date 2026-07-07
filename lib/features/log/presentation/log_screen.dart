// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_screen.dart
// Purpose: BW-04 log foundation screen for BreakWave.
// Notes: BW-72B declutters Log capture and adds lightweight Other inputs.
// Notes: BW-76B keeps Log save/update confirmation on the Log tab.
// Notes: BW-76C adds undo for accidental recent-log deletion.
// Notes: BW-76D turns key replacement choices into real navigation actions.
// Notes: BW-84A improves Log review scope, edit clarity, and delete undo timing.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../../../core/ui/breakwave_app_bar.dart';
import '../data/log_repository.dart';
import '../domain/log_entry.dart';
import 'widgets/log_entry_type_section.dart';
import 'widgets/log_intensity_section.dart';
import 'widgets/log_notes_card.dart';
import 'widgets/log_save_card.dart';
import 'widgets/log_trigger_chips_section.dart';
import 'widgets/log_cbt_reflection_card.dart';
import 'widgets/recent_log_entries_card.dart';

class LogScreen extends StatefulWidget {
  final VoidCallback onReturnHome;
  final VoidCallback onOpenRescue;
  final VoidCallback onOpenSupport;

  const LogScreen({
    super.key,
    required this.onReturnHome,
    required this.onOpenRescue,
    required this.onOpenSupport,
  });

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final LogRepository _repository = const LogRepository();

  late final ScrollController _scrollController;

  String _entryType = 'Urge';
  int _intensity = 3;
  final Set<String> _selectedTriggers = <String>{};
  String? _selectedReplacementAction;

  late final TextEditingController _otherTriggerController;
  late final TextEditingController _thoughtController;
  late final TextEditingController _otherReplacementActionController;
  late final TextEditingController _actionTakenController;
  late final TextEditingController _consequenceController;
  late final TextEditingController _betterPlanController;
  late final TextEditingController _notesController;

  int _savedEntryCount = 0;
  bool _isSaving = false;
  List<LogEntry> _recentEntries = const <LogEntry>[];
  String? _editingEntryId;
  String? _lastSaveMessage;
  bool _showAllEntries = false;
  int _deleteSnackBarSerial = 0;

  static const String _otherLabel = 'Other';

  static const List<String> _availableTriggers = <String>[
    'Stress',
    'Boredom',
    'Lonely',
    'Habit',
    'Tired',
    'Environment',
    _otherLabel,
  ];

  static const List<String> _healthyReplacementActions = <String>[
    'Open Rescue',
    'Leave the room',
    'Text someone safe',
    'Take a short walk',
    'Cold water reset',
    'Put the phone down',
    'Move to public space',
    'Charge phone away from bed',
    'Journal one line',
    'Pray for one minute',
    _otherLabel,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _otherTriggerController = TextEditingController();
    _thoughtController = TextEditingController();
    _otherReplacementActionController = TextEditingController();
    _actionTakenController = TextEditingController();
    _consequenceController = TextEditingController();
    _betterPlanController = TextEditingController();
    _notesController = TextEditingController();
    _refreshFromStorage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _otherTriggerController.dispose();
    _thoughtController.dispose();
    _otherReplacementActionController.dispose();
    _actionTakenController.dispose();
    _consequenceController.dispose();
    _betterPlanController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _refreshFromStorage() async {
    try {
      final List<LogEntry> entries = await _repository.loadEntries();
      if (!mounted) return;
      setState(() {
        _savedEntryCount = entries.length;
        _recentEntries = entries.take(5).toList();
      });
    } catch (_) {}
  }

  List<LogEntry> _visibleEntries(List<LogEntry> entries) {
    if (_showAllEntries) {
      return entries;
    }

    return entries.take(5).toList();
  }

  Future<void> _toggleShowAllEntries() async {
    final bool nextShowAllEntries = !_showAllEntries;
    final List<LogEntry> entries = await _repository.loadEntries();

    if (!mounted) return;

    setState(() {
      _showAllEntries = nextShowAllEntries;
      _savedEntryCount = entries.length;
      _recentEntries = nextShowAllEntries ? entries : entries.take(5).toList();
    });
  }

  void _setEntryType(String value) {
    setState(() {
      _entryType = value;
    });
  }

  void _setIntensity(int value) {
    setState(() {
      _intensity = value;
    });
  }

  void _toggleTrigger(String value) {
    setState(() {
      if (_selectedTriggers.contains(value)) {
        _selectedTriggers.remove(value);
        if (value == _otherLabel) {
          _otherTriggerController.clear();
        }
      } else {
        _selectedTriggers.add(value);
      }
    });
  }

  void _setReplacementAction(String? value) {
    setState(() {
      _selectedReplacementAction = value;
      if (value != _otherLabel) {
        _otherReplacementActionController.clear();
      }
    });
  }

  List<String> _resolvedTriggers() {
    final List<String> triggers = _selectedTriggers
        .where((String trigger) => trigger != _otherLabel)
        .toList();

    if (_selectedTriggers.contains(_otherLabel)) {
      final String customTrigger = _otherTriggerController.text.trim();
      triggers.add(customTrigger.isEmpty ? _otherLabel : 'Other: $customTrigger');
    }

    return triggers;
  }

  String _resolvedReplacementAction() {
    if (_selectedReplacementAction == _otherLabel) {
      final String customAction = _otherReplacementActionController.text.trim();
      return customAction.isEmpty ? _otherLabel : customAction;
    }

    return _selectedReplacementAction ?? '';
  }

  void _populateDraftFromEntry(LogEntry entry) {
    setState(() {
      _lastSaveMessage = null;
      _editingEntryId = entry.id;
      _entryType = entry.entryType;
      _intensity = entry.intensity;

      _selectedTriggers.clear();
      _otherTriggerController.clear();
      for (final String trigger in entry.triggers) {
        if (trigger.startsWith('Other: ')) {
          _selectedTriggers.add(_otherLabel);
          _otherTriggerController.text = trigger.substring('Other: '.length);
        } else if (_availableTriggers.contains(trigger)) {
          _selectedTriggers.add(trigger);
        } else if (trigger.trim().isNotEmpty) {
          _selectedTriggers.add(_otherLabel);
          _otherTriggerController.text = trigger;
        }
      }

      final String replacementAction = entry.replacementAction.trim();
      _otherReplacementActionController.clear();
      if (replacementAction.isEmpty) {
        _selectedReplacementAction = null;
      } else if (_healthyReplacementActions.contains(replacementAction) &&
          replacementAction != _otherLabel) {
        _selectedReplacementAction = replacementAction;
      } else {
        _selectedReplacementAction = _otherLabel;
        _otherReplacementActionController.text =
            replacementAction == _otherLabel ? '' : replacementAction;
      }

      _thoughtController.text = entry.thought;
      _actionTakenController.text = entry.actionTaken;
      _consequenceController.text = entry.consequence;
      _betterPlanController.text = entry.betterPlan;
      _notesController.text = entry.notes;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _clearDraft() {
    _editingEntryId = null;
    _entryType = 'Urge';
    _intensity = 3;
    _selectedTriggers.clear();
    _selectedReplacementAction = null;
    _otherTriggerController.clear();
    _thoughtController.clear();
    _otherReplacementActionController.clear();
    _actionTakenController.clear();
    _consequenceController.clear();
    _betterPlanController.clear();
    _notesController.clear();
  }

  void _cancelEdit() {
    setState(() {
      _clearDraft();
      _lastSaveMessage = 'Edit canceled. New draft started.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit canceled. New draft started.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEditingStatusBanner(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.edit_note_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Editing saved entry',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Changes will update this saved log entry instead of creating a new one.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _cancelEdit,
            icon: const Icon(Icons.close_outlined),
            label: const Text('Cancel edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _undoDeleteEntry(LogEntry entry) async {
    _deleteSnackBarSerial++;
    await _repository.saveEntry(entry);
    await _refreshFromStorage();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restored log entry.'),
      ),
    );
  }

  Future<void> _deleteEntry(LogEntry entry) async {
    await _repository.deleteEntry(entry.id);

    if (!mounted) return;

    if (_editingEntryId == entry.id) {
      setState(_clearDraft);
    }

    await _refreshFromStorage();

    if (!mounted) return;

    _deleteSnackBarSerial++;
    final int snackBarSerial = _deleteSnackBarSerial;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Deleted log entry. Undo available briefly.'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _undoDeleteEntry(entry),
          ),
        ),
      );

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || _deleteSnackBarSerial != snackBarSerial) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  Future<void> _saveEntry() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final String savedType = _entryType;
      final String? editingId = _editingEntryId;
      final List<String> resolvedTriggers = _resolvedTriggers();
      final String replacementActionForSave = _resolvedReplacementAction();

      final LogEntry entry = LogEntry(
        id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        entryType: savedType,
        intensity: _intensity,
        triggers: resolvedTriggers,
        thought: _thoughtController.text.trim(),
        actionTaken: _actionTakenController.text.trim(),
        consequence: _consequenceController.text.trim(),
        betterPlan: _betterPlanController.text.trim(),
        replacementAction: replacementActionForSave,
        notes: _notesController.text.trim(),
        createdAtIso: DateTime.now().toIso8601String(),
      );

      if (editingId == null) {
        await _repository.saveEntry(entry);
      } else {
        await _repository.updateEntry(entry);
      }

      final List<LogEntry> entries = await _repository.loadEntries();

      if (!mounted) return;

      final String saveMessage = editingId == null
          ? '$savedType entry saved. You can review it below.'
          : '$savedType entry updated. You can review it below.';

      setState(() {
        _savedEntryCount = entries.length;
        _recentEntries = entries.take(5).toList();
        _clearDraft();
        _lastSaveMessage = saveMessage;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveMessage),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save the entry right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _editingEntryId != null;

    return Scaffold(
      appBar: const BreakWaveAppBar(sectionTitle: 'Log'),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const WaveSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Pattern Log',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Turn blur into something visible.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Blue clarity, honest pattern-tracking, and simple reflection belong here.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saved locally on this device: $_savedEntryCount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (isEditing) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Editing a saved entry',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  LogEntryTypeSection(
                    selectedType: _entryType,
                    onSelected: _setEntryType,
                  ),
                  const SizedBox(height: 16),
                  LogIntensitySection(
                    selectedIntensity: _intensity,
                    onSelected: _setIntensity,
                  ),
                  const SizedBox(height: 16),
                  LogTriggerChipsSection(
                    availableTriggers: _availableTriggers,
                    selectedTriggers: _selectedTriggers,
                    onToggle: _toggleTrigger,
                    otherTriggerController: _otherTriggerController,
                    showOtherTriggerField:
                        _selectedTriggers.contains(_otherLabel),
                  ),
                  const SizedBox(height: 16),
                  LogCbtReflectionCard(
                    thoughtController: _thoughtController,
                    actionTakenController: _actionTakenController,
                    consequenceController: _consequenceController,
                    betterPlanController: _betterPlanController,
                    replacementActions: _healthyReplacementActions,
                    selectedReplacementAction: _selectedReplacementAction,
                    onReplacementSelected: _setReplacementAction,
                    otherReplacementActionController:
                        _otherReplacementActionController,
                    showOtherReplacementField:
                        _selectedReplacementAction == _otherLabel,
                    onOpenRescue: widget.onOpenRescue,
                    onOpenSupport: widget.onOpenSupport,
                  ),
                  const SizedBox(height: 16),
                  LogNotesCard(
                    controller: _notesController,
                  ),
                  const SizedBox(height: 16),
                    LogSaveCard(
                      entryType: _entryType,
                      intensity: _intensity,
                      triggerCount: _resolvedTriggers().length,
                      savedEntryCount: _savedEntryCount,
                      isSaving: _isSaving,
                      isEditing: isEditing,
                      lastSaveMessage: _lastSaveMessage,
                      onSave: _saveEntry,
                      onCancelEdit: _cancelEdit,
                    ),
                  const SizedBox(height: 16),
                  RecentLogEntriesCard(
                      entries: _recentEntries,
                      totalEntryCount: _savedEntryCount,
                      showAllEntries: _showAllEntries,
                      onToggleShowAll: _toggleShowAllEntries,
                      onEdit: _populateDraftFromEntry,
                      onDelete: _deleteEntry,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
