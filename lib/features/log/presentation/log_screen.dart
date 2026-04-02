// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: log_screen.dart
// Purpose: BW-04 log foundation screen for BreakWave.
// Notes: Neutral logging scaffold for BW-06.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/ui/wave_surface.dart';
import 'widgets/log_entry_type_section.dart';
import 'widgets/log_intensity_section.dart';
import 'widgets/log_notes_card.dart';
import 'widgets/log_save_card.dart';
import 'widgets/log_trigger_chips_section.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String _entryType = 'Urge';
  int _intensity = 3;
  final Set<String> _selectedTriggers = <String>{};
  late final TextEditingController _notesController;

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
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

  void _saveEntry() {
    final String notes = _notesController.text.trim();
    final String triggerSummary = _selectedTriggers.isEmpty
        ? 'No triggers selected'
        : _selectedTriggers.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved $_entryType entry • intensity $_intensity • $triggerSummary${notes.isEmpty ? '' : ' • notes added'}',
        ),
      ),
    );
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
