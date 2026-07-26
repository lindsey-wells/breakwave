// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: premium_gate_tile.dart
// Purpose: Feature-aware BreakWave Plus gate helper.
// Notes: Presentation delegates access decisions to the
//        centralized BreakWaveAccessService.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/access/breakwave_access_decision.dart';
import '../../../core/access/breakwave_access_service.dart';
import '../../../core/access/breakwave_feature.dart';
import 'breakwave_plus_screen.dart';

class PremiumGateTile extends StatefulWidget {
  const PremiumGateTile({
    super.key,
    required this.feature,
    required this.title,
    required this.description,
    this.unlockedText = 'Available in BreakWave Plus',
    this.onUnlockedTap,
    this.accessService =
        BreakWaveAccessService.localTesting,
  });

  final BreakWaveFeature feature;
  final String title;
  final String description;
  final String unlockedText;
  final VoidCallback? onUnlockedTap;
  final BreakWaveAccessService accessService;

  @override
  State<PremiumGateTile> createState() =>
      _PremiumGateTileState();
}

class _PremiumGateTileState
    extends State<PremiumGateTile> {
  bool _loading = true;
  BreakWaveAccessDecision? _decision;

  @override
  void initState() {
    super.initState();
    widget.accessService.changes.addListener(
      _handleEntitlementChange,
    );
    _load();
  }

  @override
  void dispose() {
    widget.accessService.changes.removeListener(
      _handleEntitlementChange,
    );
    super.dispose();
  }

  void _handleEntitlementChange() {
    _load();
  }

  Future<void> _load() async {
    final BreakWaveAccessDecision decision =
        await widget.accessService.decisionFor(
      widget.feature,
    );

    if (!mounted) return;

    setState(() {
      _decision = decision;
      _loading = false;
    });
  }

  Future<void> _handleTap() async {
    if (_loading) return;

    if (_decision?.isAvailable == true) {
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
    final ColorScheme colorScheme =
        theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _handleTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme
              .surfaceContainerHighest
              .withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style:
                        theme.textTheme.titleMedium?.copyWith(
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
                    _decision?.isAvailable == true
                        ? 'Unlocked'
                        : widget.unlockedText,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
