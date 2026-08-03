// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: teach_me_breakwave_entry_card.dart
// Purpose: Replayable Support entry for the BreakWave tutorial.
// Notes: BW-ONBOARD-01B1 keeps the tutorial free and optional.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/tutorial/breakwave_tutorial_state.dart';
import '../../../../core/tutorial/breakwave_tutorial_state_store.dart';
import '../../../tutorial/presentation/teach_me_breakwave_screen.dart';

class TeachMeBreakWaveEntryCard extends StatefulWidget {
  const TeachMeBreakWaveEntryCard({super.key});

  @override
  State<TeachMeBreakWaveEntryCard> createState() =>
      _TeachMeBreakWaveEntryCardState();
}

class _TeachMeBreakWaveEntryCardState
    extends State<TeachMeBreakWaveEntryCard> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final BreakWaveTutorialState state =
          await BreakWaveTutorialStateStore.load();
      if (!mounted) return;
      setState(() {
        _completed = state.completed;
      });
    } catch (_) {
      // The entry remains usable even if completion state cannot be read.
    }
  }

  Future<void> _openTutorial() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const TeachMeBreakWaveScreen(),
      ),
    );
    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      key: const Key('teach-me-breakwave-entry-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Teach Me How to Use BreakWave',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_completed)
                const Icon(
                  Icons.check_circle,
                  semanticLabel: 'Tutorial completed',
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Take a short, replayable tour of Rescue, Home, Log, recovery tools, privacy, and BreakWave Plus.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _openTutorial,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  _completed ? 'Review quick tour' : 'Start quick tour',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
