import 'package:flutter/material.dart';

import '../../../core/reasons/reasons_store.dart';
import 'reasons_to_change_screen.dart';

class ReasonsFocusCard extends StatefulWidget {
  const ReasonsFocusCard({super.key});

  @override
  State<ReasonsFocusCard> createState() => _ReasonsFocusCardState();
}

class _ReasonsFocusCardState extends State<ReasonsFocusCard> {
  bool _loading = true;
  String? _currentFocus;
  bool _hasReasons = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final selection = await ReasonsStore.loadSelection();
    if (!mounted) return;

    setState(() {
      _currentFocus = selection.currentFocus;
      _hasReasons = selection.hasReasons;
      _loading = false;
    });
  }

  Future<void> _openReasonsScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ReasonsToChangeScreen(),
      ),
    );

    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current focus',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _currentFocus ??
                      'Choose the reason that matters most right now, so Home stays anchored to something real.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _openReasonsScreen,
                  child: Text(_hasReasons ? 'Edit reasons' : 'Set reasons'),
                ),
              ],
            ),
    );
  }
}
