// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_screen.dart
// Purpose: BW-04 log foundation screen for BreakWave.
// Notes: BW-08 recent log history surface.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import '../data/log_repository.dart';
import '../domain/log_entry.dart';
import 'widgets/log_entry_type_section.dart';
import 'widgets/log_intensity_section.dart';
import 'widgets/log_notes_card.dart';
import 'widgets/log_save_card.dart';
import 'widgets/log_trigger_chips_section.dart';
import 'widgets/recent_log_entries_card.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final LogRepository _repository = const LogRepository();

  String _entryType = 'Urge';
  int _intensity = 3;
  final Set<String> _selectedTriggers = <String>{};
  late final TextEditingController _notesController;

  int _savedEntryCount = 0;
  bool _isSaving = false;
  List<LogEntry> _recentEntries = const <LogEntry>[];

  static const List<String> _availableTriggers = <String>[
    'Stress',
    'Boredom',
    'Lonely',
    'Habit',
    'Tired',
    'Environment',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadSavedEntryCount();
    _loadRecentEntries();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEntryCount() async {
    try {
      final int count = await _repository.entryCount();
      if (!mounted) return;
      setState(() {
        _savedEntryCount = count;
      });
    } catch (_) {}
  }

  Future<void> _loadRecentEntries() async {
    try {
      final List<LogEntry> entries = await _repository.loadEntries();
      if (!mounted) return;
      setState(() {
        _recentEntries = entries.take(5).toList();
      });
    } catch (_) {}
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
      } else {
        _selectedTriggers.add(value);
      }
    });
  }

  Future<void> _saveEntry() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final String savedType = _entryType;

      final LogEntry entry = LogEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        entryType: savedType,
        intensity: _intensity,
        triggers: _selectedTriggers.toList(),
        notes: _notesController.text.trim(),
        createdAtIso: DateTime.now().toIso8601String(),
      );

      await _repository.saveEntry(entry);
      final List<LogEntry> entries = await _repository.loadEntries();

      if (!mounted) return;

      setState(() {
        _savedEntryCount = entries.length;
        _recentEntries = entries.take(5).toList();
        _entryType = 'Urge';
        _intensity = 3;
        _selectedTriggers.clear();
        _notesController.clear();
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved $savedType entry locally • ${entries.length} total on this device',
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 16),
                  RecentLogEntriesCard(
                    entries: _recentEntries,
                  ),
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
                  ),
                  const SizedBox(height: 16),
                  LogNotesCard(
                    controller: _notesController,
                  ),
                  const SizedBox(height: 16),
                  LogSaveCard(
                    entryType: _entryType,
                    intensity: _intensity,
                    triggerCount: _selectedTriggers.length,
                    savedEntryCount: _savedEntryCount,
                    isSaving: _isSaving,
                    onSave: _saveEntry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
