// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_access_button.dart
// Purpose: Non-authoritative persistent Plus access indicator.
// Notes: Blue = trusted Plus active. Gray = review/upgrade available.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/billing/breakwave_billing_composition.dart';
import '../../../core/billing/breakwave_billing_scope.dart';

class BreakWavePlusAccessButton extends StatefulWidget {
  const BreakWavePlusAccessButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<BreakWavePlusAccessButton> createState() =>
      _BreakWavePlusAccessButtonState();
}

class _BreakWavePlusAccessButtonState
    extends State<BreakWavePlusAccessButton> {
  BreakWaveBillingComposition? _composition;
  bool _active = false;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final BreakWaveBillingComposition composition =
        BreakWaveBillingScope.of(context);

    if (identical(_composition, composition)) return;

    _composition?.entitlementSource.changes
        .removeListener(_handleEntitlementChanged);

    _composition = composition;
    composition.entitlementSource.changes
        .addListener(_handleEntitlementChanged);
    _refresh();
  }

  @override
  void dispose() {
    _composition?.entitlementSource.changes
        .removeListener(_handleEntitlementChanged);
    super.dispose();
  }

  void _handleEntitlementChanged() {
    _refresh();
  }

  Future<void> _refresh() async {
    final BreakWaveBillingComposition? composition = _composition;
    if (composition == null) return;

    bool active = false;
    try {
      active = await composition.entitlementSource.isPlusUnlocked();
    } catch (_) {
      active = false;
    }

    if (!mounted || !identical(_composition, composition)) return;

    setState(() {
      _active = active;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color background =
        _active ? Colors.blue : Colors.grey.shade600;
    final String tooltip = _active
        ? 'BreakWave Plus active'
        : 'Review BreakWave Plus';

    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        elevation: 3,
        child: IconButton(
          key: const Key('breakwave-plus-access-button'),
          onPressed: widget.onPressed,
          tooltip: tooltip,
          icon: _loading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
