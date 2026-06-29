// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: privacy_settings_card.dart
// Purpose: BW-24 privacy settings card.
// Notes: Lets the user reduce visible detail and switch to discreet notifications.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/privacy/privacy_settings.dart';
import '../../../../core/privacy/privacy_settings_store.dart';
import '../../../../core/privacy/screen_privacy_service.dart';
import '../../../../core/reminders/breakwave_notifications.dart';
import '../../../../core/reminders/reminder_settings.dart';
import '../../../../core/reminders/reminder_settings_store.dart';
import '../../../../core/triggers/triggers_selection.dart';
import '../../../../core/triggers/triggers_store.dart';

class PrivacySettingsCard extends StatefulWidget {
  const PrivacySettingsCard({super.key});

  @override
  State<PrivacySettingsCard> createState() => _PrivacySettingsCardState();
}

class _PrivacySettingsCardState extends State<PrivacySettingsCard> {
  bool _loading = true;
  bool _saving = false;
  PrivacySettings _settings = PrivacySettings.defaults;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final PrivacySettings settings = await PrivacySettingsStore.load();

    if (!mounted) return;

    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await PrivacySettingsStore.save(_settings);
      await ScreenPrivacyService.setScreenPrivacyEnabled(
        _settings.blockScreenshotsAndScreenRecording,
      );

      final ReminderSettings reminderSettings = await ReminderSettingsStore.load();
      final TriggersSelection triggers = await TriggersStore.loadSelection();

      final bool rescheduled = await BreakWaveNotifications.safeRescheduleAll(
        settings: reminderSettings,
        triggersSelection: triggers,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            rescheduled
                ? 'Privacy settings saved.'
                : 'Privacy settings saved locally. Notification refresh may need another try.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save privacy settings right now.'),
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
                  'Privacy controls',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reduce visible detail on Home, use neutral notification text, and add screenshot protection when your device supports it.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Discreet notifications'),
                  subtitle: const Text('Use neutral notification text so BreakWave does not reveal recovery details on your lock screen.'),
                  value: _settings.discreetNotifications,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        discreetNotifications: value,
                      );
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hide Home insights'),
                  subtitle: const Text('Recommended when using Lock Log & Support so Home reveals less recovery detail.'),
                  value: _settings.hideHomeInsights,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        hideHomeInsights: value,
                      );
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hide latest logged moment'),
                  subtitle: const Text('Prevents recent log details from appearing on Home while the app is unlocked.'),
                  value: _settings.hideLatestLoggedMoment,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        hideLatestLoggedMoment: value,
                      );
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prevent screenshots while BreakWave is open'),
                  subtitle: const Text(
                    'Adds extra privacy by asking Android to block normal screenshots and screen recordings while BreakWave is open. This reduces casual exposure but is not absolute protection.',
                  ),
                  value: _settings.blockScreenshotsAndScreenRecording,
                  onChanged: (bool value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        blockScreenshotsAndScreenRecording: value,
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save privacy settings'),
                  ),
                ),
              ],
            ),
    );
  }
}
