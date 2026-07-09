// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_card.dart
// Purpose: BW-21/BW-37 support contact card.
// Notes: Saves one trusted contact with phone and/or email for direct actions.
// Notes: BW-86B2 adds inline saved-state clarity for trusted contact.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_store.dart';

class SupportContactCard extends StatefulWidget {
  const SupportContactCard({super.key});

  @override
  State<SupportContactCard> createState() => _SupportContactCardState();
}

class _SupportContactCardState extends State<SupportContactCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _loading = true;
  bool _saving = false;
  bool _hasSavedContact = false;
  String? _savedStatusMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _nameController.addListener(_handleDraftChanged);
    _phoneController.addListener(_handleDraftChanged);
    _emailController.addListener(_handleDraftChanged);
    _load();
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleDraftChanged);
    _phoneController.removeListener(_handleDraftChanged);
    _emailController.removeListener(_handleDraftChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final SupportContact? contact = await SupportContactStore.loadContact();
    if (!mounted) return;

    _nameController.text = contact?.name ?? '';
    _phoneController.text = contact?.phoneNumber ?? '';
    _emailController.text = contact?.emailAddress ?? '';

    setState(() {
      _hasSavedContact = contact != null;
      _loading = false;
    });
  }


  void _handleDraftChanged() {
    if (!mounted || _loading || _saving || _savedStatusMessage == null) return;

    setState(() {
      _savedStatusMessage = null;
    });
  }
  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
    final String emailAddress = _emailController.text.trim();

    if (name.isEmpty || (phoneNumber.isEmpty && emailAddress.isEmpty) || _saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await SupportContactStore.saveContact(
        SupportContact(
          name: name,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
        ),
      );

      if (!mounted) return;

      setState(() {
        _hasSavedContact = true;
          _savedStatusMessage = 'Trusted contact saved.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trusted contact saved.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save that trusted contact right now.'),
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
      await SupportContactStore.clearContact();

      if (!mounted) return;

      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();

      setState(() {
        _hasSavedContact = false;
          _savedStatusMessage = 'Trusted contact cleared.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trusted contact cleared.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear that trusted contact right now.'),
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
                  'Trusted contact',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Save one person you can reach when the wave starts getting louder. Add a phone number, an email, or both.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact name',
                    hintText: 'Example: Alex',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: 'Example: 8005551212',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'Example: alex@example.com',
                  ),
                ),
                  if (_savedStatusMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _savedStatusMessage == 'Trusted contact saved.'
                                  ? 'Trusted contact saved. Ready for ${_nameController.text.trim()} when you need support.'
                                  : 'Trusted contact cleared. Add a new person when you are ready.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _saving
                            ? 'Saving...'
                            : _hasSavedContact && _savedStatusMessage == 'Trusted contact saved.'
                                ? 'Saved trusted contact'
                                : 'Save trusted contact',
                      ),
                  ),
                ),
                if (_hasSavedContact) ...<Widget>[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saving ? null : _clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Clear trusted contact'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
