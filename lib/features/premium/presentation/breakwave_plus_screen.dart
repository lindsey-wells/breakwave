// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_plus_screen.dart
// Purpose: Customer-facing BreakWave Plus hub and store-owned plan display.
// Notes: Purchase callbacks are never entitlement authority.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/access/breakwave_feature.dart';
import '../../../core/billing/breakwave_billing_composition.dart';
import '../../../core/billing/breakwave_billing_scope.dart';
import '../../faith/domain/christian_recovery_journey.dart';
import '../../faith/presentation/christian_journeys_screen.dart';
import '../../guided_routines/domain/recovery_routine.dart';
import '../../guided_routines/presentation/guided_routines_screen.dart';
import '../../insights/presentation/recovery_insights_screen.dart';
import '../../personal_plan/presentation/personal_recovery_plan_screen.dart';
import '../../recovery_report/presentation/recovery_report_builder_screen.dart';
import '../application/breakwave_plus_controller.dart';

class BreakWavePlusScreen extends StatefulWidget {
  const BreakWavePlusScreen({
    super.key,
    this.onRoutineActionRequested,
    this.controller,
  });

  final ValueChanged<RoutineActionTarget>? onRoutineActionRequested;
  final BreakWavePlusController? controller;

  @override
  State<BreakWavePlusScreen> createState() =>
      _BreakWavePlusScreenState();
}

class _BreakWavePlusScreenState extends State<BreakWavePlusScreen> {
  BreakWavePlusController? _controller;
  bool _ownsController = false;

  BreakWavePlusController get _requiredController => _controller!;

  @override
  void initState() {
    super.initState();
    final BreakWavePlusController? supplied = widget.controller;
    if (supplied != null) {
      _controller = supplied;
      supplied.addListener(_handleControllerChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        supplied.refresh();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;

    final BreakWaveBillingComposition composition =
        BreakWaveBillingScope.of(context);
    final BreakWavePlusController controller =
        BreakWavePlusController.fromComposition(composition);

    _controller = controller;
    _ownsController = true;
    controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refresh();
    });
  }

