// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_app_handoff_card.dart
// Purpose: BW-44B email app handoff card.
// Notes: Saves a team email and opens a prefilled draft in the user's email app.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/email_capture/email_app_handoff_service.dart';
import '../../../../core/email_capture/email_app_handoff_settings.dart';
import '../../../../core/email_capture/email_app_handoff_store.dart';
import '../../../../core/email_capture/email_capture_settings.dart';
import '../../../../core/email_capture/email_capture_store.dart';

class EmailAppHandoffCard extends StatefulWidget {
  const EmailAppHandoffCard({super.key});

  @override
  State<EmailAppHandoffCard> createState() => _EmailAppHandoffCardState();
}

class _EmailAppHandoffCardState extends State<EmailAppHandoffCard> {
  late final TextEditingController _teamEmailController;

  bool _loading = true;
  bool _working = false;
  EmailCaptureSettings _emailSettings = EmailCaptureSettings.defaults;
  EmailAppHandoffSettings _handoffSettings =
      EmailAppHandoffSettings.defaults;

  @override
  void initState() {
    super.initState();
    _teamEmailController = TextEditingController();
    EmailCaptureStore.changes.addListener(_load);
    EmailAppHandoffStore.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    EmailCaptureStore.changes.removeListener(_load);
    EmailAppHandoffStore.changes.removeListener(_load);
    _teamEmailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final EmailCaptureSettings emailSettings = await EmailCaptureStore.load();
    final EmailAppHandoffSettings handoffSettings =
        await EmailAppHandoffStore.load();

    if (!mounted) return;

    _teamEmailController.text = handoffSettings.teamEmailAddress;

    setState(() {
      _emailSettings = emailSettings;
      _handoffSettings = handoffSettings;
      _loading = false;
    });
  }

  Future<void> _saveRecipient() async {
    if (_working) return;

    final String email = _teamEmailController.text.trim();
    if (!(email.contains('@') && email.contains('.'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid BreakWave team email address first.'),
        ),
      );
      return;
    }

    setState(() {
      _working = true;
    });

    try {
      await EmailAppHandoffStore.save(
        EmailAppHandoffSettings(teamEmailAddress: email),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BreakWave team email saved locally.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save team email right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _clearRecipient() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      await EmailAppHandoffStore.clear();

      if (!mounted) return;
      _teamEmailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BreakWave team email cleared.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear team email right now.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _openDraft() async {
    if (_working) return;

    setState(() {
      _working = true;
    });

    try {
      final bool ok = await EmailAppHandoffService.openSavedDraft();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Opened email draft handoff.'
                : 'Unable to open the email app right now.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open draft right now: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool hasData =
        EmailAppHandoffService.hasSendableData(_emailSettings);

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
                  'Send to BreakWave team',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Manual only. Save one team email address, then open a prefilled draft in Gmail or the default email app when you choose.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _teamEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'BreakWave team email',
                    hintText: 'Example: team@breakwave.app',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hasData
                      ? 'Saved email-consent data is ready to send.'
                      : 'No saved email-consent data yet.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: _working ? null : _saveRecipient,
                      child: const Text('Save team email'),
                    ),
                    OutlinedButton(
                      onPressed: _working ? null : _clearRecipient,
                      child: const Text('Clear team email'),
                    ),
                    FilledButton(
                      onPressed: (!_working &&
                              _handoffSettings.hasRecipient &&
                              hasData)
                          ? _openDraft
                          : null,
                      child: Text(_working ? 'Opening...' : 'Send saved data now'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
