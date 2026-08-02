// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: support_contact_card.dart
// Purpose: BW-21/BW-37 support contact card.
// Notes: Saves one trusted contact with phone and/or email for direct actions.
// Notes: BW-86B2 adds inline saved-state clarity for trusted contact.
// Notes: BW-SUPPORT-01B uses approved stronger-wave terminology.
// Notes: BW-PRIVACY-01A keeps saved contact details masked until editing.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/support/support_contact.dart';
import '../../../../core/support/support_contact_masking.dart';
import '../../../../core/support/support_contact_store.dart';

class SupportContactCard extends StatefulWidget {
  const SupportContactCard({super.key});

  @override
  State<SupportContactCard> createState() =>
      _SupportContactCardState();
}

class _SupportContactCardState extends State<SupportContactCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  SupportContact? _savedContact;
  bool _loading = true;
  bool _saving = false;
  bool _hasSavedContact = false;
  bool _editing = true;
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

  void _setControllerValues(SupportContact? contact) {
    _nameController.text = contact?.name ?? '';
    _phoneController.text = contact?.phoneNumber ?? '';
    _emailController.text = contact?.emailAddress ?? '';
  }

  Future<void> _load() async {
    final SupportContact? contact =
        await SupportContactStore.loadContact();
    if (!mounted) return;

    _setControllerValues(contact);

    setState(() {
      _savedContact = contact;
      _hasSavedContact = contact != null;
      _editing = contact == null;
      _loading = false;
    });
  }

  void _handleDraftChanged() {
    if (!mounted ||
        _loading ||
        _saving ||
        _savedStatusMessage == null) {
      return;
    }

    setState(() {
      _savedStatusMessage = null;
    });
  }

  void _beginEditing() {
    _setControllerValues(_savedContact);
    setState(() {
      _editing = true;
      _savedStatusMessage = null;
    });
  }

  void _cancelEditing() {
    _setControllerValues(_savedContact);
    setState(() {
      _editing = false;
      _savedStatusMessage = null;
    });
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final String phoneNumber = _phoneController.text.trim();
    final String emailAddress = _emailController.text.trim();

    if (name.isEmpty ||
        (phoneNumber.isEmpty && emailAddress.isEmpty) ||
        _saving) {
      return;
    }

    final SupportContact savedContact = SupportContact(
      name: name,
      phoneNumber: phoneNumber,
      emailAddress: emailAddress,
    );

    setState(() {
      _saving = true;
    });

    try {
      await SupportContactStore.saveContact(savedContact);

      if (!mounted) return;

      setState(() {
        _savedContact = savedContact;
        _hasSavedContact = true;
        _editing = false;
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
          content: Text(
            'Unable to save that trusted contact right now.',
          ),
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
        _savedContact = null;
        _hasSavedContact = false;
        _editing = true;
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
          content: Text(
            'Unable to clear that trusted contact right now.',
          ),
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

  Widget _buildStatusBanner(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
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
    );
  }

  Widget _buildMaskedSummary(
    BuildContext context,
    ThemeData theme,
    SupportContact contact,
  ) {
    return Column(
      key: const Key('trusted-contact-masked-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Saved contact: ${contact.name}',
          style: theme.textTheme.bodyMedium,
        ),
        if (contact.hasPhone) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Phone: ${SupportContactMasking.phone(contact.phoneNumber)}',
            key: const Key('trusted-contact-editor-masked-phone'),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (contact.hasEmail) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Email: ${SupportContactMasking.email(contact.emailAddress)}',
            key: const Key('trusted-contact-editor-masked-email'),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 10),
        Text(
          'Contact details stay masked until you deliberately edit them. Text and email support actions still use the saved information.',
          style: theme.textTheme.bodySmall,
        ),
        if (_savedStatusMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          _buildStatusBanner(
            context,
            theme,
            Theme.of(context).colorScheme,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          key: const Key('trusted-contact-edit-details'),
          onPressed: _saving ? null : _beginEditing,
          icon: const Icon(Icons.edit_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Edit contact details'),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _saving ? null : _clear,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Clear trusted contact'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      key: const Key('trusted-contact-editor'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_hasSavedContact) ...<Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'Contact details are visible while you edit them. Saving or cancelling returns this section to its privacy mask.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          key: const Key('trusted-contact-name-field'),
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Contact name',
            hintText: 'Example: Alex',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('trusted-contact-phone-field'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: 'Example: 8005551212',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('trusted-contact-email-field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'Example: alex@example.com',
          ),
        ),
        if (_savedStatusMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          _buildStatusBanner(
            context,
            theme,
            colorScheme,
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
                  : _hasSavedContact &&
                          _savedStatusMessage ==
                              'Trusted contact saved.'
                      ? 'Saved trusted contact'
                      : 'Save trusted contact',
            ),
          ),
        ),
        if (_hasSavedContact) ...<Widget>[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('trusted-contact-cancel-editing'),
            onPressed: _saving ? null : _cancelEditing,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Cancel editing and mask details'),
            ),
          ),
        ],
      ],
    );
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
                  'Save one person you can reach when the wave starts getting stronger. Add a phone number, an email, or both.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (_savedContact != null && !_editing)
                  _buildMaskedSummary(
                    context,
                    theme,
                    _savedContact!,
                  )
                else
                  _buildEditor(
                    context,
                    theme,
                    colorScheme,
                  ),
              ],
            ),
    );
  }
}
