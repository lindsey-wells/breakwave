// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: contextual_first_visit_education.dart
// Purpose: BW-EDU-01A local, dismissible first-visit education.
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BreakWaveEducationSurface {
  rescue,
  log,
  support,
}

class BreakWaveContextualEducationStore {
  const BreakWaveContextualEducationStore._();

  static const String storageKey =
      'bw_contextual_first_visit_dismissed_v1';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<bool> shouldShow(
    BreakWaveEducationSurface surface,
  ) async {
    final SharedPreferences prefs = await _prefs();
    final List<String> dismissed =
        prefs.getStringList(storageKey) ?? const <String>[];

    return !dismissed.contains(surface.name);
  }

  static Future<void> dismiss(
    BreakWaveEducationSurface surface,
  ) async {
    final SharedPreferences prefs = await _prefs();
    final Set<String> dismissed = <String>{
      ...?prefs.getStringList(storageKey),
      surface.name,
    };

    final List<String> values = dismissed.toList()..sort();
    await prefs.setStringList(storageKey, values);
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}

class ContextualFirstVisitEducationCard extends StatefulWidget {
  const ContextualFirstVisitEducationCard({
    super.key,
    required this.surface,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final BreakWaveEducationSurface surface;
  final String eyebrow;
  final String title;
  final String body;

  @override
  State<ContextualFirstVisitEducationCard> createState() =>
      _ContextualFirstVisitEducationCardState();
}

class _ContextualFirstVisitEducationCardState
    extends State<ContextualFirstVisitEducationCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final bool shouldShow =
        await BreakWaveContextualEducationStore.shouldShow(widget.surface);

    if (!mounted) return;

    setState(() {
      _visible = shouldShow;
    });
  }

  Future<void> _dismiss() async {
    await BreakWaveContextualEducationStore.dismiss(widget.surface);

    if (!mounted) return;

    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      key: ValueKey<String>(
        'contextual-first-visit-${widget.surface.name}',
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.primary.withOpacity(0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: ValueKey<String>(
                'contextual-first-visit-got-it-${widget.surface.name}',
              ),
              onPressed: _dismiss,
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}
