// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: bedtime_danger_mode_card.dart
// Purpose: BW-23 bedtime danger mode card.
// Notes: Home-level late-night risk prompt with one-tap Rescue path.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/bedtime/bedtime_mode_entry.dart';
import '../../../../core/bedtime/bedtime_mode_store.dart';
import '../../../../core/recovery/recovery_mode.dart';
import '../../../../core/recovery/recovery_mode_store.dart';
import '../../../../core/widget/home_widget_sync.dart';

class BedtimeDangerModeCard extends StatefulWidget {
  const BedtimeDangerModeCard({
    super.key,
    required this.onOpenRescue,
  });

  final VoidCallback onOpenRescue;

  @override
  State<BedtimeDangerModeCard> createState() => _BedtimeDangerModeCardState();
}

class _BedtimeDangerModeCardState extends State<BedtimeDangerModeCard> {
  bool _loading = true;
  bool _saving = false;
  bool? _isRiskyTonight;
  RecoveryMode _mode = RecoveryMode.secular;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final BedtimeModeEntry? entry = await BedtimeModeStore.loadTodayEntry();
    final RecoveryMode mode =
        await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;

    if (!mounted) return;

    setState(() {
      _isRiskyTonight = entry?.isRisky;
      _mode = mode;
      _loading = false;
    });
  }

  Future<void> _save(bool isRisky) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await BedtimeModeStore.saveTodayRisk(isRisky);
      await BreakWaveHomeWidgetSync.sync();
      if (!mounted) return;

      setState(() {
        _isRiskyTonight = isRisky;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRisky
                ? 'Saved bedtime risk for tonight.'
                : 'Saved tonight as steady.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save bedtime mode right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _headline() {
    if (_mode == RecoveryMode.christian) {
      return 'Bedtime danger mode';
    }
    return 'Bedtime check';
  }

  String _bodyText() {
    if (_isRiskyTonight == true) {
      if (_mode == RecoveryMode.christian) {
        return 'Tonight may need extra honesty, light, and quick obedience. Bring the wave into the open early instead of facing it alone in the dark.';
      }
      return 'Tonight may need extra structure. Reduce isolation, reduce privacy, and interrupt the pattern before it gains momentum.';
    }

    if (_isRiskyTonight == false) {
      if (_mode == RecoveryMode.christian) {
        return 'Tonight looks steadier. Stay watchful, stay honest, and choose the safer path early if the wave starts rising.';
      }
      return 'Tonight looks steadier. Stay aware, and interrupt the pattern early if the wave starts rising.';
    }

    if (_mode == RecoveryMode.christian) {
      return 'Late-night temptation often grows where fatigue and secrecy meet. Mark tonight honestly before the window gets harder.';
    }
    return 'Late-night drift often gets louder when fatigue and privacy combine. Mark tonight honestly before the window gets harder.';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
              children: <Widget>[
                Text(
                  _headline(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _bodyText(),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('Tonight feels steady'),
                      selected: _isRiskyTonight == false,
                      onSelected: _saving ? null : (bool selected) {
                        if (!selected) return;
                        _save(false);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Tonight feels risky'),
                      selected: _isRiskyTonight == true,
                      onSelected: _saving ? null : (bool selected) {
                        if (!selected) return;
                        _save(true);
                      },
                    ),
                  ],
                ),
                if (_isRiskyTonight == true) ...<Widget>[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.onOpenRescue,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Open Rescue now'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
