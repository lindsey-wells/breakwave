import 'package:flutter/material.dart';

import '../../../core/triggers/triggers_selection.dart';
import '../../../core/triggers/triggers_store.dart';

class TriggersRiskyTimesScreen extends StatefulWidget {
  const TriggersRiskyTimesScreen({super.key});

  @override
  State<TriggersRiskyTimesScreen> createState() => _TriggersRiskyTimesScreenState();
}

class _TriggersRiskyTimesScreenState extends State<TriggersRiskyTimesScreen> {
  static const List<String> _presetTriggers = <String>[
    'Stress',
    'Conflict',
    'Loneliness',
    'Boredom',
    'Scrolling',
    'Fatigue',
    'Shame spiral',
  ];

  static const List<String> _presetRiskyTimes = <String>[
    'Late night',
    'When alone',
    'After stress',
    'After conflict',
    'Bored and scrolling',
  ];

  final TextEditingController _customTriggerController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  List<String> _selectedTriggers = <String>[];
  List<String> _selectedRiskyTimes = <String>[];

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  @override
  void dispose() {
    _customTriggerController.dispose();
    super.dispose();
  }

  Future<void> _loadSelection() async {
    final selection = await TriggersStore.loadSelection();
    if (!mounted) return;

    setState(() {
      _selectedTriggers = List<String>.from(selection.selectedTriggers);
      _selectedRiskyTimes = List<String>.from(selection.selectedRiskyTimes);
      _loading = false;
    });
  }

  void _toggleTrigger(String trigger, bool selected) {
    final updated = List<String>.from(_selectedTriggers);
    if (selected) {
      if (!updated.contains(trigger)) {
        updated.add(trigger);
      }
    } else {
      updated.remove(trigger);
    }

    setState(() {
      _selectedTriggers = updated;
    });
  }

  void _toggleRiskyTime(String riskyTime, bool selected) {
    final updated = List<String>.from(_selectedRiskyTimes);
    if (selected) {
      if (!updated.contains(riskyTime)) {
        updated.add(riskyTime);
      }
    } else {
      updated.remove(riskyTime);
    }

    setState(() {
      _selectedRiskyTimes = updated;
    });
  }

  void _addCustomTrigger() {
    final text = _customTriggerController.text.trim();
    if (text.isEmpty) return;
    if (_selectedTriggers.contains(text)) {
      _customTriggerController.clear();
      return;
    }

    setState(() {
      _selectedTriggers = List<String>.from(_selectedTriggers)..add(text);
    });

    _customTriggerController.clear();
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    await TriggersStore.saveSelection(
      TriggersSelection(
        selectedTriggers: _selectedTriggers,
        selectedRiskyTimes: _selectedRiskyTimes,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final customTriggers = _selectedTriggers
        .where((trigger) => !_presetTriggers.contains(trigger))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triggers and risky times'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text(
              'Mark what usually starts the wave or makes it easier to drift.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This is not about perfection. It is about seeing the patterns earlier.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Common triggers',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final trigger in _presetTriggers)
                  FilterChip(
                    label: Text(trigger),
                    selected: _selectedTriggers.contains(trigger),
                    onSelected: (selected) => _toggleTrigger(trigger, selected),
                  ),
                for (final trigger in customTriggers)
                  FilterChip(
                    label: Text(trigger),
                    selected: true,
                    onSelected: (selected) => _toggleTrigger(trigger, selected),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customTriggerController,
              decoration: const InputDecoration(
                labelText: 'Add a custom trigger',
                hintText: 'Example: Unstructured evenings',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addCustomTrigger(),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _addCustomTrigger,
              child: const Text('Add custom trigger'),
            ),
            const SizedBox(height: 28),
            Text(
              'Risky times',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final riskyTime in _presetRiskyTimes)
                  FilterChip(
                    label: Text(riskyTime),
                    selected: _selectedRiskyTimes.contains(riskyTime),
                    onSelected: (selected) => _toggleRiskyTime(riskyTime, selected),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_saving ? 'Saving...' : 'Save and return Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
