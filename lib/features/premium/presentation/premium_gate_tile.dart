// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: premium_gate_tile.dart
// Purpose: BW-25 premium gate helper.
// Notes: Simple tile that routes locked depth features into BreakWave Plus.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/premium/premium_state.dart';
import '../../../core/premium/premium_state_store.dart';
import 'breakwave_plus_screen.dart';

class PremiumGateTile extends StatefulWidget {
  const PremiumGateTile({
    super.key,
    required this.title,
    required this.description,
    this.unlockedText = 'Available in BreakWave Plus',
    this.onUnlockedTap,
  });

  final String title;
  final String description;
  final String unlockedText;
  final VoidCallback? onUnlockedTap;

  @override
  State<PremiumGateTile> createState() => _PremiumGateTileState();
}

class _PremiumGateTileState extends State<PremiumGateTile> {
  bool _loading = true;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    PremiumStateStore.changes.addListener(_handleStoreChange);
    _load();
  }

  @override
  void dispose() {
    PremiumStateStore.changes.removeListener(_handleStoreChange);
    super.dispose();
  }

  void _handleStoreChange() {
    _load();
  }

  Future<void> _load() async {
    final PremiumState state = await PremiumStateStore.load();
    if (!mounted) return;

    setState(() {
      _isUnlocked = state.isPlusUnlocked;
      _loading = false;
    });
  }

  Future<void> _handleTap() async {
    if (_loading) return;

    if (_isUnlocked) {
      widget.onUnlockedTap?.call();
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const BreakWavePlusScreen(),
      ),
    );

    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _handleTap,
      child: Ink(
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
                children: <Widget>[
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isUnlocked ? 'Unlocked' : widget.unlockedText,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
