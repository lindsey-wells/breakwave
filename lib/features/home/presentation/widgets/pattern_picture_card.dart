// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: pattern_picture_card.dart
// Purpose: BW-89A9 unified presentation of separate Recognize signals.
// Notes: Composes Log, Daily Context, and Bedtime Context observations
// without blending evidence, creating a risk score, or inferring causation.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/bedtime/bedtime_mode_entry.dart';
import '../../../../core/bedtime/bedtime_mode_store.dart';
import '../../../../core/checkin/daily_check_in_entry.dart';
import '../../../../core/checkin/daily_check_in_store.dart';
import '../../../log/data/log_repository.dart';
import '../../../log/domain/log_entry.dart';
import '../../../patterns/domain/bedtime_context_observation.dart';
import '../../../patterns/domain/bedtime_context_observation_engine.dart';
import '../../../patterns/domain/daily_context_observation.dart';
import '../../../patterns/domain/daily_context_observation_engine.dart';
import '../../../patterns/domain/pattern_observation.dart';
import '../../../patterns/domain/pattern_observation_engine.dart';

class PatternPictureCard extends StatefulWidget {
  const PatternPictureCard({super.key});

  @override
  State<PatternPictureCard> createState() => _PatternPictureCardState();
}

class _PatternPictureCardState extends State<PatternPictureCard> {
  bool _loading = true;
  PatternObservationResult? _logResult;
  DailyContextObservationResult? _dailyResult;
  BedtimeContextObservationResult? _bedtimeResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final List<LogEntry> logEntries =
          await const LogRepository().loadEntries();
      final List<DailyCheckInEntry> dailyEntries =
          await DailyCheckInStore.loadEntries();
      final List<BedtimeModeEntry> bedtimeEntries =
          await BedtimeModeStore.loadEntries();
      final DateTime now = DateTime.now();

      final PatternObservationResult logResult =
          const PatternObservationEngine().evaluate(
        entries: logEntries,
        now: now,
      );
      final DailyContextObservationResult dailyResult =
          const DailyContextObservationEngine().evaluate(
        entries: dailyEntries,
        now: now,
      );
      final BedtimeContextObservationResult bedtimeResult =
          const BedtimeContextObservationEngine().evaluate(
        entries: bedtimeEntries,
        now: now,
      );

      if (!mounted) return;

      setState(() {
        _logResult = logResult;
        _dailyResult = dailyResult;
        _bedtimeResult = bedtimeResult;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Card(
      key: const ValueKey<String>('pattern-picture-card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Pattern Picture',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'See the signals without turning them into conclusions.',
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...<Widget>[
              _PatternPictureSection(
                icon: Icons.waves_outlined,
                title: 'Recovery moments',
                source: 'From your Log',
                messages: _logMessages(),
              ),
              const SizedBox(height: 12),
              _PatternPictureSection(
                icon: Icons.wb_sunny_outlined,
                title: 'Daily context',
                source: 'From Daily Check-In',
                messages: <String>[
                  _dailyResult?.message ??
                      'Daily Check-In context is not available right now.',
                ],
              ),
              const SizedBox(height: 12),
              _PatternPictureSection(
                icon: Icons.nightlight_outlined,
                title: 'Bedtime context',
                source: 'From bedtime check-ins',
                messages: <String>[
                  _bedtimeResult?.message ??
                      'Bedtime context is not available right now.',
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'These are separate observations from what you recorded. '
                  'They can help you notice repetition, but they do not '
                  'explain what caused a wave or predict what happens next.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _logMessages() {
    final PatternObservationResult? result = _logResult;
    if (result == null) {
      return const <String>[
        'Log observations are not available right now.',
      ];
    }

    if (!result.hasEnoughData) {
      return <String>[
        'Keep logging recovery moments. Three recent behavioral entries '
            'are needed before looking for repetition.',
      ];
    }

    if (!result.hasObservations) {
      return <String>[
        'No repeated Log signal stands out yet in the last '
            '${result.windowDays} days.',
      ];
    }

    return result.observations
        .take(3)
        .map((PatternObservation item) => item.message)
        .toList(growable: false);
  }
}

class _PatternPictureSection extends StatelessWidget {
  const _PatternPictureSection({
    required this.icon,
    required this.title,
    required this.source,
    required this.messages,
  });

  final IconData icon;
  final String title;
  final String source;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            source,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (int index = 0; index < messages.length; index += 1) ...<Widget>[
            if (index > 0) const SizedBox(height: 6),
            Text(messages[index]),
          ],
        ],
      ),
    );
  }
}