  @override
  void dispose() {
    final BreakWavePlusController? controller = _controller;
    controller?.removeListener(_handleControllerChanged);
    if (_ownsController) controller?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openFeature(
    BreakWaveFeature feature,
    VoidCallback open,
  ) async {
    final BreakWaveBillingComposition composition =
        BreakWaveBillingScope.of(context);
    final bool allowed =
        await composition.accessService.isAvailable(feature);

    if (!mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'BreakWave Plus access is not currently verified.',
          ),
        ),
      );
      return;
    }
    open();
  }

  void _openRecoveryInsights() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RecoveryInsightsScreen(),
      ),
    );
  }

  void _openPersonalRecoveryPlan() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PersonalRecoveryPlanScreen(),
      ),
    );
  }

  void _openGuidedRoutines() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GuidedRoutinesScreen(
          onActionRequested: widget.onRoutineActionRequested,
        ),
      ),
    );
  }

  void _handleChristianJourneyActionRequested(
    ChristianJourneyActionTarget target,
  ) {
    final ValueChanged<RoutineActionTarget>? handler =
        widget.onRoutineActionRequested;
    if (handler == null) return;

    switch (target) {
      case ChristianJourneyActionTarget.rescue:
        handler(RoutineActionTarget.rescue);
        return;
      case ChristianJourneyActionTarget.personalPlan:
        handler(RoutineActionTarget.personalPlan);
        return;
    }
  }

  void _openChristianJourneys() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChristianJourneysScreen(
          onActionRequested: widget.onRoutineActionRequested == null
              ? null
              : _handleChristianJourneyActionRequested,
        ),
      ),
    );
  }

  void _openRecoveryReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RecoveryReportBuilderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BreakWavePlusSnapshot snapshot = _requiredController.snapshot;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('BreakWave Plus')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _AccessStatusCard(snapshot: snapshot),
            const SizedBox(height: 16),
            if (!snapshot.isPlusUnlocked)
              _PlansCard(
                snapshot: snapshot,
                onMonthly: _requiredController.purchaseMonthly,
                onAnnual: _requiredController.purchaseAnnual,
              ),
            if (!snapshot.isPlusUnlocked) const SizedBox(height: 16),
            _StoreActionsCard(
              snapshot: snapshot,
              onRestore: _requiredController.restorePurchases,
              onRefresh: _requiredController.refresh,
            ),
            const SizedBox(height: 16),
            _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snapshot.isPlusUnlocked
                        ? 'Your Plus recovery tools'
                        : 'What BreakWave Plus adds',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.isPlusUnlocked
                        ? 'Your trusted Plus entitlement is active. Each feature still checks access before opening.'
                        : 'Plus adds deeper repeat-use recovery tools. Rescue, basic recovery support, privacy controls, and your core recovery data remain available without Plus.',
                  ),
                  const SizedBox(height: 16),
                  _FeatureEntry(
                    title: 'Advanced recovery insights',
                    body:
                        '30-day and 90-day history, trigger trends, risky-time patterns, and summaries from your recovery logs.',
                    active: snapshot.isPlusUnlocked,
                    onPressed: () => _openFeature(
                      BreakWaveFeature.advancedRecoveryInsights,
                      _openRecoveryInsights,
                    ),
                  ),
                  _FeatureEntry(
                    title: 'Saved personal recovery plan',
                    body:
                        'A practical plan connecting triggers, danger windows, reasons, redirect actions, trusted support, and reset steps.',
                    active: snapshot.isPlusUnlocked,
                    onPressed: () => _openFeature(
                      BreakWaveFeature.savedPersonalRecoveryPlan,
                      _openPersonalRecoveryPlan,
                    ),
                  ),
                  _FeatureEntry(
                    title: 'Guided recovery routines',
                    body:
                        'Repeatable routines for high-risk moments, boundaries, mornings, bedtime, and getting back on track.',
                    active: snapshot.isPlusUnlocked,
                    onPressed: () => _openFeature(
                      BreakWaveFeature.guidedRoutines,
                      _openGuidedRoutines,
                    ),
                  ),
                  _FeatureEntry(
                    title: 'Recovery reports',
                    body:
                        'Privacy-first summaries and selected accountability information you control.',
                    active: snapshot.isPlusUnlocked,
                    onPressed: () => _openFeature(
                      BreakWaveFeature.enhancedRecoveryReports,
                      _openRecoveryReport,
                    ),
                  ),
                  _FeatureEntry(
                    title: 'Christian recovery journeys',
                    body:
                        'Multi-step journeys with Scripture, reflection, action, prayer, saved progress, and connections back to recovery tools.',
                    active: snapshot.isPlusUnlocked,
                    onPressed: () => _openFeature(
                      BreakWaveFeature.christianJourneys,
                      _openChristianJourneys,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PlusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'What stays free',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rescue and immediate interruption remain available without Plus. Basic logging, privacy controls, essential support resources, and base Christian or secular recovery support are not locked behind a subscription.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessStatusCard extends StatelessWidget {
  const _AccessStatusCard({required this.snapshot});
  final BreakWavePlusSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final bool active = snapshot.isPlusUnlocked;
    final Color statusColor =
        active ? Colors.blue : Colors.grey.shade600;

    return _PlusCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  active ? 'BreakWave Plus is active' : 'BreakWave Plus',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  active
                      ? 'Your trusted Plus access is verified.'
                      : 'Free remains fully usable. Upgrade only if the store catalog is available and Plus is right for you.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansCard extends StatelessWidget {
  const _PlansCard({
    required this.snapshot,
    required this.onMonthly,
    required this.onAnnual,
  });

  final BreakWavePlusSnapshot snapshot;
  final Future<void> Function() onMonthly;
  final Future<void> Function() onAnnual;

  @override
  Widget build(BuildContext context) {
    if (snapshot.loading) {
      return const _PlusCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!snapshot.revenueCatConfigured ||
        !snapshot.catalogReady ||
        snapshot.monthly == null ||
        snapshot.annual == null) {
      return const _PlusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Purchases are not available on this build yet.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'BreakWave Free and Rescue remain available. Plan prices appear here only when the connected store catalog is ready.',
            ),
          ],
        ),
      );
    }

    return _PlusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Choose a plan',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prices below come directly from the connected store. No trial or discount is assumed.',
          ),
          const SizedBox(height: 14),
          _PlanButton(
            title: 'Monthly',
            plan: snapshot.monthly!,
            enabled: !snapshot.busy,
            onPressed: onMonthly,
          ),
          const SizedBox(height: 10),
          _PlanButton(
            title: 'Annual',
            plan: snapshot.annual!,
            enabled: !snapshot.busy,
            onPressed: onAnnual,
          ),
        ],
      ),
    );
  }
}

class _PlanButton extends StatelessWidget {
  const _PlanButton({
    required this.title,
    required this.plan,
    required this.enabled,
    required this.onPressed,
  });

  final String title;
  final BreakWavePlusPlanOption plan;
  final bool enabled;
  final Future<void> Function() onPressed;

  String get _period => switch (plan.subscriptionPeriod) {
        'P1M' => 'per month',
        'P1Y' => 'per year',
        final String value => value,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Column(
            children: <Widget>[
              Text(
                '$title — ${plan.priceString}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(_period),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreActionsCard extends StatelessWidget {
  const _StoreActionsCard({
    required this.snapshot,
    required this.onRestore,
    required this.onRefresh,
  });

  final BreakWavePlusSnapshot snapshot;
  final Future<void> Function() onRestore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return _PlusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (snapshot.notice != null) ...<Widget>[
            Text(
              snapshot.notice!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: snapshot.busy ? null : onRefresh,
                  child: const Text('Refresh access'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: snapshot.busy ? null : onRestore,
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          ),
          if (snapshot.busy) ...<Widget>[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _FeatureEntry extends StatelessWidget {
  const _FeatureEntry({
    required this.title,
    required this.body,
    required this.active,
    required this.onPressed,
  });

  final String title;
  final String body;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  active
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: active ? Colors.blue : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(body),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: active ? onPressed : null,
                child: Text(
                  active ? 'Open' : 'Available with verified Plus',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusCard extends StatelessWidget {
  const _PlusCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
