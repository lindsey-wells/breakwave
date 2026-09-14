// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_safe_screen.dart
// Purpose: IOS-G2G data-minimized Rescue presentation while Full App lock remains active.
// Notes:
// - Uses only generic, non-personalized Rescue tools.
// - Owns only in-memory presentation state.
// - Does not read/write recovery history, Personal Why, Support, billing, or account data.
// ------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';

import 'widgets/calm_reset_card.dart';
import 'widgets/urge_intensity_section.dart';

class RescueSafeScreen extends StatefulWidget {
  const RescueSafeScreen({
    super.key,
    required this.onUnlock,
    required this.onBackToLock,
  });

  final VoidCallback onUnlock;
  final VoidCallback onBackToLock;

  @override
  State<RescueSafeScreen> createState() => _RescueSafeScreenState();
}

class _RescueSafeScreenState extends State<RescueSafeScreen> {
  int _selectedIntensity = 3;
  String? _selectedRedirect;
  String? _outcome;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: <Widget>[
          Text(
            'Rescue-safe access',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your private recovery information is still locked. These generic tools stay available without opening your history, Personal Why, Support settings, or account areas.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          UrgeIntensitySection(
            selectedIntensity: _selectedIntensity,
            onSelected: (int value) {
              setState(() {
                _selectedIntensity = value;
              });
            },
          ),
          const SizedBox(height: 14),
          const CalmResetCard(),
          const SizedBox(height: 14),
          const _RescueSafeTimerCard(),
          const SizedBox(height: 14),
          _GenericRedirectCard(
            selected: _selectedRedirect,
            onSelected: (String value) {
              setState(() {
                _selectedRedirect = value;
              });
            },
          ),
          const SizedBox(height: 14),
          _RescueSafeOutcomeCard(
            outcome: _outcome,
            onOutcome: (String value) {
              setState(() {
                _outcome = value;
              });
            },
          ),
          const SizedBox(height: 14),
          const _ExternalSupportGuidanceCard(),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: widget.onUnlock,
            icon: const Icon(Icons.lock_open_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Unlock BreakWave'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: widget.onBackToLock,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Back to privacy lock'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RescueSafeTimerCard extends StatefulWidget {
  const _RescueSafeTimerCard();

  @override
  State<_RescueSafeTimerCard> createState() => _RescueSafeTimerCardState();
}

class _RescueSafeTimerCardState extends State<_RescueSafeTimerCard> {
  static const int _durationSeconds = 60;

  Timer? _timer;
  int _remainingSeconds = _durationSeconds;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() {
        _running = false;
      });
      return;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _durationSeconds;
    }

    setState(() {
      _running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _running = false;
        });
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = _durationSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '60-second pause',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Stay here for one minute. Nothing from this timer is written to your recovery history.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Text(
              '$_remainingSeconds seconds',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton(
                  onPressed: _toggle,
                  child: Text(_running ? 'Pause timer' : 'Start timer'),
                ),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericRedirectCard extends StatelessWidget {
  const _GenericRedirectCard({
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  static const List<String> _actions = <String>[
    'Move to a different room',
    'Put the phone down for 60 seconds',
    'Drink a glass of water',
    'Step outside if it is safe',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Choose a generic redirect',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick one small action that changes what your body or environment is doing right now.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            for (final String action in _actions)
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: action,
                groupValue: selected,
                onChanged: (String? value) {
                  if (value != null) onSelected(value);
                },
                title: Text(action),
              ),
          ],
        ),
      ),
    );
  }
}

class _RescueSafeOutcomeCard extends StatelessWidget {
  const _RescueSafeOutcomeCard({
    required this.outcome,
    required this.onOutcome,
  });

  final String? outcome;
  final ValueChanged<String> onOutcome;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'How is the wave now?',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This check-in stays only on this screen for now. Nothing is saved to recovery history while the app is locked.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () => onOutcome('easing'),
                  child: const Text('Wave is easing'),
                ),
                OutlinedButton(
                  onPressed: () => onOutcome('strong'),
                  child: const Text('Still strong'),
                ),
              ],
            ),
            if (outcome != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                outcome == 'easing'
                    ? 'Keep the distance you created. You can continue these generic tools or unlock BreakWave when you are ready.'
                    : 'Stay with the generic tools. You can repeat the breathing reset, use the timer, change locations, or unlock BreakWave for personalized Rescue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExternalSupportGuidanceCard extends StatelessWidget {
  const _ExternalSupportGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.people_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Need support outside the app? Move toward a safe person or place. If you are in immediate danger, contact local emergency services.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
