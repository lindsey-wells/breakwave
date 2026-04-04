// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: fast_urge_entry_card.dart
// Purpose: BW-14 fast urge entry from Home.
// Notes: Saves a quick urge and routes directly into Rescue.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/ui/wave_surface.dart';
import '../../../log/data/log_repository.dart';
import '../../../log/domain/log_entry.dart';
import '../../../triggers/presentation/triggers_risky_times_screen.dart';

class FastUrgeEntryCard extends StatefulWidget {
  const FastUrgeEntryCard({
    super.key,
    required this.onOpenRescue,
  });

  final VoidCallback onOpenRescue;

  @override
  State<FastUrgeEntryCard> createState() => _FastUrgeEntryCardState();
}

class _FastUrgeEntryCardState extends State<FastUrgeEntryCard> {
  final LogRepository _repository = const LogRepository();

  static const List<String> _quickTriggers = <String>[
    'Stress',
    'Boredom',
    'Lonely',
    'Scrolling',
    'Late night',
  ];

  bool _isSaving = false;

  Future<void> _openQuickEntry() async {
    final _QuickUrgeResult? result = await showModalBottomSheet<_QuickUrgeResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return const _QuickUrgeSheet();
      },
    );

    if (result == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _repository.saveEntry(
        LogEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          entryType: 'Urge',
          intensity: result.intensity,
          triggers: result.trigger == null ? const <String>[] : <String>[result.trigger!],
          notes: 'Quick urge entry from Home.',
          createdAtIso: DateTime.now().toIso8601String(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Urge logged. Moving you into Rescue.'),
        ),
      );

      widget.onOpenRescue();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save that urge right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WaveSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Need help right now?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Log the wave fast and move straight into Rescue.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this when the wave is rising and you do not want extra steps.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSaving ? null : _openQuickEntry,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(_isSaving ? 'Saving...' : 'I feel the wave now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickUrgeSheet extends StatefulWidget {
  const _QuickUrgeSheet();

  @override
  State<_QuickUrgeSheet> createState() => _QuickUrgeSheetState();
}

class _QuickUrgeSheetState extends State<_QuickUrgeSheet> {
  int _intensity = 3;
  String? _selectedTrigger;

  static const List<String> _quickTriggers = <String>[
    'Stress',
    'Boredom',
    'Lonely',
    'Scrolling',
    'Late night',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(
            'Fast urge entry',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture what is happening, then go straight into Rescue.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Intensity',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<Widget>.generate(5, (int index) {
              final int value = index + 1;
              return ChoiceChip(
                label: Text('$value'),
                selected: _intensity == value,
                onSelected: (_) {
                  setState(() {
                    _intensity = value;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          Text(
            'Trigger',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final String trigger in _quickTriggers)
                FilterChip(
                  label: Text(trigger),
                  selected: _selectedTrigger == trigger,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedTrigger = selected ? trigger : null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(
                _QuickUrgeResult(
                  intensity: _intensity,
                  trigger: _selectedTrigger,
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Log urge and open Rescue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickUrgeResult {
  const _QuickUrgeResult({
    required this.intensity,
    required this.trigger,
  });

  final int intensity;
  final String? trigger;
}
