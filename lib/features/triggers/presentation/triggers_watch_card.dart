import 'package:flutter/material.dart';

import '../../../core/triggers/triggers_store.dart';
import 'triggers_risky_times_screen.dart';

class TriggersWatchCard extends StatefulWidget {
  const TriggersWatchCard({super.key});

  @override
  State<TriggersWatchCard> createState() => _TriggersWatchCardState();
}

class _TriggersWatchCardState extends State<TriggersWatchCard> {
  bool _loading = true;
  List<String> _triggers = <String>[];
  List<String> _riskyTimes = <String>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final selection = await TriggersStore.loadSelection();
    if (!mounted) return;

    setState(() {
      _triggers = selection.selectedTriggers;
      _riskyTimes = selection.selectedRiskyTimes;
      _loading = false;
    });
  }

  Future<void> _openScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const TriggersRiskyTimesScreen(),
      ),
    );

    if (!mounted) return;
    await _load();
  }

  List<String> _previewItems() {
    final merged = <String>[
      ..._triggers,
      ..._riskyTimes,
    ];

    final preview = <String>[];
    for (final item in merged) {
      if (!preview.contains(item)) {
        preview.add(item);
      }
      if (preview.length == 3) {
        break;
      }
    }
    return preview;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final preview = _previewItems();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch for',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  preview.isEmpty
                      ? 'Set the moments and patterns that usually make you vulnerable.'
                      : preview.join(' • '),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _openScreen,
                  child: Text(preview.isEmpty ? 'Set triggers' : 'Edit triggers'),
                ),
              ],
            ),
    );
  }
}
