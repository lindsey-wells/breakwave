import 'package:flutter/material.dart';

import '../../../core/reasons/reasons_selection.dart';
import '../../../core/reasons/reasons_store.dart';

class ReasonsToChangeScreen extends StatefulWidget {
  const ReasonsToChangeScreen({super.key});

  @override
  State<ReasonsToChangeScreen> createState() => _ReasonsToChangeScreenState();
}

class _ReasonsToChangeScreenState extends State<ReasonsToChangeScreen> {
  static const List<String> _presetReasons = [
    'I want mental clarity.',
    'I want to stop feeding shame and secrecy.',
    'I want to protect my relationships.',
    'I want to break the habit loop.',
    'I want to use my time better.',
    'I want to live with integrity.',
  ];

  final TextEditingController _customReasonController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  List<String> _selectedReasons = <String>[];
  String? _currentFocus;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSelection() async {
    final selection = await ReasonsStore.loadSelection();
    if (!mounted) return;

    setState(() {
      _selectedReasons = List<String>.from(selection.selectedReasons);
      _currentFocus = selection.currentFocus;
      _loading = false;
    });
  }

  void _toggleReason(String reason, bool selected) {
    final updated = List<String>.from(_selectedReasons);

    if (selected) {
      if (!updated.contains(reason)) {
        updated.add(reason);
      }
    } else {
      updated.remove(reason);
    }

    String? focus = _currentFocus;
    if (updated.isEmpty) {
      focus = null;
    } else if (focus == null || !updated.contains(focus)) {
      focus = updated.first;
    }

    setState(() {
      _selectedReasons = updated;
      _currentFocus = focus;
    });
  }

  void _addCustomReason() {
    final text = _customReasonController.text.trim();
    if (text.isEmpty) return;
    if (_selectedReasons.contains(text)) {
      _customReasonController.clear();
      return;
    }

    final updated = List<String>.from(_selectedReasons)..add(text);

    setState(() {
      _selectedReasons = updated;
      _currentFocus ??= text;
    });

    _customReasonController.clear();
  }

  Future<void> _save() async {
    if (_selectedReasons.isEmpty || _currentFocus == null || _saving) return;

    setState(() {
      _saving = true;
    });

    final selection = ReasonsSelection(
      selectedReasons: _selectedReasons,
      currentFocus: _currentFocus,
    );

    await ReasonsStore.saveSelection(selection);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reasons to change'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text(
              'Pick the reasons that matter most when the wave starts rising.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose more than one if needed, then set one current focus for Home.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final reason in _presetReasons)
                  FilterChip(
                    label: Text(reason),
                    selected: _selectedReasons.contains(reason),
                    onSelected: (selected) => _toggleReason(reason, selected),
                  ),
                for (final reason in _selectedReasons
                    .where((reason) => !_presetReasons.contains(reason)))
                  FilterChip(
                    label: Text(reason),
                    selected: true,
                    onSelected: (selected) => _toggleReason(reason, selected),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customReasonController,
              decoration: const InputDecoration(
                labelText: 'Add a custom reason',
                hintText: 'Example: I want my evenings back.',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addCustomReason(),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _addCustomReason,
              child: const Text('Add custom reason'),
            ),
            const SizedBox(height: 24),
            Text(
              'Current focus',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_selectedReasons.isEmpty)
              Text(
                'Select at least one reason to set your current focus.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ..._selectedReasons.map(
                (reason) => RadioListTile<String>(
                  value: reason,
                  groupValue: _currentFocus,
                  title: Text(reason),
                  onChanged: (value) {
                    setState(() {
                      _currentFocus = value;
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (_selectedReasons.isEmpty || _currentFocus == null || _saving)
                  ? null
                  : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_saving ? 'Saving...' : 'Save reasons'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
