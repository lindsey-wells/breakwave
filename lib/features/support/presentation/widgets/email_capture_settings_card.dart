// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_capture_settings_card.dart
// Purpose: BW-42 optional email capture card.
// Notes: Saves email + separate marketing/research consent locally.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/email_capture/email_capture_settings.dart';
import '../../../../core/email_capture/email_capture_store.dart';

class EmailCaptureSettingsCard extends StatefulWidget {
  const EmailCaptureSettingsCard({super.key});

  @override
  State<EmailCaptureSettingsCard> createState() => _EmailCaptureSettingsCardState();
}

class _EmailCaptureSettingsCardState extends State<EmailCaptureSettingsCard> {
  late final TextEditingController _emailController;

  bool _loading = true;
  bool _saving = false;
  bool _marketingOptIn = false;
  bool _researchOptIn = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final EmailCaptureSettings settings = await EmailCaptureStore.load();
    if (!mounted) return;

    _emailController.text = settings.emailAddress;

    setState(() {
      _marketingOptIn = settings.marketingOptIn;
      _researchOptIn = settings.researchOptIn;
      _hasSaved = settings.emailAddress.trim().isNotEmpty || settings.hasAnyConsent;
      _loading = false;
    });
  }

  bool _looksLikeEmail(String value) {
    final String email = value.trim();
    return email.contains('@') && email.contains('.');
  }

  Future<void> _save() async {
    if (_saving) return;

    final String email = _emailController.text.trim();

    if ((_marketingOptIn || _researchOptIn) && !_looksLikeEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address to save consent choices.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await EmailCaptureStore.save(
        EmailCaptureSettings(
          emailAddress: email,
          marketingOptIn: _marketingOptIn,
          researchOptIn: _researchOptIn,
        ),
      );

      if (!mounted) return;

      setState(() {
        _hasSaved = email.isNotEmpty || _marketingOptIn || _researchOptIn;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email preferences saved locally.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save email preferences right now.'),
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

  Future<void> _clear() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await EmailCaptureStore.clear();

      if (!mounted) return;

      _emailController.clear();

      setState(() {
        _marketingOptIn = false;
        _researchOptIn = false;
        _hasSaved = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email preferences cleared.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear email preferences right now.'),
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
                  'Stay in touch',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Optional only. BreakWave help works without email.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'Example: you@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _marketingOptIn,
                  onChanged: (bool value) {
                    setState(() {
                      _marketingOptIn = value;
                    });
                  },
                  title: const Text('Send me product updates'),
                  subtitle: const Text('Optional marketing / feature updates.'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _researchOptIn,
                  onChanged: (bool value) {
                    setState(() {
                      _researchOptIn = value;
                    });
                  },
                  title: const Text('Invite me to research or feedback'),
                  subtitle: const Text('Optional product interviews, surveys, or beta feedback.'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_saving ? 'Saving...' : 'Save email preferences'),
                  ),
                ),
                if (_hasSaved) ...<Widget>[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saving ? null : _clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Clear email preferences'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
