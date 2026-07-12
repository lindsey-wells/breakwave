// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_insights_screen.dart
// Purpose: Real 7/30/90-day recovery insights from local logs.
// Notes: BW-87B2B provides honest summaries without prediction.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../log/data/log_repository.dart';
import '../domain/recovery_insights_calculator.dart';
import '../domain/recovery_insights_snapshot.dart';

class RecoveryInsightsScreen extends StatefulWidget {
  const RecoveryInsightsScreen({super.key});

  @override
  State<RecoveryInsightsScreen> createState() =>
      _RecoveryInsightsScreenState();
}

class _RecoveryInsightsScreenState
    extends State<RecoveryInsightsScreen> {
  final LogRepository _repository = const LogRepository();
  final RecoveryInsightsCalculator _calculator =
      const RecoveryInsightsCalculator();

  RecoveryInsightsSnapshot? _snapshot;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final entries = await _repository.loadEntries();

      final RecoveryInsightsSnapshot snapshot =
          _calculator.calculate(
        entries: entries,
        now: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'BreakWave could not load your recovery insights. '
            'Your saved logs were not changed.';
        _loading = false;
      });
    }
  }

  String _countLabel(
    int count,
    String singular,
    String plural,
  ) {
    return '$count ${count == 1 ? singular : plural}';
  }

  String _weeklySummary(
    RecoveryPeriodSummary summary,
  ) {
    if (!summary.hasEntries) {
      return 'No recovery moments were logged in the last 7 days. '
          'As you use Log, this summary will reflect what you record.';
    }

    final String momentLabel =
        summary.total == 1 ? 'moment' : 'moments';

    return 'You recorded ${summary.total} recovery $momentLabel '
        'in the last 7 days: '
        '${_countLabel(summary.urges, 'urge', 'urges')}, '
        '${_countLabel(summary.victories, 'victory', 'victories')}, '
        'and ${_countLabel(summary.slips, 'slip', 'slips')}. '
        'Average recorded intensity was '
        '${summary.averageIntensity.toStringAsFixed(1)} out of 5.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery insights'),
        actions: <Widget>[
          IconButton(
            onPressed: _loading ? null : _loadInsights,
            tooltip: 'Refresh recovery insights',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _snapshot == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _InsightsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle('Insights unavailable'),
                const SizedBox(height: 10),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loadInsights,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final RecoveryInsightsSnapshot snapshot = _snapshot!;

    return RefreshIndicator(
      onRefresh: _loadInsights,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: <Widget>[
          const _InsightsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitle('Patterns from what you logged'),
                SizedBox(height: 10),
                Text(
                  'These insights use only recovery entries saved on this device. '
                  'They describe recorded patterns—they do not predict relapse, '
                  'diagnose a condition or replace professional support.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InsightsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle('Your last 7 days'),
                const SizedBox(height: 10),
                Text(_weeklySummary(snapshot.last7Days)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PeriodCard(
            title: 'Last 30 days',
            summary: snapshot.last30Days,
          ),
          const SizedBox(height: 16),
          _PeriodCard(
            title: 'Last 90 days',
            summary: snapshot.last90Days,
          ),
          const SizedBox(height: 16),
          _TriggerCard(
            triggers: snapshot.topTriggers30Days,
          ),
          const SizedBox(height: 16),
          _PatternCard(snapshot: snapshot),
          if (snapshot.ignoredEntryCount > 0) ...<Widget>[
            const SizedBox(height: 16),
            _InsightsCard(
              child: Text(
                '${snapshot.ignoredEntryCount} saved '
                '${snapshot.ignoredEntryCount == 1 ? 'entry was' : 'entries were'} '
                'excluded because the date or entry type could not '
                'be used safely.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.title,
    required this.summary,
  });

  final String title;
  final RecoveryPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final String intensity = summary.hasEntries
        ? summary.averageIntensity.toStringAsFixed(1)
        : '—';

    return _InsightsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(title),
          const SizedBox(height: 12),
          _MetricLine(
            label: 'Logged moments',
            value: summary.total.toString(),
          ),
          _MetricLine(
            label: 'Urges',
            value: summary.urges.toString(),
          ),
          _MetricLine(
            label: 'Victories',
            value: summary.victories.toString(),
          ),
          _MetricLine(
            label: 'Slips',
            value: summary.slips.toString(),
          ),
          _MetricLine(
            label: 'Average intensity',
            value: summary.hasEntries ? '$intensity / 5' : intensity,
          ),
        ],
      ),
    );
  }
}

class _TriggerCard extends StatelessWidget {
  const _TriggerCard({
    required this.triggers,
  });

  final List<TriggerInsight> triggers;

  @override
  Widget build(BuildContext context) {
    return _InsightsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionTitle('Top recorded triggers — 30 days'),
          const SizedBox(height: 10),
          if (triggers.isEmpty)
            const Text(
              'No triggers have been recorded in the last 30 days.',
            )
          else
            ...triggers.map(
              (TriggerInsight item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• ${item.trigger}: ${item.count} '
                  '${item.count == 1 ? 'entry' : 'entries'}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.snapshot,
  });

  final RecoveryInsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final List<String> observations = <String>[];

    if (snapshot.busiestWeekday30Days != null) {
      observations.add(
        '${snapshot.busiestWeekday30Days} appeared most often '
        'in your last 30 days of logs.',
      );
    }

    if (snapshot.busiestTimeWindow30Days != null) {
      observations.add(
        '${snapshot.busiestTimeWindow30Days} was the most common '
        'time window in your recorded entries.',
      );
    }

    return _InsightsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionTitle('Recorded timing patterns'),
          const SizedBox(height: 10),
          if (!snapshot.hasEnoughForTimePatterns)
            const Text(
              'Keep logging to build a useful timing pattern. '
              'At least 5 valid entries in 30 days are needed '
              'before BreakWave shows weekday or time observations.',
            )
          else if (observations.isEmpty)
            const Text(
              'No single weekday or time window clearly stood out '
              'in the last 30 days.',
            )
          else
            ...observations.map(
              (String text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $text'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
